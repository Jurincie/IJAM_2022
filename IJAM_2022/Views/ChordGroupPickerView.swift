//
//  ChordGroupPickerView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct ChordGroupPickerView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    
    @State private var showingNewGroupSheet = false
    @State private var newChordGroupName:String?

    
   var body: some View {
       Menu {
           Picker("Chord Groups", selection: $iJamVM.activeChordGroupName) {
               ForEach(iJamVM.getChordGroupNames(), id: \.self) {
                   Text($0).swipeActions {
                       Button {
                           debugPrint("Delete")
                       } label: {
                          Label("Delete", systemImage: "trash")
                       }
                       .tint(.red)
                  }
               }
           }
           
           .labelsHidden()
           .pickerStyle(.menu)
       } label: {
           Text("\(iJamVM.activeChordGroup!.name!)")
               .onChange(of: iJamVM.activeChordGroupName) { newValue in
                   if iJamVM.activeChordGroupName == "CREATE NEW GROUP" {
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

