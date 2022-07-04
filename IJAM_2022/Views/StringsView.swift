//
//  StringView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/3/22.
//

// StringsView is responsible for displaying the 6 StringView views
// And obtaining the bounds of each of the strings via their Anchor Preferences

// StringsView moitors a DragGesture's position to track when a string is encountered
// Upon leaving the stringArea causing that string to play the appropriate note on its AudioPlayer

import AVFoundation
import SwiftUI

struct StringsView: View {
    @StateObject private var stringsVM = StringsViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
    @EnvironmentObject var contentVM:ContentViewModel
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint?
    var dragOffset:CGFloat  = 0.0
    var height:CGFloat      = 0.0
    
    var body: some View {
        let tap  = TapGesture()
        let drag = DragGesture(minimumDistance: 0).onChanged { value in
            dragLocation = value.location

            if contentVM.isMuted == false {
                let stringToPlay =  stringsVM.dragTriggersStringToPlay(loc: dragLocation!)
            
                if stringToPlay != -1  && contentVM.fretIndexMap[6 - stringToPlay] != -1 {
                    let noteToPlay = self.stringsVM.noteToPlay(self.contentVM.fretIndexMap, (self.contentVM.activeTuning?.openNoteIndices)!, stringToPlay, self.contentVM.capoPosition)
                    
                    debugPrint("----> string: \(stringToPlay)  plays: \(noteToPlay)")
    
                    self.stringsVM.playGuitar(stringToPlay, noteToPlay, self.contentVM.volumeLevel)
                }
        
            }
        }.sequenced(before: tap)
            .onEnded { _ in
                
                // resetting formerZone to -1 prevents string from being picked on next tap for a drag
                self.stringsVM.formerZone = -1
                
                //debugPrint("---> Drag ended: formerZone reset to -1")
            }
        
        HStack(spacing:0) {
            HStack(spacing:0) {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 6, fretNumber:self.contentVM.fretIndexMap[0]) .readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 6 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                   
                }
                StringView(height:height, stringNumber: 5, fretNumber:self.contentVM.fretIndexMap[1]) .readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 5 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
                StringView(height:height, stringNumber: 4, fretNumber:self.contentVM.fretIndexMap[2]) .readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 4 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
            }
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 3, fretNumber:self.contentVM.fretIndexMap[3]) .readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 3 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
              
                StringView(height:height, stringNumber: 2, fretNumber:self.contentVM.fretIndexMap[4]) .readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 2 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
                StringView(height:height, stringNumber: 1, fretNumber:self.contentVM.fretIndexMap[5]).readFrame { newFrame in
                    if stringsVM.zoneBreaks.count < 1 {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
            }
            
            HStack(spacing:0) {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .gesture(drag)
        .alert("System Volume is OFF", isPresented: $stringsVM.showingAlert, actions: {})
    }
}


