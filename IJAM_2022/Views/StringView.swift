//
//  StringView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/5/22.
//

import Foundation
import SwiftUI

// StringView has 2 layers:
//  bottom layer: appropriate string image
//  top layer:  VStack() of 6 possibly-RedBall images evenly spaced over top half of the stringsView

struct StringView: View {
    @EnvironmentObject var iJamVM:IjamViewModel
        var height:CGFloat
        var stringImageName:String
        var stringNumber:Int
        
        init(height: CGFloat, stringNumber:Int, fretNumber:Int) {
            self.height             = height
            self.stringNumber       = stringNumber
            self.stringImageName    = "String"
            stringImageName.append("\(stringNumber)")
        }
        
    var body: some View {
        let openNotesString = (iJamVM.activeTuning?.openNoteNames!)!
        let openNotes:[String] = openNotesString.components(separatedBy: ["-"])
        
        let openStringNote = openNotes[6 - stringNumber]
        
        let minFret = iJamVM.getMinDisplayedFret(fretString: iJamVM.activeChord!.fretMap!)
        
        let fretBoxes:[FretBox] = [
            FretBox(id: 0, title: self.iJamVM.fretIndexMap[6 - stringNumber] == -1 ? "X" : getFretNoteTitle(openNote: openStringNote, offset: 0)),
            FretBox(id: minFret + 1, title: getFretNoteTitle(openNote: openStringNote, offset: 1 + minFret)),
            FretBox(id: minFret + 2, title: getFretNoteTitle(openNote: openStringNote, offset: 2 + minFret)),
            FretBox(id: minFret + 3, title: getFretNoteTitle(openNote: openStringNote, offset: 3 + minFret)),
            FretBox(id: minFret + 4, title: getFretNoteTitle(openNote: openStringNote, offset: 4 + minFret)),
            FretBox(id: minFret + 5, title: getFretNoteTitle(openNote: openStringNote, offset: 5 + minFret))]
        
        
        ZStack() {
            
                                    // BOTTOM layer //
            Image(stringImageName)
                .resizable()
                .frame(width:20, height:height, alignment:.topLeading)
                .opacity(self.iJamVM.fretIndexMap[6 - stringNumber] == -1 ? 0.3 : 1.0)
            
                                    // 2ND layer //
            // 1x6 grid of Buttons with noteName in text on top of the possible image
            // zero or one of the buttons may show the redBall image indicating string if fretted there
            VStack(spacing:0) {
                FretBoxView(fretBox: fretBoxes[0], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[1], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[2], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[3], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[4], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[5], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                
                Spacer()
            }
        }
    }
    
    struct FretBox: Identifiable  {
        var id: Int
        var title: String
    }
    
    struct FretBoxView: View {
        var fretBox: FretBox
        var stringNumber:Int
        @EnvironmentObject var iJamVM:IjamViewModel

        var body: some View {
            let minFret = iJamVM.getMinDisplayedFret(fretString:self.iJamVM.activeTuning!.activeChord!.fretMap!)

            ZStack() {
                Button(action:{
                    if(self.iJamVM.fretIndexMap[6 - stringNumber] == 0 && self.fretBox.id == 0){
                        self.iJamVM.fretIndexMap[6 - stringNumber] = -1
                    } else if(self.iJamVM.fretIndexMap[6 - stringNumber] == self.fretBox.id + minFret && self.fretBox.id > 0) {
                        self.iJamVM.fretIndexMap[6 - stringNumber] = 0
                    } else {
                        self.iJamVM.fretIndexMap[6 - stringNumber] = self.fretBox.id
                    }
                    try? coreDataManager.shared.PersistentStoreController.viewContext.save()
                }){
                    // show a white peg on zeroFret and redBall on freted fretBox

                    if(self.fretBox.id == 0)
                    {
                        Image("Peg")
                            .resizable()
                    } else {
                        Image(self.iJamVM.fretIndexMap[6 - stringNumber] == self.fretBox.id + minFret ? "Redball" : "")
                            .resizable()
                    }
                }
                // show fretZero note names AND a possibly fretted fretBox
                self.fretBox.id + minFret == self.iJamVM.fretIndexMap[6 - stringNumber] || self.fretBox.id == 0 ? Text(self.fretBox.title) : Text("")
                    .foregroundColor(Color.white)
                    .font(.custom("Arial Rounded MT Bold", size: 18.0))
            }
        }
    }
}

