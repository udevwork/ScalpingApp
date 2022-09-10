import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var username: DefaultsKey<String?> { .init("username") }
    var apiKey: DefaultsKey<String?> { .init("apiKey") }
    var secretKey: DefaultsKey<String?> { .init("secretKey") }
    
    var lastSymbolSearch: DefaultsKey<[String]> { .init("lastSymbolSearch", defaultValue: []) }
    
}
