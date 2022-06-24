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
    
    @StateObject private var stringsVM = StringsViewModel(context:coreDataManager.shared.PersistentStoreController.viewContext)
    var dragOffset:CGFloat  = 0.0
    var height:CGFloat      = 0.0
    
    var locString : String {
        guard let loc = tapLocation else { return "Tap" }
        return "\(Int(loc.x)), \(Int(loc.y))"
    }
    
    var body: some View {
        let tap  = TapGesture().onEnded { tapLocation = dragLocation }
        let drag = DragGesture(minimumDistance: 0).onChanged { value in
            dragLocation = value.location

            if iJamVM.isMuted == false {
                if stringsVM.dragsNewPositionTriggersPlay(loc: dragLocation!){
                    
                    self.stringsVM.pickString(fretIndexMap: self.iJamVM.fretIndexMap, openNoteIndices: (self.iJamVM.activeTuning?.openNoteIndices)!, capoPosition: self.iJamVM.capoPosition, volumeLevel: self.iJamVM.volumeLevel)
                }
            }
        }.sequenced(before: tap)
            .onEnded { _ in self.stringsVM.formerZone = -1
                
                #if DEBUG
                debugPrint("---> Drag ended: formerZone reset to -1")
                #endif
            }
        
        HStack(spacing:0) {
            HStack(spacing:0) {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 6, fretNumber:self.iJamVM.fretIndexMap[0]) .readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
                }
                StringView(height:height, stringNumber: 5, fretNumber:self.iJamVM.fretIndexMap[1]) .readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
                }
                StringView(height:height, stringNumber: 4, fretNumber:self.iJamVM.fretIndexMap[2]) .readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
                }
            }
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 3, fretNumber:self.iJamVM.fretIndexMap[3]) .readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
                }
              
                StringView(height:height, stringNumber: 2, fretNumber:self.iJamVM.fretIndexMap[4]) .readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
                }
                StringView(height:height, stringNumber: 1, fretNumber:self.iJamVM.fretIndexMap[5]).readFrame { newFrame in
                    stringsVM.xPosition = (newFrame.maxX + newFrame.minX) / 2 - 5 - dragOffset
                    stringsVM.zoneBreaks.append(stringsVM.xPosition)
                    stringsVM.zoneBreaks.sort()
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


