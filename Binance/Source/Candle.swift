import Foundation
public struct Candle: Decodable, Identifiable {
    
    public var id = UUID().uuidString
    
    public let openTime: Double
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: String
    public let closeTime: Double
    
    public init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        self.openTime = try values.decode(Double.self)
        self.open = try Double(values.decode(String.self))!
        self.high = try Double(values.decode(String.self))!
        self.low = try Double(values.decode(String.self))!
        self.close = try Double(values.decode(String.self))!
        self.volume = try values.decode(String.self)
        self.closeTime = try values.decode(Double.self)
    }
    
    public init(candle: CandleStream) {
        self.openTime = candle.data.openTime
        self.open = candle.data.open
        self.high = candle.data.high
        self.low = candle.data.low
        self.close =  candle.data.close
        self.volume = ""
        self.closeTime = candle.data.closeTime
    }
    
    /**
     init with mock data
     */
    public init() {
        self.openTime = 1
        self.open = 4
        self.high = 6
        self.low = 1
        self.close = 2
        self.volume = ""
        self.closeTime = 2
    }
    
}
