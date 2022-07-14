//
//  ChordGroupPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct ChordGroupPickerView: View {
    @EnvironmentObject var contentVM:MainViewModel
    @State private var showingNewGroupSheet = false
    @State private var newChordGroupName:String?

   var body: some View {
       Menu {
           Picker(kChordGroups, selection: $contentVM.activeChordGroupName) {
               ForEach(contentVM.getChordGroupNames(), id: \.self) {
                   Text($0)
               }
           }
           
           .labelsHidden()
           .pickerStyle(.menu)
       } label: {
           Text("\(contentVM.activeChordGroup!.name!)")
               .onChange(of: contentVM.activeChordGroupName) { newValue in
                   if contentVM.activeChordGroupName == kCreateNewGroup {
                       // set this to launch NewChordGroupView
                       showingNewGroupSheet = true
                    }
               }
               .font(.body)
               .padding(5.0)
               .overlay(
                    RoundedRectangle(cornerRadius: 10)
                   .stroke(Color.white, lineWidth:1)
               )
               .foregroundColor(Color.white)
            }.sheet(isPresented: $showingNewGroupSheet) {
            
            CreateNewChordGroupView()
       }
   }
}

