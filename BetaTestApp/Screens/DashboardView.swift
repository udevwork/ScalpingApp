import SwiftUI
import Combine
import BinanceResponce

class DashboardViewModel: ObservableObject  {
    
    @Published var positions: [String:PositionRisk] = [:]
    @Published var allPositions: [PositionRisk] = []
    @Published var error: String = ""
    private var subscribers: [AnyCancellable] = []
    public var isSceneActive = true
    
    init(){
        fetchData()
    }
    
    public func fetchData(){
        Web.shared.testConnection { [weak self] error in
            if error == nil {
                self?.fetchPosition()
                self?.subscribeToWebsocket()
                self?.fetchAccountData()
                self?.error.removeAll()
            } else {
                self?.error = error?.msg ?? "Error... =("
            }
        }
    }
    
    private func fetchAccountData(){
        if let request = Web.shared.request(.fapi, .get, .futures, .v2, "balance", nil) {
            Web.shared.REST(request, [Balance].self) { responce in
                if let balance = responce.first(where: { $0.asset == "USDT" })?.balance {
                    User.shared.balance = balance
                }
            }
        }
    }
    
    private func fetchPosition(){
        positions.removeAll()
        if let request = Web.shared.request(.fapi ,.get, .futures, .v2, "positionRisk", nil) {
            Web.shared.REST(request, [PositionRisk].self) { responce in
                responce
                    .filter({$0.unRealizedProfit != 0})
                    .forEach { self.positions[$0.symbol] = $0 }
                self.allPositions = responce // save all
            }
        }
    }
    
    private func subscribeToWebsocket(){
        Web.shared.subscribe(.futuresSocket, to: "!ticker@arr", id: 9)
        
        Web.shared.$stream.sink { [weak self] responce in
            DispatchQueue.global().async {
                guard let sSelf = self else { return }
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
    
    private func parsePrices(miniTicker: [MarketMiniTicker]){
        self.positions.forEach { key, value in
            if let price = miniTicker.first(where: {$0.symbol == key})?.price {
                self.positions[key]?.markPrice = price
            }
        }
    }
    
    public func openPositionList() -> [PositionRisk]{
        return positions.filter({ $1.positionAmt != 0.0 }).map({ $1 })
    }
    
}

struct DashboardView: View {
    
    @StateObject var model = DashboardViewModel()
    @EnvironmentObject var settings: BottomNavigationViewController
    
    var body: some View {
        List {
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
                    PositionListExtraItem(position: position).environmentObject(settings)
                }
            }
            
            Section(header: Text("Other").lightFont()) {
                
                MenuItem(iconName: "Zoom_solid", menuName: "Open new chart", destination: {
                    SymbolBrowser(model: SymbolBrowserViewModel(positions: model.allPositions))
                        .environmentObject(settings)
                })
                
                MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                    SettingsView().environmentObject(settings)
                })

            }            
            
        }.onAppear{
            model.isSceneActive = true
            settings.set(screen: .Menu)
        }.onDisappear{
            model.isSceneActive = false
        }
    }
}

struct OpenPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView().environmentObject(BottomNavigationViewController()).navigationTitle("Positions")
        }
    }
}

