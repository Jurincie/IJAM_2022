//
//  ChordButtonsView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

func getFontSize(targetString:String) -> Double {
    var fontSize:Double = UIDevice.current.userInterfaceIdiom == .pad ? 28.0 : 22.0
    
    if targetString.count >= 5 {
        fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 14.0 : 11.0
    }
    else if targetString.count == 4 {
        fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18.0 : 14.0
    }else if targetString.count == 3 {
        fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 16.0
    } else {
        fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 24.0 : 18.0

    }
    
    return fontSize
}

struct ChordButtonsView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
    var width:CGFloat   = 0.0
    var height:CGFloat  = 0.0

    
    let mySpacing:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 36.0 : 12.0
    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible())]
        
    var body: some View {
        let chordNames:[String] = self.iJamVM.getAvailableChordNames()
        
        let boxes = [Box(id: 0, title: chordNames[0], image:Image("BlankPick")),
                      Box(id: 1, title: chordNames[1], image:Image("BlankPick")),
                      Box(id: 2, title: chordNames[2], image:Image("BlankPick")),
                      Box(id: 3, title: chordNames.count < 4 ? "" :chordNames[3], image:Image("BlankPick")),
                      Box(id: 4, title: chordNames.count < 5 ? "" :chordNames[4], image:Image("BlankPick")),
                      Box(id: 5, title: chordNames.count < 6 ? "" :chordNames[5], image:Image("BlankPick")),
                      Box(id: 6, title: chordNames.count < 7 ? "" :chordNames[6], image:Image("BlankPick")),
                      Box(id: 7, title: chordNames.count < 8 ? "" :chordNames[7], image:Image("BlankPick")),
                      Box(id: 8, title: chordNames.count < 9 ? "" :chordNames[8], image:Image("BlankPick")),
                      Box(id: 9, title: chordNames.count < 10 ? "" :chordNames[9], image:Image("BlankPick"))]
                
        LazyVGrid(columns: columns, spacing:mySpacing) {
                ForEach(boxes, id: \.id) { box in
                    BoxView(box: box)
            }
        }
    }
        
    struct Box: Identifiable  {
        var id: Int
        var title: String
        var image:Image
    }
    
    struct BoxView: View {
        var box: Box
        @EnvironmentObject var iJamVM:IjamViewModel
        @Environment(\.managedObjectContext) private var viewContext

        var body: some View {
            ZStack() {
                Button(action: {
                    // automatically reload picks in ChordButtonsView updating the one selected
                    if self.box.title != "No Chord" && self.box.title != "" {
                        self.iJamVM.selectedChordBtn = self.box.id
                        
                        // set activeTuning.activeChord and fretMapIndex
                        let chordNames = self.iJamVM.activeChordGroup?.availableChordNames!.components(separatedBy: ["-"])
                        let newActiveChordName = chordNames![self.box.id]
                        let newActiveChord = self.iJamVM.getChordWithName(name: newActiveChordName, tuning: self.iJamVM.activeTuning!)
                        self.iJamVM.activeChord! = newActiveChord
                        self.iJamVM.fretIndexMap = self.iJamVM.getFretIndexMap()
                      
                        do {
                            try viewContext.save()
                        } catch {
                            viewContext.rollback()
                            debugPrint( "Data not saved")
                        }
                        
                    }
                }){
                    Image(iJamVM.selectedChordBtn == self.box.id ? "ActivePick" : self.box.title == "No Chord" || self.box.title == "" ? "UndefinedPick" : "BlankPick")
                        .resizable()
                        .shadow(radius: 10)
                        .padding(10)
                }
                
                let fontSize = getFontSize(targetString: self.box.title)
                
                Text(self.box.title == "No Chord" || self.box.title == "" ? "" : self.box.title)
                    .foregroundColor(Color.white)
                    .font(.custom("Arial Rounded MT Bold", size: fontSize))
            }
        }
    }
}

