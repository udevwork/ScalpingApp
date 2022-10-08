import SwiftUI
import Combine
import Binance
import AlertToast

class DashboardViewModel: ObservableObject  {
    
    private var subscribers: [AnyCancellable] = []
    
    public var isSceneActive = true
    public var stageManager = DataLodingStageManager(stageCount: 5)
    
    @Published public var positions: [String:PositionRisk] = [:]
    @Published public var allPositions: [PositionRisk] = []
    @Published public var error: String = ""
    @Published public var isLoading: Bool = false
    
    init(){
        fetchData()
        stageManager.$inProgress.assign(to: &$isLoading)
    }
    
    public func fetchData(){
        stageManager.start()
        Web.shared.testConnection { [weak self] error in
            if let error = error {
                self?.stageManager.finishWithError()
                self?.error = error.msg
            } else {
                self?.stageManager.finishStep(name: "test")
                self?.fetchPosition()
                self?.createSocketConnection()
                self?.fetchAccountData()
                self?.error.removeAll()
            }
        }
        
        Web.shared.$socketConnected.sink { [weak self] connected in
            if connected {
                self?.subscribeToTickerStream()
                self?.subscribeToUserStream()
            }
        }.store(in: &subscribers)
    }
    
    private func createSocketConnection(){
        Web.shared.subscribe(.futuresSocket, to: "", id: 0)
    }
    
    private func fetchAccountData(){
        if let request = Web.shared.request(.fapi, .get, .futures, .v2, "balance", nil) {
            
            Web.shared.REST(request, [Balance].self, completion: {  [weak self] responce in
                if let balance = responce.first(where: { $0.asset == "USDT" })?.balance {
                    User.shared.balance = balance
                    self?.stageManager.finishStep(name: "account")
                }
            }, onError: { [weak self] error in
                self?.stageManager.finishWithError()
                self?.error = error.msg
            })
        }
    }
    
    private func fetchPosition(){
        positions.removeAll()
        if let request = Web.shared.request(.fapi ,.get, .futures, .v2, "positionRisk", nil) {
            Web.shared.REST(request, [PositionRisk].self, completion: { [weak self] responce in
                responce
                    .filter({$0.unRealizedProfit != 0})
                    .forEach { self?.positions[$0.symbol] = $0 }
                self?.allPositions = responce // save all
                self?.stageManager.finishStep(name: "position")
            }, onError: { [weak self] error in
                self?.stageManager.finishWithError()
                self?.error = error.msg
            })
        }
    }
    
    private func subscribeToTickerStream(){
        Web.shared.subscribe(.futuresSocket, to: "!ticker@arr", id: 9)
        
        Web.shared.$stream.sink { [weak self] responce in
            DispatchQueue.global().async {
                guard let sSelf = self else { return }
                
                if let socketActionResult = try? decode(SocketResponse.self, from: responce) {
                    if socketActionResult.id == 9 {
                        print("socketActionResult: ", socketActionResult.result as Any, " ID: ", socketActionResult.id)
                        if socketActionResult.result == nil { // sucsess
                            self?.stageManager.finishStep(name: "connect to ticker socket ")
                        }
                    }
                    if socketActionResult.id == 1 {
                        print("socketActionResult: ", socketActionResult.result as Any, " ID: ", socketActionResult.id)
                        if socketActionResult.result == nil { // sucsess
                            self?.stageManager.finishStep(name: "connect to account stream socket")
                        }
                    }
                }
                
                if let update = try? decode(PositionUpdateStream.self, from: responce) {
                    if update.o.x == "FILLED" {
                        print("FILLED")
                        self?.fetchPosition()
                    }
                }
                
                if !sSelf.isSceneActive { return }
                guard let miniTicker = try? decode([MarketMiniTicker].self, from: responce) else {
                    return
                }
                
                DispatchQueue.main.sync {
                    sSelf.parsePrices(miniTicker: miniTicker)
                }
            }
            
            
        }.store(in: &subscribers)
        
    }
    
    private func subscribeToUserStream(){
        if let request = Web.shared.request(.fapi ,.post, .futures, .v1, "listenKey", nil, useTimestamp: false, useSignature: false) {
            Web.shared.REST(request, ListenKey.self, completion: { responce in
                print("listenKey", responce.listenKey)
                Web.shared.subscribe(.futuresSocket, to: responce.listenKey, id: 1)
            }, onError: { error in
                
            })
        }
    }
    
    private func parsePrices(miniTicker: [MarketMiniTicker]){
        self.positions.forEach { key, value in
            if let price = miniTicker.first(where: {$0.symbol == key})?.price {
                self.positions[key]?.markPrice = price
            }
        }
    }
    
    public func openPositionList() -> [PositionRisk]{
        return positions
            .filter({ $1.positionAmt != 0.0 })
            .map({ $1 })
            .sorted { l, r in
                l.unRealizedProfit < r.unRealizedProfit
            }
    }
    
}

struct DashboardView: View {
    
    @StateObject var model = DashboardViewModel()
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                StarterBanner().listRowSeparator(.hidden)
                if model.isLoading == false {
                    if model.error.isEmpty == false {
                        
                        HStack {
                            Text(model.error).articleFont()
                            Spacer()
                            Button {
                                model.fetchData()
                            } label: {
                                Text("Reload").articleBoldFont()
                            }
                        }.menuItemTopStyle()
                        
                        MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                            SettingsView()
                        }).navigationItemModificatorStyle()
                            .menuItemBottomStyle()
                        
                    } else {
                        Text(User.shared.balance.currency()).subtitleFont()
                        Section(header: Text("Open positions").lightFont()) {
                            ForEach(model.openPositionList(), id: \.id) { position in
                                PositionListExtraItem(position: position)
                            }
                        }
                        
                        Section(header: Text("Other").lightFont()) {
                            
                            MenuItem(iconName: "Zoom_solid", menuName: "Open new chart", destination: {
                                SymbolBrowser(model: SymbolBrowserViewModel(positions: model.allPositions))
                                
                            })
                            
                            MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                                SettingsView()
                            })
                            
                        }
                    }
                }
            }
        }.onAppear{
            model.isSceneActive = true
        }.onDisappear{
            model.isSceneActive = false
        }.toast(isPresenting: $model.isLoading) {
            AlertToast(displayMode: .alert, type: .loading, title: "Setup terminal")
        }
        .ScrollViewStyle()
    }
}

struct OpenPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView().navigationTitle("Positions")
        }
    }
}

