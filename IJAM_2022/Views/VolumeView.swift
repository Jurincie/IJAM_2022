//
//  VolumeView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/29/22.
//

import Foundation
import SwiftUI

struct VolumeView: View {
    @EnvironmentObject var contentVM:ContentViewModel
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
                        self.contentVM.isMuted.toggle()
                    
                        if (self.contentVM.isMuted) {
                            self.contentVM.savedVolumeLevel = self.contentVM.volumeLevel
                            self.contentVM.volumeLevel = 0.0
                            
                            // strings muted by playing "NoNote.wav on all string's AudioPlayers
                            stringsVM.muteAllAudio()
                        } else {
                            self.contentVM.volumeLevel = self.contentVM.savedVolumeLevel
                        }
                    }) {
                    Image(systemName: self.contentVM.isMuted ? "speaker.slash.fill" : "speaker.wave.1")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .shadow(radius: 10)
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                
                Slider(value:$contentVM.volumeLevel, in: 0...100, step: 1,
                    onEditingChanged: { editing in
                        // notify stringsView to change volume on all 6 AudioPlayers
                        
                        if isEditing == false {
                            if contentVM.isMuted && contentVM.volumeLevel > 0.0 {
                                contentVM.isMuted  = false
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

