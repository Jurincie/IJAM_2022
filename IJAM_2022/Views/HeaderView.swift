//
//  HeaderView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/30/22.
//

import SwiftUI


struct HeaderView: View {
    @EnvironmentObject var contentVM:ContentViewModel
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    @State private var selection:String = ""

    var body: some View {
        VStack() {
            HStack() {
                TuningPickerView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
                ChordGroupPickerView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(RadialGradient(gradient: Gradient(colors: [.black, .cyan]), center: .center, startRadius: 2, endRadius: 650))
        
    }
}
