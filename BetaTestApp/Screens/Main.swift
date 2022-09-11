//
//  BetaTestAppApp.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 12.08.2022.
//

import SwiftUI

@main
struct Main: App {
    
    init() {
        Web.shared.setApiKeys(publicKey: User.shared.publicKey, secretKey: User.shared.secretKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

struct AppView: View {
    
    @StateObject var navController = BottomNavigationViewController()
    
    init() {
         UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Nunito-ExtraBold", size: 25)!]
     }
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            NavigationStack {
                DashboardView().environmentObject(navController)
            }
            .background(Color.red)
            .cornerRadius(30)
            .padding(EdgeInsets(top: -60, leading: 0, bottom: 0, trailing: 0))
            
            BottomNavigationView()
                .offset(CGSize(width: 0, height: 10))
                .environmentObject(navController)
            
        }.background(Color.black)
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
