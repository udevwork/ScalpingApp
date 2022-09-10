import Foundation

class Finance {
    
    static func culcPNL(positionSide: PositionSide, entryPrice: Double, markPrice: Double, positionAmt: Double) -> Double {
        if positionSide == .Long {
            return (markPrice - entryPrice) * positionAmt
        } else if positionSide == .Short {
            return (entryPrice - markPrice) * positionAmt
        }
        return 0
    }
    
    static func culcPNL(from position: PositionRisk) -> Double {
        if position.positionSide == .Long {
            return (position.markPrice - position.entryPrice) * position.positionAmt
        } else if position.positionSide == .Short {
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
    
}
