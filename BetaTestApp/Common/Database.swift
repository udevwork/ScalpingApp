import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    
    // User
    var username: DefaultsKey<String?> { .init("username") }
    var apiKey: DefaultsKey<String?> { .init("apiKey") }
    var secretKey: DefaultsKey<String?> { .init("secretKey") }

    // Common data
    var lastSymbolSearch: DefaultsKey<[String]> { .init("lastSymbolSearch", defaultValue: []) }
    
}

// Helper
extension DefaultsKeys {
    /**
     Saves the name of the currency that we have opened for viewing.
     Stores only 5 values, the new value gets to the top of the list.
     */
    public static func saveOpened(_ symbol: String) {
        if !Defaults.lastSymbolSearch.contains(symbol){
            if Defaults.lastSymbolSearch.count >= 5 {
                Defaults.lastSymbolSearch.removeLast()
            }
            Defaults.lastSymbolSearch.insert(symbol, at: 0)
        }
    }
}
