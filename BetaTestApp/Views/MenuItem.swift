import SwiftUI

struct MenuItem<Destination>: View where Destination: View  {
    let iconName: String
    let menuName: String
    @ViewBuilder var destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Label {
                Text(menuName).articleBoldFont()
            } icon: {
                Icon(iconName: iconName)
            }
        }
    }
    
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(iconName: "Zoom_solid", menuName: "Search", destination: {})
    }
}
