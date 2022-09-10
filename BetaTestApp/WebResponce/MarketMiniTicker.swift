import Foundation

struct MarketMiniTicker: Codable
{
    var symbol: String
    var price: Double
    var priceChangePercent: Double
    
    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case price = "c"
        case priceChangePercent = "P"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        price = try Double(container.decode(String.self, forKey: .price)) ?? 0
        priceChangePercent = try Double(container.decode(String.self, forKey: .priceChangePercent)) ?? 0
    }
    
}
