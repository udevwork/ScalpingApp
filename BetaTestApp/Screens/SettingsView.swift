import SwiftUI
import Binance
import SwiftyUserDefaults

class SettingsViewModel: ObservableObject  {
    
    @Published var username: String = ""
    @Published var api: String = ""
    @Published var secret: String = ""
    
    public func save(){
        Defaults.username = self.username
        Defaults.apiKey = self.api
        Defaults.secretKey = self.secret
        Web.shared.setApiKeys(publicKey: self.api, secretKey: self.secret)
    }
    
}


struct SettingsView: View {
    
    @StateObject var model = SettingsViewModel()

    @State private var showingAlert = false
    @State private var showingClearDBAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Hello, \(Defaults.username ?? "trader")")) {
                TextField("Username", text: $model.username)
            }
            
            Section(header: Text("Connect you binance account")) {
                TextField("API", text: $model.api)
                TextField("Secret", text: $model.secret)
            }
            
            Section(header: Text("Other")) {
                Button("Clear DB") {
                    showingClearDBAlert.toggle()
                }.alert("Delete Database?", isPresented: $showingClearDBAlert) {
                    Button("Delete", role: .destructive) { Defaults.removeAll() }
                    Button("Close", role: .cancel) { }
                }
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
            SettingsView()
        }
    }
}
