import SwiftUI

struct Icon: View {
    var iconName: String
    
    var body: some View {
        Image(iconName).resizable().frame(width: 16, height: 16)
    }
}

struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        Icon(iconName: "Zoom_solid")
    }
}
