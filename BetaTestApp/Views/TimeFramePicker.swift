//
//  TimeFramePicker.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 10.09.2022.
//

import SwiftUI

struct TimeFramePicker: View {
    
    var selection: Binding<String>
    
    var body: some View {
        Picker("Timeframe", selection: selection) {
            Text("1m").tag("1m")
            Text("5m").tag("5m")
            Text("15m").tag("15m")
            Text("1d").tag("1d")
            Text("1M").tag("1M")
        }
    }
}

struct TimeFramePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimeFramePicker(selection: .constant("1m"))
    }
}
