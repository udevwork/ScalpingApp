import Foundation

public struct SocketResponse: Codable {
    public let result: [String]?
    public let id: Int
    
    public init() {
        self.result = nil
        self.id = 1
    }
}
