import Foundation
public struct ServerError: Decodable {
    
    public let code: Int
    public let msg: String
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case msg = "msg"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(Int.self, forKey: .code)
        self.msg = try container.decode(String.self, forKey: .msg)
    }
    
    public init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }

}
