import SwiftUI

extension View {
    func navigationItemModificatorStyle() -> some View {
        modifier(NavigationItemModificatorModifier())
    }
}

struct NavigationItemModificatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image("Arrow1_solid")
                .resizable()
                .frame(width: 10, height: 12)
                .foregroundColor(.gray)
        }
           
    }
}

struct NavigationItemModificator_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    })
                    .navigationItemModificatorStyle()
                    .menuItemSingleStyle()
    
                }
            }
            .navigationTitle("BackgroundModification")
            .ScrollViewStyle()
        }
    }
}

