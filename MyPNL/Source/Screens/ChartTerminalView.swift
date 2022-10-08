import SwiftUI
import Combine
import AlertToast
import Binance
import SwiftyUserDefaults

public class ChartTerminalViewModel: ObservableObject {
    
    // Static
    public static var min:Double = 0.0
    public static var max:Double = 0.0
    
    // Private variables
    private var lastRecivedStreamCandle: CandleStream? = nil
    private let socketID: Int = 10
    private var subscribers: [AnyCancellable] = []
    private var timeframe = "1m"
    private var isChartLoading: Bool = false
    
    // Public variables
    public var symbol: String
    
    // Published
    @Published var candles: [Candle] = []
    @Published var price: Double = 0.0
    @Published var pnl: Double = 0.0
    @Published public var position: PositionRisk?
    @Published var positionAmount: Double = 10.0
    @Published public var stageManager = DataLodingStageManager(stageCount: 2)
    @Published public var orderProcessing: Bool = false
    @Published public var positionUpdating: Bool = false
    @Published public var errorEvent: Bool = false
    @Published public var errorEventText: String = "Fail"
    
    
    init(symbol: String, position: PositionRisk?) {
        self.symbol = symbol
        self.position = position
        self.price = position?.markPrice ?? 0.0
        self.pnl = position?.unRealizedProfit ?? 0.0
        
        DefaultsKeys.saveOpened(symbol)
        
    }
    
    // States logic
    public func load() {
        isChartLoading = true
        stageManager.start()
        objectWillChange.send()
        fetchCandles()
        subscribeToWebscoket()
    }
    
    public func unload(){
        ChartTerminalViewModel.min = 0.0
        ChartTerminalViewModel.max = 0.0
        Web.shared.unsubscribe(from: "\(symbol.lowercased())@kline_\(timeframe)", id: socketID)
        subscribers.removeAll()
        candles.removeAll()
        lastRecivedStreamCandle = nil
        self.position = nil
    }
    
    public func reload(newTF: String){
        ChartTerminalViewModel.min = 0.0
        ChartTerminalViewModel.max = 0.0
        Web.shared.unsubscribe(from: "\(symbol.lowercased())@kline_\(timeframe)", id: socketID)
        subscribers.removeAll()
        candles.removeAll()
        lastRecivedStreamCandle = nil
        timeframe = newTF
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: { [weak self] in
            self?.load()
        })
    }
    
    // Fetch candles data from
    private func fetchCandles(){
        if let request = Web.shared.request(.fapi ,.get, .futures, .v1, "klines", [.init(name: "symbol", value: symbol.uppercased()), .init(name: "interval", value: timeframe),.init(name: "limit", value: "20")], useSignature: false) {
            Web.shared.REST(request, [Candle].self) { [weak self] responce in
                responce.forEach { self?.setMaxMin(candle: $0) }
                self?.candles = responce
                self?.isChartLoading = false
                self?.stageManager.finishStep()
            }
        }
    }
    
    // Refetch if some updates
    private func fetchPosition(){
        positionUpdating = true
        if let request = Web.shared.request(.fapi ,.get, .futures, .v2, "positionRisk", nil) {
            Web.shared.REST(request, [PositionRisk].self) { [weak self] responce in
                let newPosition = responce.first { pos in
                    pos.symbol == self?.symbol
                }
                self?.position = newPosition?.positionAmt == 0 ? nil : newPosition
                self?.positionUpdating = false
            }
        }
    }
    
    private func subscribeToWebscoket(){
        let socketURL = "\(symbol.lowercased())@kline_\(timeframe)"
        Web.shared.subscribe(.futuresSocket, to: socketURL, id: socketID)
        
        Web.shared.$stream.sink { [weak self] in
            
            if let update = try? decode(PositionUpdateStream.self, from: $0) {
                if update.o.x == "FILLED" {
                    print("FILLED")
                    self?.fetchPosition()
                }
            }
            
            if let socketActionResult = try? decode(SocketResponse.self, from: $0) {
                if socketActionResult.id == self?.socketID {
                    print("socketActionResult: ", socketActionResult.result as Any, " ID: ", socketActionResult.id)
                    self?.stageManager.finishStep(name: "connect to socket")
                }
            }
            
            if let streamCandle = try? decode(CandleStream.self, from: $0),
               let sSelf = self {
                if sSelf.isChartLoading { return }
                sSelf.parsStreamCandle(streamCandle)
                sSelf.parsPrice(streamCandle)
                if let position = sSelf.position, position.positionAmt != 0 {
                    sSelf.pnl = Finance.culcPNL(from: position)
                }
            }
        }.store(in: &subscribers)
    }
    
    private func parsStreamCandle(_ streamCandle: CandleStream) {
        let candle = streamCandle.candle()
        self.setMaxMin(candle: candle)
        if candles.last!.openTime == candle.openTime {
            lastRecivedStreamCandle = streamCandle
            candles[candles.count-1] = candle
        } else {
            if let last = lastRecivedStreamCandle, last.data.isClosed {
                candles.removeFirst()
                candles.append(candle)
            }
        }
    }
    
    private func parsPrice(_ streamCandle: CandleStream) {
        self.price = streamCandle.data.close
    }
    
    private func order(_ quantity: String, side: PositionSide){
        orderProcessing = true
        let side: String = side == .Long ? "BUY" : "SELL"
        
        let params: [URLQueryItem] = [.init(name: "symbol", value: self.symbol),
                                      .init(name: "side", value: side),
                                      .init(name: "type", value: "MARKET"),
                                      .init(name: "quantity", value: quantity)]
        
        if let request = Web.shared.request(.fapi, .post, .futures, .v1, "order", params, useTimestamp: true, useSignature: true) {
            
            Web.shared.REST(request, NewOrder.self, completion: { [weak self] responce in
                print("SELL:", responce.symbol, "Completed")
                self?.orderProcessing = false
            }, iferror: { [weak self] err in
                self?.orderProcessing = false
                self?.errorEventText = err.msg
                self?.errorEvent = true
            })
        }
    }
    
    public func sell() {
        let quantity: String = (positionAmount/price).truncate() // in $
        self.order(quantity, side: .Short)
    }
    public func buy() {
        let quantity: String = (positionAmount/price).truncate() // in $
        self.order(quantity, side: .Long)
    }
    public func close() {
        guard let position = position else { return }
        let quantity: String = String(abs(position.positionAmt))
        if Finance.positionSide(of: position) == .Long {
            self.order(quantity, side: .Short)
        } else {
            self.order(quantity, side: .Long)
        }
    }
    public func revertPosition() {
        guard let position = position else { return }
        let quantity: String = String(position.positionAmt*2)
        if Finance.positionSide(of: position) == .Long {
            self.order(quantity, side: .Short)
        } else {
            self.order(quantity, side: .Long)
        }
    }

    
    func setMaxMin(candle: Candle) {
        if ChartTerminalViewModel.max < candle.high { ChartTerminalViewModel.max = candle.high }
        if ChartTerminalViewModel.min == 0 { ChartTerminalViewModel.min = candle.low }
        if ChartTerminalViewModel.min > candle.low { ChartTerminalViewModel.min = candle.low }
    }
    
}

