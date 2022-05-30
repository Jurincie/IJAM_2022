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
        
        ZStack() {
            Image("HeaderView")
                .resizable()
                .frame(width: width, height: height, alignment: .topLeading)
                .border(Color.gray, width: 4)
            HStack() {
                Spacer()
            
                TuningPickerView()
                    .frame(width: width / 2, height: 40, alignment: .center)
                
                ChordGroupPickerView()
                    .frame(width: width / 2, height: 40, alignment: .center)
               
                Spacer()
            }
        }
    }
}
