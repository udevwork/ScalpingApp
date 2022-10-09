import Foundation

public struct MarketMiniTicker: Codable
{
    public var symbol: String
    public var price: Double
    public var priceChangePercent: Double
    
    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case price = "c"
        case priceChangePercent = "P"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        price = try Double(container.decode(String.self, forKey: .price)) ?? 0
        priceChangePercent = try Double(container.decode(String.self, forKey: .priceChangePercent)) ?? 0
    }
    
}
