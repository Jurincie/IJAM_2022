//
//  TuningPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/18/22.
//

import SwiftUI

struct TuningPickerView: View {
    @EnvironmentObject var iJamVM:IjamViewModel

   var body: some View {
       let tuningNames:[String] = iJamVM.getTuningNames()
      
       VStack {
           Menu {
               Picker("Tunings", selection: $iJamVM.activeTuningName) {
                   ForEach(tuningNames, id: \.self) {
                       Text($0)
                   }
               }
               .labelsHidden()
               .pickerStyle(.menu)
           } label: {
               Text("\(iJamVM.activeTuning!.name!)")
                   .font(.title3)
                   .fontWeight(.bold)
                   .overlay(
                        RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.black, lineWidth:1)
                   )
                   .padding(2.0)
                   .foregroundColor(Color.white)
                   .padding(10)
           }
       }
   }
}


struct TuningPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TuningPickerView()
    }
}
