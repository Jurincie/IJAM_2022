//
//  VolumeView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/29/22.
//

import Foundation
import SwiftUI

struct VolumeView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    @StateObject private var stringsVM = StringsViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
    @State private var isEditing = false
    
    var body: some View {
        VStack() {
            Spacer()
            Spacer()
            HStack {
                Spacer()
                
                // Mute Button
                Button(action: {
                        self.iJamVM.isMuted.toggle()
                    
                        if (self.iJamVM.isMuted) {
                            self.iJamVM.savedVolumeLevel = self.iJamVM.volumeLevel
                            self.iJamVM.volumeLevel = 0.0
                        } else {
                            self.iJamVM.volumeLevel = self.iJamVM.savedVolumeLevel
                        }
                    }) {
                    Image(systemName: self.iJamVM.isMuted ? "speaker.slash.fill" : "speaker.wave.1")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .shadow(radius: 10)
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                
                Slider(value:$iJamVM.volumeLevel, in: 0...100, step: 1,
                    onEditingChanged: { editing in
                        // notify stringsView to change volume on all 6 AudioPlayers
                        
                        if isEditing == false {
                            if iJamVM.isMuted && iJamVM.volumeLevel > 0.0 {
                                iJamVM.isMuted  = false
                                isEditing       = editing
                            }
                        }
                })
                Spacer()
            }
            Spacer()
        }
    }
}

