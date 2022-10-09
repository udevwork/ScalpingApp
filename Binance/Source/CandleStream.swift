import Foundation
public struct CandleStream: Codable {
    
    public var data: CandleStream.Data
    
    public struct Data: Codable  {
        public var openTime: Double
        public var closeTime: Double
        public var open: Double
        public var close: Double
        public var high: Double
        public var low: Double
        public var isClosed: Bool
        
        enum CodingKeys: String, CodingKey {
            case openTime = "t"
            case closeTime = "T"
            case open = "o"
            case close = "c"
            case high = "h"
            case low = "l"
            case isClosed = "x"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            openTime = try container.decode(Double.self, forKey: .openTime)
            closeTime = try container.decode(Double.self, forKey: .closeTime)
            open = try Double(container.decode(String.self, forKey: .open))!
            close = try Double(container.decode(String.self, forKey: .close))!
            high = try Double(container.decode(String.self, forKey: .high))!
            low = try Double(container.decode(String.self, forKey: .low))!
            isClosed = try container.decode(Bool.self, forKey: .isClosed)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case data = "k"
    }
    
    public func candle() -> Candle {
       return Candle(candle: self)
    }
    
}