struct ChartTerminalView: View {
    
    @StateObject var model: ChartTerminalViewModel
    @State var timeframe = "1m"
    @FocusState private var amountIsFocused: Bool
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Chart \(timeframe)").lightFont()) {
                    Text(model.price.currency()).subtitleFont()
                    ZStack {
                        ChartView(candles: model.candles, position: model.position)
                        if model.candles.isEmpty {
                            ProgressView()
                        }
                    }
                    TimeFramePicker(selection: $timeframe)
                        .onChange(of: timeframe, perform: { newValue in
                        model.reload(newTF: newValue)
                    })
                }
                
                Section (header: Text("Position").lightFont()) {
                    if let pos = model.position, model.pnl != 0  {
                        VStack(alignment:.leading, spacing: 20) {
                            HStack {
                                Text("PNL ").articleFont()
                                Text("\(model.pnl.currency())").foregroundColor(model.pnl > 0 ? .green : .red).articleBoldFont()
                                Spacer()
                                Text("% ").articleFont()
                                Text(Finance.calcPriceChangePercentage(currentPrice: model.price, entryPrice: pos.entryPrice) ).foregroundColor(model.pnl > 0 ? .green : .red).articleBoldFont()
                            }
                            HStack {
                                Text("Side ").articleFont()
                                let side = Finance.positionSide(of: pos)
                                Text(side.rawValue).foregroundColor(side == .Long ? .green : .red).articleBoldFont()
                                Spacer()
                                Text("amt: ").articleFont()
                                Text("\(pos.positionAmt)").articleBoldFont()
                            }
                        }
                    }

                }
                
                Section(header: Text("Trade").lightFont()) {
                    VStack(alignment:.leading, spacing: 20) {

                        HStack {
                            TextField("Amount", value: $model.positionAmount, formatter: formatter)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(UIKeyboardType.decimalPad)
                                .focused($amountIsFocused)
                            
                            Button {
                                amountIsFocused = false
                            } label: {
                                Text("Apply").articleBoldFont()
                            }
                        }
                        
                        HStack {
                            Button {
                                model.buy()
                                amountIsFocused = false
                            } label: {
                                Text("Buy").articleBoldFont().foregroundColor(Color("BuyColor"))
                            }.buttonStyle(BorderedButtonStyle())
                            
                            Button {
                                model.sell()
                                amountIsFocused = false
                            } label: {
                                Text("Sell").articleBoldFont().foregroundColor(Color("SellColor"))
                            }.buttonStyle(BorderedButtonStyle())
                            
                            Button {
                                model.close()
                                amountIsFocused = false
                            } label: {
                                Text("Close").articleBoldFont()
                            }.buttonStyle(BorderedButtonStyle()).disabled(model.position == nil)
                            
                            Button {
                                model.revertPosition()
                                amountIsFocused = false
                            } label: {
                                Text("Revert").articleBoldFont()
                            }.buttonStyle(BorderedButtonStyle()).disabled(model.position == nil)
                        }
                        
                    }
                }

            }
        }.navigationTitle(model.symbol)
        
        .onDisappear(perform: {
            model.unload()
        })
        .onAppear(perform: {
            model.load()
        })
        .toast(isPresenting: $model.stageManager.inProgress) {
            AlertToast(displayMode: .alert, type: .loading, title: "Setup chart")
        }
        .toast(isPresenting: $model.orderProcessing) {
            AlertToast(displayMode: .alert, type: .loading, title: "Process order")
        }
        .toast(isPresenting: $model.positionUpdating) {
            AlertToast(displayMode: .alert, type: .loading, title: "Updating")
        }
        .toast(isPresenting: $model.errorEvent) {
            AlertToast(displayMode: .alert, type: .error(.red), title: model.errorEventText)
        }
    }
    

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartTerminalView(model: ChartTerminalViewModel(symbol: "BTCUSDT", position: PositionRisk()))
                .navigationTitle("BTCUSDT")
        }
    }
}
