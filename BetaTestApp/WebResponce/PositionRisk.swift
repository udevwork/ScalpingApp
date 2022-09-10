import Foundation

struct PositionRisk: Codable, Identifiable {
    
    var id = UUID().uuidString
    
    var entryPrice: Double
    var marginType: String
    var isolatedMargin: Double
    var leverage: Int
    var liquidationPrice: Double
    var markPrice: Double
    var maxNotionalValue: Double
    var positionAmt: Double
    var symbol: String
    var unRealizedProfit: Double
    
    var positionSide: PositionSide {
        get {
            return positionAmt > 0 ? .Long : .Short
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case entryPrice = "entryPrice"
        case marginType = "marginType"
        case isolatedMargin = "isolatedMargin"
        case leverage = "leverage"
        case liquidationPrice = "liquidationPrice"
        case markPrice = "markPrice"
        case maxNotionalValue = "maxNotionalValue"
        case positionAmt = "positionAmt"
        case symbol = "symbol"
        case unRealizedProfit = "unRealizedProfit"
//        case positionSide = "positionSide"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entryPrice = try Double(container.decode(String.self, forKey: .entryPrice)) ?? 0
        marginType = try container.decode(String.self, forKey: .marginType)
        isolatedMargin = try Double(container.decode(String.self, forKey: .isolatedMargin)) ?? 0
        leverage = try Int(container.decode(String.self, forKey: .leverage)) ?? 0
        liquidationPrice = try Double(container.decode(String.self, forKey: .liquidationPrice)) ?? 0
        markPrice = try Double(container.decode(String.self, forKey: .markPrice)) ?? 0
        maxNotionalValue = try Double(container.decode(String.self, forKey: .maxNotionalValue)) ?? 0
        positionAmt = try Double(container.decode(String.self, forKey: .positionAmt)) ?? 0
        symbol = try container.decode(String.self, forKey: .symbol)
        unRealizedProfit = try Double(container.decode(String.self, forKey: .unRealizedProfit)) ?? 0
 //       positionSide = try container.decode(String.self, forKey: .positionSide)
    }
    
    init() {
        entryPrice = 10400.0
        marginType = "isolated"
        isolatedMargin = 100.0
        leverage = 10
        liquidationPrice = 9000.0
        markPrice = 10000.0
        maxNotionalValue = 0
        positionAmt = 10
        symbol = "BTCUSDT"
        unRealizedProfit = 145.0
    }
    
}
