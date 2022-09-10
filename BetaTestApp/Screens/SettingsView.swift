//
//  SettingsView.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 03.09.2022.
//

import SwiftUI

import SwiftyUserDefaults

class SettingsViewModel: ObservableObject  {
    
    @Published var username: String = ""
    @Published var api: String = ""
    @Published var secret: String = ""
    
    public func save(){
        Defaults.username = self.username
        Defaults.apiKey = self.api
        Defaults.secretKey = self.secret
    }
    
}


struct SettingsView: View {
    
    @StateObject var model = SettingsViewModel()
    @EnvironmentObject var settings: BottomNavigationViewController

    @State private var showingAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Hello, \(Defaults.username ?? "trader")")) {
                TextField("Username", text: $model.username)
            }
            
            Section(header: Text("Connect you binance account")) {
                TextField("API", text: $model.api)
                TextField("Secret", text: $model.secret)
            }
            
            Button {
                model.save()
                showingAlert = true
            } label: {
                Text("Save")
            }.alert("Saved!", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
            
        }.navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView().environmentObject(BottomNavigationViewController())
        }
    }
}
