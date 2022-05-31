//
//  FretNumbersView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/4/22.
//

import SwiftUI

struct FretNumbersView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
     
    var body: some View {
        
        VStack(spacing:0) {
            
            CapoPositionPickerView()
                .frame(width: width, height: height / 6, alignment: .center)
            
            // next 5 span the chord
            // from minfret to minFret + 4)
            let minFret = iJamVM.getMinDisplayedFret(fretString:self.iJamVM.activeTuning!.activeChord!.fretMap!)
            
            Text(String(iJamVM.capoPosition + minFret + 1))
                .frame(width: width, height: height / 6, alignment: .center)
                .background(Color.blue)
                .foregroundColor(Color.yellow)
                .cornerRadius(5)
            Text(String(iJamVM.capoPosition + minFret + 2))
                .frame(width: width, height: height / 6, alignment: .center)
                .background(Color.blue)
                .foregroundColor(Color.yellow)
                .cornerRadius(5)
            Text(String(iJamVM.capoPosition + minFret + 3))
                .frame(width: width, height: height / 6, alignment: .center)
                .background(Color.blue)
                .foregroundColor(Color.yellow)
                .cornerRadius(5)
            Text(String(iJamVM.capoPosition + minFret + 4))
                .frame(width: width, height: height / 6, alignment: .center)
                .background(Color.blue)
                .foregroundColor(Color.yellow)
                .cornerRadius(5)
            Text(String(iJamVM.capoPosition + minFret + 5))
                .frame(width: width, height: height / 6, alignment: .center)
                .background(Color.blue)
                .foregroundColor(Color.yellow)
                .cornerRadius(5)
        }
    }
}
