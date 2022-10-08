import SwiftUI

struct TimeFramePicker: View {
    
    var selection: Binding<String>
    private let timeframes: [String] = ["1m", "5m", "15m", "1d", "1w", "1M"]
    
    var body: some View {
        Picker("Timeframe", selection: selection) {
            ForEach(timeframes, id: \.self) {
                Text($0).tag($0)
            }
        }
    }
}

struct TimeFramePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimeFramePicker(selection: .constant("1m"))
    }
}
