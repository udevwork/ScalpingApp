import SwiftUI

class SymbolBrowserViewModel: ObservableObject  {
    @Published var positions: [PositionRisk] = []
    
    init(positions: [PositionRisk]) {
        self.positions = positions
    }
}

struct SymbolBrowser: View {
    
    @StateObject var model: SymbolBrowserViewModel
    @EnvironmentObject var settings: BottomNavigationViewController
    @State var searchText = ""
    
    var body: some View {
        List(model.positions.filter({ $0.symbol.lowercased().contains(searchText.lowercased())  })) { position in
            
            
            PositionListSimpleItem(position: position)
                .environmentObject(settings)
            }.searchable(text: $searchText)
            .navigationTitle("Open chart")
            .onAppear(perform: {
                settings.set(screen: .Connection)
            })
        
    }
}



struct SymbolBrowser_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SymbolBrowser(model: SymbolBrowserViewModel(positions: [PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk(),PositionRisk()]))
                .environmentObject(BottomNavigationViewController())
        }
    }
}
