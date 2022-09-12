import SwiftUI
import Combine
import SwiftyUserDefaults
import BinanceResponce

class ChartTerminalViewModel: ObservableObject {
    
    static var min:Double = 0.0
    static var max:Double = 0.0
    
    var isChartLoading: Bool = false
    
    var lastRecivedStreamCandle: CandleStream? = nil
    
    @Published var candles: [Candle] = []
    @Published var price: Double = 0.0
    @Published var pnl: Double = 0.0
    
    private let socketID: Int = 10
    
    private var subscribers: [AnyCancellable] = []
    
    public var symbol: String
    public var position: PositionRisk?
    
    var timeframe = "1m"
    
    init(symbol: String, position: PositionRisk?) {
        self.symbol = symbol
        self.position = position
        
        price = position?.markPrice ?? 0.0
        pnl = position?.unRealizedProfit ?? 0.0
        
        if !Defaults.lastSymbolSearch.contains(symbol){
            if Defaults.lastSymbolSearch.count >= 5 {
                Defaults.lastSymbolSearch.removeLast()
            }
            Defaults.lastSymbolSearch.insert(symbol, at: 0)
        }
    }
    
    
    public func load() {
        isChartLoading = true
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
    
    private func fetchCandles(){

        if let request = Web.shared.request(.fapi ,.get, .futures, .v1, "klines", [.init(name: "symbol", value: symbol.uppercased()), .init(name: "interval", value: timeframe),.init(name: "limit", value: "20")], useSignature: false) {
            Web.shared.REST(request, [Candle].self) { responce in
                responce.forEach { self.setMaxMin(candle: $0) }
                self.candles = responce
                self.isChartLoading = false
            }
        }
    }
    
    private func subscribeToWebscoket(){
        let socketURL = "\(symbol.lowercased())@kline_\(timeframe)"
        Web.shared.subscribe(.futuresSocket, to: socketURL, id: socketID)
        
        Web.shared.$stream.sink { [weak self] in
            
            if let socketActionResult = try? decode(SocketResponse.self, from: $0) {
                if socketActionResult.id == self?.socketID {
                    print("socketActionResult: ", socketActionResult.result as Any, " ID: ", socketActionResult.id)
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
    

    func setMaxMin(candle: Candle) {
        if ChartTerminalViewModel.max < candle.high { ChartTerminalViewModel.max = candle.high }
        if ChartTerminalViewModel.min == 0 { ChartTerminalViewModel.min = candle.low }
        if ChartTerminalViewModel.min > candle.low { ChartTerminalViewModel.min = candle.low }
    }
    
}

struct ChartTerminalView: View {
    
    @EnvironmentObject var settings: BottomNavigationViewController
    @StateObject var model: ChartTerminalViewModel
    @State var timeframe = "1m"
    
    var body: some View {
        VStack {
            List {
                Section {
                    if let pos = model.position, model.pnl < 0  {
                        HStack {
                            Text("PNL ")
                            Text("\(model.pnl.currency())").foregroundColor(model.pnl > 0 ? .green : .red).bold()
                            Spacer()
                            Text("% ")
                            Text(Finance.calcPriceChangePercentage(currentPrice: model.price, entryPrice: pos.entryPrice) ).foregroundColor(model.pnl > 0 ? .green : .red).bold()
                        }
                    } else {
                        Text("No position")
                    }

                }
                Section(header: Text("Chart \(timeframe)")) {
                    Text(model.price.currency())
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

            }
        }.navigationTitle(model.position?.symbol ?? "")
        
        .onDisappear(perform: {
            model.unload()
        })
        .onAppear(perform: {
            model.load()
            settings.set(screen: .Trade)
        })
    }
    

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChartTerminalView(model: ChartTerminalViewModel(symbol: "BTCUSDT", position: PositionRisk()))
                .environmentObject(BottomNavigationViewController())
                .navigationTitle("BTCUSDT")
        }
    }
}
