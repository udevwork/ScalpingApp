import Foundation
import BinanceResponce

class Finance {
    
    static func culcPNL(from position: PositionRisk) -> Double {
        if Finance.positionSide(of: position) == .Long {
            return (position.markPrice - position.entryPrice) * position.positionAmt
        } else if Finance.positionSide(of: position) == .Short {
            return (position.entryPrice - position.markPrice) * position.positionAmt
        }
        return 0
    }
    
    static func calcPriceChangePercentage(currentPrice: Double, entryPrice: Double) -> String {
        let inPercent = ((currentPrice - entryPrice)/currentPrice)*100
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = numberFormatter.string(from: NSNumber(value: inPercent))
        return number ?? "0"
    }
 
    static func positionSide(of position: PositionRisk) -> PositionSide{
        return position.positionAmt > 0 ? .Long : .Short
    }
    
}
