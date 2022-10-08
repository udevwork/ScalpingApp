import Foundation
public struct ServerError: Decodable {
    
    public let code: Double
    public let msg: String
    
    public init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        self.code = try values.decode(Double.self)
        self.msg = try values.decode(String.self)
    }
    
    public init(code: Double, msg: String) {
        self.code = code
        self.msg = msg
    }

}
