//
//  MenuItemModificator.swift
//  MyPNL
//
//  Created by Denis Kotelnikov on 08.10.2022.
//

import SwiftUI

extension View {
    func menuItemTopStyle() -> some View {
        modifier(MenuItemStyle(corners: [.topLeft, .topRight]))
    }
    func menuItemCenterStyle() -> some View {
        modifier(MenuItemStyle(corners: []))
    }
    func menuItemBottomStyle() -> some View {
        modifier(MenuItemStyle(corners: [.bottomLeft, .bottomRight]))
    }
    func menuItemSingleStyle() -> some View {
        modifier(MenuItemStyle(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight]))
    }
}

struct MenuItemStyle: ViewModifier {
    var corners: UIRectCorner
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            .background(Color("ContrastColor"))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .cornerRadius(12, corners: corners)
    }
}

struct MenuItemStyleModificator_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationStack {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    StarterBanner()
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    }).menuItemTopStyle()
                    Divider().background(Color("LightGray"))
                    MenuItem(iconName: "Settings_solid", menuName: "Settings", destination: {
                        SettingsView()
                    }).menuItemCenterStyle()
                    Divider().background(Color("LightGray"))
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
