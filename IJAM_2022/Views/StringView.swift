//
//  StringView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/5/22.
//

import SwiftUI

// StringView has 2 layers:
//  bottom layer: appropriate string image
//  top layer:  VStack() of 6 possibly-RedBall images evenly spaced over top half of the stringsView


struct StringView: View {
    @EnvironmentObject var contentVM:MainViewModel
    @State private var stringVibrating = false
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
        let openNotesString     = (contentVM.activeTuning?.openNoteNames!)!
        let openNotes:[String]  = openNotesString.components(separatedBy: ["-"])
        let openStringNote      = openNotes[6 - stringNumber]
        let minFret             = contentVM.getMinDisplayedFret(from: contentVM.activeChord!.fretMap!)
        
        let fretBoxes:[FretBox] = [
            FretBox(id: 0, title: self.contentVM.fretIndexMap[6 - stringNumber] == -1 ? "X" : getFretNoteTitle(openNote: openStringNote, offset: 0)),
            FretBox(id: minFret + 1, title: getFretNoteTitle(openNote: openStringNote, offset: 1 + minFret)),
            FretBox(id: minFret + 2, title: getFretNoteTitle(openNote: openStringNote, offset: 2 + minFret)),
            FretBox(id: minFret + 3, title: getFretNoteTitle(openNote: openStringNote, offset: 3 + minFret)),
            FretBox(id: minFret + 4, title: getFretNoteTitle(openNote: openStringNote, offset: 4 + minFret)),
            FretBox(id: minFret + 5, title: getFretNoteTitle(openNote: openStringNote, offset: 5 + minFret))]
        
        ZStack() {
            // BOTTOM layer //
    
            let imageName = stringVibrating ? stringImageName + "Active" : stringImageName
            
            Image(imageName)
                .resizable()
                .frame(width:20, height:height, alignment:.topLeading)
                .opacity(self.contentVM.fretIndexMap[6 - stringNumber] == -1 ? 0.5 : 1.0)
                                
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
        @EnvironmentObject var contentVM:MainViewModel
        @Environment(\.managedObjectContext) private var viewContext

        var body: some View {
            let minFret = contentVM.getMinDisplayedFret(from:self.contentVM.activeChord!.fretMap!)
            
            // When fret is tapped:
            //  if that fret was already pressed -> remove press to show open string active
            //  if open fret tapped -> make string inactive (-1)
            //  if string is inactive and open string is tapped -> show open string
            //  if fret is tapped that is NOT active, make it active and make old fret inactive

            ZStack() {
                Button(action:{
                    if(self.contentVM.fretIndexMap[6 - stringNumber] == 0 && self.fretBox.id == 0) {
                        self.contentVM.fretIndexMap[6 - stringNumber] = -1
                    } else if(self.contentVM.fretIndexMap[6 - stringNumber] == self.fretBox.id + minFret && self.fretBox.id > 0) {
                        self.contentVM.fretIndexMap[6 - stringNumber] = 0
                    } else {
                        self.contentVM.fretIndexMap[6 - stringNumber] = self.fretBox.id
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        viewContext.rollback()
                        
                        debugPrint( "Data not saved")
                    }
                }){
                    // show a white peg on zeroFret and redBall on freted fretBox
                    if(self.fretBox.id == 0) {
                        Image("Peg")
                            .resizable()
                            .colorInvert()
                    } else {
                        Image("Redball")
                            .resizable()
                            .opacity(self.contentVM.fretIndexMap[6 - stringNumber] == self.fretBox.id ? 1.0 : 0.0)
                    }
                }
                // show fretZero note names AND a POSSIVLE fretted fretBox
                self.fretBox.id == self.contentVM.fretIndexMap[6 - stringNumber] || self.fretBox.id == 0 ? Text(self.fretBox.title).foregroundColor(Color.white)  : Text("").foregroundColor(Color.white) 
                    .font(.custom("Futura Bold", size: 18.0))
            }
        }
    }
}

