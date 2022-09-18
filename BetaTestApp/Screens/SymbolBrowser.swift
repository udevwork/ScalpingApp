import SwiftUI
import BinanceResponce
import SwiftyUserDefaults

class SymbolBrowserViewModel: ObservableObject  {
    @Published var positions: [PositionRisk] = []
    var def : DefaultsDisposable? = nil
    @Published var lastOpendCharts: [String] = []
    @Published var searchText = ""
    
    init(positions: [PositionRisk]) {
        self.positions = positions
        manageLastOpenedCharts()
    }
    
    private func manageLastOpenedCharts(){
        self.lastOpendCharts = Defaults.lastSymbolSearch
        self.def = Defaults.observe(\.lastSymbolSearch) { [weak self] update in
            DispatchQueue.main.async {
                self?.lastOpendCharts = update.newValue ?? []
            }
        }
        
    }
    
    public func lastSearchList() -> [PositionRisk]{
        return positions.filter({
            self.lastOpendCharts.contains($0.symbol)
        })
    }
    
    public func searchList() -> [PositionRisk]{
        return Array(positions.filter({
            let symbol = $0.symbol.lowercased()
            let result = symbol.contains(searchText.lowercased()) && symbol.contains("usdt")
            return result
        }).prefix(7))
    }
}

struct SymbolBrowser: View {
    
    @StateObject var model: SymbolBrowserViewModel
    
    var body: some View {
        List() {
            if model.searchText.isEmpty == false {
                ForEach(model.searchList()) {
                    PositionListSimpleItem(position: $0)
                }
            } else {
                Section("Last search") {
                    ForEach(model.lastSearchList()) {
                        PositionListSimpleItem(position: $0)
                    }
                }
            }
         
        }.searchable(text: $model.searchText)
            .navigationTitle("Open chart")
    }
}



struct SymbolBrowser_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SymbolBrowser(model: SymbolBrowserViewModel(positions: [PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk()]))
        }
    }
}
