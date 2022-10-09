import SwiftUI
import Binance
import SwiftyUserDefaults

@main
struct Main: App {
    
    init() {
        Web.shared.setApiKeys(publicKey: User.shared.publicKey, secretKey: User.shared.secretKey)
        Web.shared.testnet = Defaults.useTestnet ?? false
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

struct AppView: View {
    
    
    init() {
         UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Nunito-ExtraBold", size: 25)!]
     }
    
    var body: some View {
            NavigationStack {
                DashboardView().navigationTitle("Dashboard")
            }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
