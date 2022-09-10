//
//  MenuItem.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 10.09.2022.
//

import SwiftUI

struct MenuItem<Destination>: View where Destination: View  {
    
    let iconName: String
    let menuName: String
    @ViewBuilder var destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Label {
                Text("Open new chart").articleBoldFont()
            } icon: {
                Icon(iconName: "Zoom_solid")
            }
        }
    }
    
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(iconName: "Zoom_solid", menuName: "Search", destination: {})
    }
}
