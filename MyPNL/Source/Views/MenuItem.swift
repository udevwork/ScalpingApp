import SwiftUI

struct MenuItem<Destination>: View where Destination: View  {
    
    let iconName: String
    let menuName: String
    
    @ViewBuilder var destination: () -> Destination
    
    var body: some View {
        HStack {
            NavigationLink(destination: destination) {
                HStack(spacing: 15) {
                    Icon(iconName: iconName)
                    Text(menuName).articleBoldFont()
                }

            }
            Spacer()
        }
    }
    
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(iconName: "Zoom_solid", menuName: "Search", destination: {})
    }
}
