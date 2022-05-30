//
//  ChordGroupPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct ChordGroupPickerView: View {
    @EnvironmentObject var iJamVM:IjamViewModel

   var body: some View {
       let chordGroupsNames:[String] = iJamVM.getChordGroupNames()
      
       VStack {
           Menu {
               Picker("Chord Groups", selection: $iJamVM.activeChordGroupName) {
                   ForEach(chordGroupsNames, id: \.self) {
                       Text($0)
                   }
               }
               .labelsHidden()
               .pickerStyle(.menu)
           } label: {
               Text("\(iJamVM.activeChordGroup!.name!)")
                   .font(.title3)
                   .fontWeight(.bold)
                   .overlay(
                        RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.black, lineWidth:1)
                   )
                   .padding(2.0)
                   .foregroundColor(Color.white)
           }
       }
   }
}

