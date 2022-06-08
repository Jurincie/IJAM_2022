//
//  TopView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct TopView: View {

     var width:CGFloat = 0.0
     var height:CGFloat = 0.0
    
    var body: some View {
        ZStack() {
            Image("TopView")
                .resizable()
                .frame(width: width, height: height, alignment: .topLeading)
            
            ChordButtonsView()
                .frame(width: width, height: height, alignment: .center)
        }
    }
}
