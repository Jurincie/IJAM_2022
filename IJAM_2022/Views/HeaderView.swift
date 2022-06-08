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
                    .frame(width: width / 3, height: 40, alignment: .center)
                
                ChordGroupPickerView()
                    .frame(width: width / 3, height: 40, alignment: .center)
               
                Spacer()
            }
            Spacer()
        }
        .frame(width: width, height: 80.0, alignment:.topLeading)
        .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 650))
        
    }
}
