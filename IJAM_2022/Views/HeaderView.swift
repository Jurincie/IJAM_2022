//
//  HeaderView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/30/22.
//

import SwiftUI


struct HeaderView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    @State private var selection:String = ""

    var body: some View {
        VStack() {
            Spacer()
            HStack() {
                Spacer()
            
                TuningPickerView()
                    .frame(minWidth: width / 4, idealWidth: width / 3, maxWidth: width / 2.5, minHeight: 40.0, idealHeight: 45.0, maxHeight: 50.0, alignment: .topLeading)
                
                ChordGroupPickerView()
                    .frame(minWidth: width / 4, idealWidth: width / 3, maxWidth: width / 2.5, minHeight: 40.0, idealHeight: 45.0, maxHeight: 50.0, alignment: .topLeading)
               
                Spacer()
            }
            Spacer()
        }
        .frame(width: width, height: 80.0, alignment:.topLeading)
        .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 650))
        
    }
}
