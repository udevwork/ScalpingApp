import SwiftUI
import Combine
import BinanceResponce
import AlertToast

class DashboardViewModel: ObservableObject  {
    
    @Published var positions: [String:PositionRisk] = [:]
    @Published var allPositions: [PositionRisk] = []
    @Published var error: String = ""
    private var subscribers: [AnyCancellable] = []
    public var isSceneActive = true
    
    @Published public var stageManager = DataLodingStageManager(stageCount: 5)
    
    init(){
        fetchData()
    }
    
    public func fetchData(){
        stageManager.start()
        Web.shared.testConnection { [weak self] error in
            if error == nil {
                self?.stageManager.finishStep()
                self?.fetchPosition()
                self?.subscribeToWebsocket()
                self?.subscribeToUserStream()
                self?.fetchAccountData()
                self?.error.removeAll()
            } else {
                self?.error = error?.msg ?? "Error... =("
            }
        }
    }
    
    private func fetchAccountData(){
        if let request = Web.shared.request(.fapi, .get, .futures, .v2, "balance", nil) {
            Web.shared.REST(request, [Balance].self) { [weak self] responce in
                if let balance = responce.first(where: { $0.asset == "USDT" })?.balance {
                    User.shared.balance = balance
                    self?.stageManager.finishStep()
                }
            }
        }
    }
    
    private func fetchPosition(){
        positions.removeAll()
        if let request = Web.shared.request(.fapi ,.get, .futures, .v2, "positionRisk", nil) {
            Web.shared.REST(request, [PositionRisk].self) { [weak self] responce in
                responce
                    .filter({$0.unRealizedProfit != 0})
                    .forEach { self?.positions[$0.symbol] = $0 }
                self?.allPositions = responce // save all
                self?.stageManager.finishStep()
            }
        }
    }
    
    private func subscribeToWebsocket(){
        Web.shared.subscribe(.futuresSocket, to: "!ticker@arr", id: 9)
        
        Web.shared.$stream.sink { [weak self] responce in
            DispatchQueue.global().async {
                guard let sSelf = self else { return }
                
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
        self.stageManager.finishStep()
    }
    
    private func subscribeToUserStream(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            if let request = Web.shared.request(.fapi ,.post, .futures, .v1, "listenKey", nil, useTimestamp: false, useSignature: false) {
                Web.shared.REST(request, ListenKey.self) { [weak self] responce in
                    print("listenKey", responce.listenKey)
                    Web.shared.subscribe(.futuresSocket, to: responce.listenKey, id: 1)
                    self?.stageManager.finishStep()
                }
            }
        })
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
        List {
            if model.stageManager.inProgress == false {
                if model.error.isEmpty == false {
                    HStack {
                        Text(model.error).articleFont()
                        Spacer()
                        Button {
                            model.fetchData()
                        } label: {
                            Text("Reload").articleBoldFont()
                        }
                        
                    }
                }
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
        }.onAppear{
            model.isSceneActive = true
        }.onDisappear{
            model.isSceneActive = false
        }.toast(isPresenting: $model.stageManager.inProgress) {
            AlertToast(displayMode: .alert, type: .loading, title: "Setup terminal")
        }
    }
}

struct OpenPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView().navigationTitle("Positions")
        }
    }
}

