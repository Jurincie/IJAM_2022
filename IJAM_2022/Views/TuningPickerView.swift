//
//  TuningPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/18/22.
//

import SwiftUI

struct TuningPickerView: View {
    @EnvironmentObject var contentVM:ContentViewModel

   var body: some View {
       let tuningNames:[String] = contentVM.getTuningNames()
      
       VStack {
           Menu {
               Picker("Tunings", selection: $contentVM.activeTuningName) {
                   ForEach(tuningNames, id: \.self) {
                       Text($0)
                   }
               }
               .labelsHidden()
               .pickerStyle(.menu)
           } label: {
               Text(contentVM.activeTuning!.name!)
                   .foregroundColor(Color.white)
                   .font(.body)
                   .padding(5.0)
                   .overlay(RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.white, lineWidth:1))
           }
       }
   }
}


struct TuningPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TuningPickerView()
    }
}
