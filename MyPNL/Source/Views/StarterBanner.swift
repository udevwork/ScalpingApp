//
//  StarterBanner.swift
//  MyPNL
//
//  Created by Denis Kotelnikov on 08.10.2022.
//

import SwiftUI

struct StarterBanner: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack() {
               
                VStack(alignment:.leading) {
                    VStack(alignment:.leading, spacing: 10) {
                        Text("Try our AI for\navoid huge loss!")
                            .foregroundColor(.white)
                            .headerFont()
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Setup account")
                                    .foregroundColor(.black)
                                    .articleBoldFont()
                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            }.background(Color.white).cornerRadius(30)
                        }
                    }.offset(CGSize(width: 20, height: 0))
                }.frame(height: 150)
                Spacer()
            }.background(Color("LightPurple")).cornerRadius(20)
            Image("robot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 220, height: 220)
                .offset(CGSize(width: 10, height: 10))
        }
    }
}

struct StarterBanner_Previews: PreviewProvider {
    static var previews: some View {
        StarterBanner()
    }
}
