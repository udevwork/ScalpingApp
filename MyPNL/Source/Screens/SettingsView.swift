import SwiftUI
import Binance
import SwiftyUserDefaults

class SettingsViewModel: ObservableObject  {
    
    @Published var username: String = ""
    @Published var api: String = ""
    @Published var secret: String = ""
    @Published var useTestnet: Bool = false
    
    init() {
        self.username = Defaults.username ?? "trader"
        self.api = Defaults.apiKey ?? ""
        self.secret = Defaults.secretKey ?? ""
        self.useTestnet = Defaults.useTestnet ?? false
    }
    
    public func save(){
        Defaults.username = self.username
        Defaults.apiKey = self.api
        Defaults.secretKey = self.secret
        Defaults.useTestnet = self.useTestnet
        Web.shared.setApiKeys(publicKey: self.api, secretKey: self.secret)
        Web.shared.testnet = Defaults.useTestnet ?? false
    }
    
}


struct SettingsView: View {
    
    @StateObject var model = SettingsViewModel()
    
    @State private var showingAlert = false
    @State private var showingClearDBAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                
                VStack(spacing: 0) {
                    HStack {
                        Icon(iconName: "User_solid")
                        TextField("Username", text: $model.username).articleFont()
                    }.menuItemSingleStyle()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Icon(iconName: "Pen_solid")
                        TextField("API", text: $model.api).foregroundColor(.gray).articleFont()
                    }.menuItemTopStyle()
                    
                    HStack {
                        Icon(iconName: "Pen_solid")
                        TextField("Secret", text: $model.secret).foregroundColor(.gray).articleFont()
                    }.menuItemBottomStyle()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Icon(iconName: "Cloud storage_solid")
                        Text("Testnet").articleFont()
                        Toggle("", isOn: $model.useTestnet)
                    }.menuItemSingleStyle()
                
                }
                
                VStack(spacing: 0) {
                    Button(action: {
                        showingClearDBAlert.toggle()
                    }, label: {
                        HStack {
                            Icon(iconName: "Trash_solid").foregroundColor(Color.red)
                            Text("Clear storage").foregroundColor(Color.red).articleFont()
                            Spacer()
                        }
                    }).alert("Clear storage?", isPresented: $showingClearDBAlert) {
                        Button("Delete", role: .destructive) { Defaults.removeAll() }
                        Button("Close", role: .cancel) { }
                    }.menuItemSingleStyle()
                }
                
            }
            
        }.navigationTitle("Settings")
            .toolbar {
                Button {
                    model.save()
                    showingAlert = true
                } label: {
                    Text("Save")
                }.alert("Saved!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            .ScrollViewStyle()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
