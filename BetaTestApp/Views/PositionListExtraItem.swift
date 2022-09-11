import SwiftUI
import BinanceResponce

struct PositionListExtraItem: View {
    @EnvironmentObject var settings: BottomNavigationViewController
    var position: PositionRisk
    
    var body: some View {
        NavigationLink {
            ChartTerminalView(model: ChartTerminalViewModel(symbol: position.symbol, position: position))
                .environmentObject(settings)
        } label: {
            
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    CryptoIcon(symbol: position.symbol)
                    Text(position.symbol).articleBoldFont()
                    Spacer()
                    Text("\(position.markPrice.currency())").articleFont()
                }

                let pnl = Finance.culcPNL(from: position)
                HStack {
                    Text("PNL").articleFont()
                    Text(pnl.currency()).foregroundColor(pnl > 0 ? Color("BuyColor") : Color("SellColor")).articleBoldFont()
                }
            }
            
            
        }
    }
}

struct PositionListExtraItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                PositionListExtraItem(position: PositionRisk()).environmentObject(BottomNavigationViewController())
            }
        }
    }
}
