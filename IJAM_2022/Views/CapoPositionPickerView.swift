//
//  CapoPositionPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct CapoPositionPickerView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    
    let frets = [-2,-1,0,1,2,3,4,5]

   var body: some View {
       VStack {
           Menu {
               Picker("Capo Position", selection: $iJamVM.capoPosition) {
                   ForEach(frets, id: \.self) {
                       Text(String($0))
                   }
               }
               .labelsHidden()
               .pickerStyle(.menu)
           } label: {
               Text("\(iJamVM.capoPosition)")
                   .fontWeight(.bold)
                   .font(.title3)
                   .foregroundColor(Color.white)
        
                   
           }
       }
   }
}

//struct CapoPositionPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CapoPositionPickerView()
//    }
//}
