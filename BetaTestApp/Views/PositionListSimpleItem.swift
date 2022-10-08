import SwiftUI
import Binance

struct PositionListSimpleItem: View {
    
    var position: PositionRisk

    var body: some View {
        NavigationLink {
            ChartTerminalView(model: .init(symbol: position.symbol, position: position))
        } label: {
            Label {
                VStack(alignment: .leading) {
                    Text(position.symbol).articleFont()
                }
            } icon: {
                CryptoIcon(symbol: position.symbol)
            }
            
        }
    }
}

struct PositionListItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                PositionListSimpleItem(position: PositionRisk())
            }
        }
    }
}
