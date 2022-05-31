//
//  VolumeView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/29/22.
//

import SwiftUI

struct VolumeView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    @State private var isEditing = false
    
    var body: some View {
        VStack() {
            Spacer()
            Spacer()
            HStack {
                Spacer()
                
                // FIX: set button size and slider size dynamically
                Button(action: {
                    self.iJamVM.isMuted.toggle()
                   
                    if (self.iJamVM.isMuted) {
                        // save volume level and set to zero
                        self.iJamVM.savedVolumeLevel    = self.iJamVM.volumeLevel
                        self.iJamVM.volumeLevel         = 0.0
                    }
                    else {
                        // restore volume level
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
                
                Slider(
                    value: $iJamVM.volumeLevel,
                    in: 0...100,
                    onEditingChanged: { editing in
                        isEditing = editing
                        
                        if isEditing == false {
                            saveContext()
                        }
                    })
                
                Spacer()
            }
            Spacer()
        }
    }
}

