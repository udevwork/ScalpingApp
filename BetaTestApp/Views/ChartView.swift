import SwiftUI
import Charts
import Binance

struct ChartView: View {
    
    var candles: [Candle]
    var position: PositionRisk?
    
    var body: some View {
        Chart() {
            ForEach(candles) { candle in
                
                RectangleMark(x: .value("Day", candle.id),
                              yStart: .value("low", candle.low),
                              yEnd: .value("high", candle.high),
                              width: 2)
                .foregroundStyle(candle.open > candle.close ? Color("SellColor") : Color("BuyColor"))
                .opacity(0.5)
                .cornerRadius(1)
                
                RectangleMark(x: .value("Day", candle.id),
                              yStart: .value("open", candle.open),
                              yEnd: .value("close", candle.close),
                              width: 8)
                .foregroundStyle(candle.open > candle.close ? Color("SellColor") : Color("BuyColor"))
                .cornerRadius(4)
            }
            if let last = candles.last {
                RuleMark(y: .value("price", last.close))
                
                if let position = position,
                   let entryPrice = position.entryPrice,
                   entryPrice > ChartTerminalViewModel.min,
                   entryPrice < ChartTerminalViewModel.max {
                    RuleMark(y: .value("entryPrice", entryPrice)).foregroundStyle(position.positionAmt < 0 ? Color.red : Color.green)
                }
                
            }
        }.chartYScale(domain: ChartTerminalViewModel.min ... ChartTerminalViewModel.max)
            .chartXAxis(.hidden)
            .padding(.horizontal, 20)
            .frame(height: 300)
    }
}

struct CandleBodyView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(candles: [Candle(),Candle(),Candle(),Candle()], position: nil)
    }
}
