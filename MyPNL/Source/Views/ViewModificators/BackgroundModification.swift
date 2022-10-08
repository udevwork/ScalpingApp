import SwiftUI

extension View {
    func ScrollViewStyle() -> some View {
        modifier(ScrollViewModifier())
    }
}

struct ScrollViewModifier: ViewModifier {
    //@Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea(edges: .all)
            content.padding(.horizontal)//.scrollContentBackground(.hidden)
        }
           
    }
}

struct BackgroundModification_Previews: PreviewProvider {
    
    static var previews: some View {
        
        
        NavigationStack {
   
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
              
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
                    .navigationTitle("BackgroundModification")
                    .ScrollViewStyle()
                
            
            
        }
        
    }
}

