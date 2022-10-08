import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct cornerRadiusModificator_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    StarterBanner()
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    }).menuItemBottomStyle()
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    }).menuItemBottomStyle()
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    }).menuItemBottomStyle()
                }
            }
            .navigationTitle("Dashboard")
            .ScrollViewStyle()
        }
    }
}
