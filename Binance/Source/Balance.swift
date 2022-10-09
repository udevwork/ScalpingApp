import Foundation

public struct Balance: Codable, Identifiable {
    
    public var id = UUID().uuidString
    
    public var accountAlias: String    // unique account code
    public var asset: String
    public var balance: Double
    public var maxWithdrawAmount: Double
    public var crossWalletBalance: Double
    public var crossUnPnl: Double
    public var availableBalance:Double
    
    enum CodingKeys: String, CodingKey {
        case accountAlias = "accountAlias"
        case asset = "asset"
        case balance = "balance"
        case maxWithdrawAmount = "maxWithdrawAmount"
        case crossWalletBalance = "crossWalletBalance"
        case crossUnPnl = "crossUnPnl"
        case availableBalance = "availableBalance"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountAlias = try container.decode(String.self, forKey: .accountAlias)
        asset = try container.decode(String.self, forKey: .asset)
        balance = try Double(container.decode(String.self, forKey: .balance)) ?? 0
        maxWithdrawAmount = try Double(container.decode(String.self, forKey: .maxWithdrawAmount)) ?? 0
        crossWalletBalance = try Double(container.decode(String.self, forKey: .crossWalletBalance)) ?? 0
        crossUnPnl = try Double(container.decode(String.self, forKey: .crossUnPnl)) ?? 0
        availableBalance = try Double(container.decode(String.self, forKey: .availableBalance)) ?? 0
    }
    
    /**
     init with mock data
     */
    public init() {
        accountAlias = "qwerty"
        asset = "BTCUSDT"
        balance = 10.0
        maxWithdrawAmount = 100.0
        crossWalletBalance = 80.0
        crossUnPnl = 134.5
        availableBalance = 130.0
    }
    
}
