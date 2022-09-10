import SwiftUI
import Combine
import SwiftyUserDefaults

class OpenPositionsViewModel: ObservableObject  {
    private var subscribers: [AnyCancellable] = []
    
    @Published var positions: [String:PositionRisk] = [:]
    @Published var allPositions: [PositionRisk] = []
    @Published var lastOpendCharts: [String] = []
    public var isSceneActive = true
    
    var def : DefaultsDisposable? = nil
    
    init(){
        fetchPosition()
        subscribeToWebsocket()
        manageLastOpenedCharts()
    }
    
    private func fetchPosition(){
        positions.removeAll()
        let request = Web.shared.request(.get, .futures, .v2, "positionRisk", Web.shared.timestamp)
        Web.shared.REST(request, [PositionRisk].self) { responce in
            responce
                .filter({$0.unRealizedProfit != 0})
                .forEach { self.positions[$0.symbol] = $0 }
            
            self.allPositions = responce // save all
            
        }
    }
    
    private func subscribeToWebsocket(){
        Web.shared.subscribe(.futures, to: "!ticker@arr", id: 9)
        
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
    
    
    private func manageLastOpenedCharts(){
        self.lastOpendCharts = Defaults.lastSymbolSearch
        self.def = Defaults.observe(\.lastSymbolSearch) { [weak self] update in
            self?.lastOpendCharts = update.newValue ?? []
        }
    }
    
    public func lastSearchList() -> [PositionRisk]{
        return allPositions.filter({ self.lastOpendCharts.contains($0.symbol) })
    }
    
    public func openPositionList() -> [PositionRisk]{
        return positions.filter({ $1.positionAmt != 0.0 }).map({ $1 })
    }
    
}

struct OpenPositionsView: View {
    
    @StateObject var model = OpenPositionsViewModel()
    @EnvironmentObject var settings: BottomNavigationViewController
    
    var body: some View {
        List {
            
            Section(header: Text("Open positions").lightFont()) {
                ForEach(model.openPositionList(), id: \.id) { position in
                    PositionListExtraItem(position: position).environmentObject(settings)
                }
            }
            
            Section(header: Text("Other").lightFont()) {
                
                MenuItem(iconName: "Open new chart", menuName: "Zoom_solid", destination: {
                    SymbolBrowser(model: SymbolBrowserViewModel(positions: model.allPositions))
                        .environmentObject(settings)
                })
                MenuItem(iconName: "Settings", menuName: "Settings_solid", destination: {
                    SettingsView().environmentObject(settings)
                })

            }
            
            Section(header: Text("Last opened charts").lightFont()) {
                ForEach(model.lastSearchList(), id: \.id) { position in
                    PositionListSimpleItem(position: position)
                }
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
            OpenPositionsView().environmentObject(BottomNavigationViewController()).navigationTitle("Positions")
        }
    }
}

