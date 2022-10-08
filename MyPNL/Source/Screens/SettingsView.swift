import SwiftUI
import Binance
import SwiftyUserDefaults

class SettingsViewModel: ObservableObject  {
    
    @Published var username: String = ""
    @Published var api: String = ""
    @Published var secret: String = ""
    
    init() {
        self.username = Defaults.username ?? "trader"
        self.api = Defaults.apiKey ?? ""
        self.secret = Defaults.secretKey ?? ""
    }
    
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
        ScrollView {
            VStack(spacing: 10) {
                
                VStack(spacing: 0) {
                    HStack {
                        Icon(iconName: "User_solid")
                        TextField("Username", text: $model.username)
                    }.menuItemSingleStyle()
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Icon(iconName: "Pen_solid").foregroundColor(.gray)
                        TextField("API", text: $model.api).foregroundColor(.gray)
                    }.menuItemTopStyle()
                    
                    HStack {
                        Icon(iconName: "Pen_solid")
                        TextField("Secret", text: $model.secret).foregroundColor(.gray)
                    }.menuItemBottomStyle()
                }
                
                VStack(spacing: 0) {
                    Button(action: {
                        showingClearDBAlert.toggle()
                    }, label: {
                        HStack {
                            Icon(iconName: "Trash_solid").foregroundColor(Color.red)
                            Text("Clear storage").foregroundColor(Color.red)
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
