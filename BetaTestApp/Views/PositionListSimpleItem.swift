//
//  PositionListItem.swift
//  BetaTestApp
//
//  Created by Denis Kotelnikov on 02.09.2022.
//

import SwiftUI

struct PositionListSimpleItem: View {
    var position: PositionRisk
    @EnvironmentObject var settings: BottomNavigationViewController

    var body: some View {
        NavigationLink {
            ChartTerminalView(model: .init(symbol: position.symbol, position: position))
                .environmentObject(settings)
        } label: {
            Label {
                VStack(alignment: .leading) {
                    Text(position.symbol).articleFont()
                }
            } icon: {
                CryptoIcon(symbol: position.symbol)
            }
            
        }
    }
}

struct PositionListItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                PositionListSimpleItem(position: PositionRisk()).environmentObject(BottomNavigationViewController())
            }
        }
    }
}
