//
//  FretNumbersView.swift
//  iJam 2022
//
//  Created by Ron :: on 5/4/22.
//

import SwiftUI

struct FretNumbersView: View {
    @EnvironmentObject var contentVM:ContentViewModel
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
     
    var body: some View {
        VStack(spacing:0) {
            
            CapoPositionPickerView()
                .frame(width: width, height: height / 6, alignment: .center)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 48))
                .border(.white, width:3)
                .cornerRadius(5)
            
            // next 5 span the chord
            // from minfret to minFret + 4)
            let minFret = contentVM.getMinDisplayedFret(from: self.contentVM.activeChord!.fretMap!)
            
            Text(String(contentVM.capoPosition + minFret + 1))
                .frame(width: width, height: height / 6, alignment: .center)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 100))
            Text(String(contentVM.capoPosition + minFret + 2))
                .frame(width: width, height: height / 6, alignment: .center)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 100))
            Text(String(contentVM.capoPosition + minFret + 3))
                .frame(width: width, height: height / 6, alignment: .center)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 100))
            Text(String(contentVM.capoPosition + minFret + 4))
                .frame(width: width, height: height / 6, alignment: .center)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 100))
            Text(String(contentVM.capoPosition + minFret + 5))
                .frame(width: width, height: height / 6, alignment: .center)
                .foregroundColor(Color.white)
                .cornerRadius(5)
                .background(RadialGradient(gradient: Gradient(colors: [.black, .gray]), center: .center, startRadius: 2, endRadius: 100))
        }
    }
}
