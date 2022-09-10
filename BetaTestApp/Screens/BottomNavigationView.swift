//
//  BottomNavigationView.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 04.09.2022.
//

import SwiftUI

class BottomNavigationViewController: ObservableObject {
    
    init() {
        print("settings init")
    }
    
    enum Screens: Int {
        case Connection
        case Trade
        case Menu
        case Tip
    }
    
    @Published var screen: Screens = .Connection
    
    func set(screen: Screens){
        self.screen = screen
        print("set:", screen)
    }

}

struct BottomNavigationView: View {
    
    @EnvironmentObject var settings: BottomNavigationViewController
    
    var body: some View {
        HStack {
                        
            if settings.screen == .Connection {
                ConnectionIndicatorView()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            } else if settings.screen == .Trade {
                TradeIndicatorView()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            } else if settings.screen == .Menu {
                NavigationMenuView()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            } else {
                ConnectionIndicatorView()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
            }

        }
        .frame(height: 80)
    }
}

struct TradeIndicatorView: View {
    var body: some View {
        HStack {
            Spacer()
            Button {
                
            } label: {
                Text("Buy")
                    .bold()
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 15, leading: 40, bottom: 15, trailing: 40))
            }.background(Color("BuyColor"))
                .cornerRadius(20)
            Spacer()
            Button {
                
            } label: {
                Text("Sell")
                    .bold()
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 15, leading: 40, bottom: 15, trailing: 40))
            }.background(Color("SellColor"))
                .cornerRadius(20)
            Spacer()
        }
    }
}

struct NavigationMenuView: View {
    var body: some View {
        HStack(alignment:.center, spacing: 50) {
           
            Image(systemName: "externaldrive.fill.badge.icloud")
   
            Image(systemName: "terminal")

            Image(systemName: "text.book.closed")

            Image(systemName: "arrowshape.turn.up.right")

        }.foregroundColor(.white)
    }
}

struct ConnectionIndicatorView: View {
    var body: some View {
        HStack {
            Circle().frame(width: 10, height: 10).foregroundColor(.yellow)
            Text("Conntection").foregroundColor(.white)
        }
    }
}

struct BottomNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
