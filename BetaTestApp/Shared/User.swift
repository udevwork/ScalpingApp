import Foundation
import SwiftyUserDefaults

public class User: ObservableObject {
    
    public static var shared: User = User()
    
    @Published var balance: Double = 0.0
    @Published var publicKey: String = ""
    @Published var secretKey: String = ""
    
    private init(){
        if let publicKey = Defaults.apiKey, let secretKey = Defaults.secretKey {
            self.publicKey = publicKey
            self.secretKey = secretKey
        }
    }
    
}
