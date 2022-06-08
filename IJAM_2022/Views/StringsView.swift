//
//  StringView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/3/22.
//

// StringsView is responsible for displaying the 6 StringView views
// And obtaining the bounds of each of the strings via their Anchor Preferences

// StringsView moitors a DragGesture's position to track when a string is encountered
//      A: setting StringImage to ActiveStringImage while drag is over any string
//      B: upon leaving the stringArea causing that string to play the appropriate note on its AudioPlayer

import AVFoundation
import SwiftUI

struct StringsView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint?
    @StateObject private var stringsVM  = StringsViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
    @State private var showingAlert     = false
    let kReduceVolumePct                = 0.50
    var dragOffset:CGFloat              = 0.0
    var height:CGFloat                  = 0.0
    
    var locString : String {
        guard let loc = tapLocation else { return "Tap" }
        return "\(Int(loc.x)), \(Int(loc.y))"
    }
    
    var body: some View {
        let tap  = TapGesture().onEnded { tapLocation = dragLocation }
        let drag = DragGesture(minimumDistance: 0).onChanged { value in
            dragLocation = value.location
        
            // assign zone to location
            let zone = stringsVM.getZone(loc: dragLocation!)

            if zone != stringsVM.formerZone {
                if stringsVM.formerZone % 2  > 0  && iJamVM.isMuted == false {
                    
                    if(AVAudioSession.sharedInstance().outputVolume == 0.0) {
                        // Alert user that their volume is off
                        showingAlert = true
                    }
                    
                    // play correct note for this string
                    let stringToPlay            = 6 - (stringsVM.formerZone / 2) // algebra is cool
                    let thisStringsFretPosition = self.iJamVM.fretIndexMap[6 - stringToPlay]
                    
                    if thisStringsFretPosition > -1 {
                        let openNoteArray:[String]  = self.iJamVM.activeTuning!.openNoteIndices!.components(separatedBy:["-"])
                        let thisStringsOpenIndex    = Int(openNoteArray[6 - stringToPlay])
                        let index                   = thisStringsFretPosition + thisStringsOpenIndex! + self.iJamVM.capoPosition
                        let noteToPlayName          = stringsVM.noteNamesArray[index]
                                                
                        stringsVM.playWaveFile(noteName:noteToPlayName, stringNumber: stringToPlay, volume: iJamVM.volumeLevel * kReduceVolumePct)
                    }
                }
            
                stringsVM.formerZone = zone
            }
        }.sequenced(before: tap)
        
        HStack(spacing:0) {
            HStack(spacing:0) {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 6, fretNumber:self.iJamVM.fretIndexMap[0]) .readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
                StringView(height:height, stringNumber: 5, fretNumber:self.iJamVM.fretIndexMap[1]) .readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
                StringView(height:height, stringNumber: 4, fretNumber:self.iJamVM.fretIndexMap[2]) .readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
            }
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 3, fretNumber:self.iJamVM.fretIndexMap[3]) .readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
              
                StringView(height:height, stringNumber: 2, fretNumber:self.iJamVM.fretIndexMap[4]) .readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
                        stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                        stringsVM.zoneBreaks.append(stringsVM.xPosition)
                        stringsVM.zoneBreaks.sort()
                    }
                }
                StringView(height:height, stringNumber: 1, fretNumber:self.iJamVM.fretIndexMap[5]).readFrame { newFrame in
                    if(stringsVM.zoneBreaks.count <= 6 ) {
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
        .alert("System Volume is OFF", isPresented: $showingAlert, actions: {})
    }
}


