//
//  CryptoIcon.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 10.09.2022.
//

import SwiftUI

struct CryptoIcon: View {
    
    var symbol: String
    
    var body: some View {
        let iconName = symbol.lowercased().replacingOccurrences(of: "usdt", with: "")
        Image(iconName).resizable().frame(width: 20, height: 20).foregroundColor(.black)
    }
}

struct CryptoIcon_Previews: PreviewProvider {
    static var previews: some View {
        CryptoIcon(symbol: "BTCUSDT")
    }
}
