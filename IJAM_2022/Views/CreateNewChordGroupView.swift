//
//  CreateNewChordGroupView.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/31/22.
//

import SwiftUI

struct Pick: Identifiable  {
    var id: Int
    var title: String
    var image:Image
}


struct PickView: View {
    var pick: Pick
    @EnvironmentObject var iJamVM:IjamViewModel
    @Binding var selectedChordButtonIndex:Int
    @Binding var newChordNames:[String]
    @Binding var tempChordName:String

    var body: some View {
        ZStack() {
            Button(action: {
                // automatically reload picks in ChordButtonsView updating the one selected
                selectedChordButtonIndex    = self.pick.id
                newChordNames[self.pick.id] = tempChordName
            }){
                Image(selectedChordButtonIndex == self.pick.id ? kActivePick : newChordNames[self.pick.id] == kNoChord ? kUndefinedPick : kBlankPick)
                    .resizable()
                    .shadow(radius: 10)
                    .padding(10)
            }
            
            let fontSize = getFontSize(targetString: self.pick.title)
            
            Text(self.pick.id == selectedChordButtonIndex ? tempChordName :
                    newChordNames[self.pick.id] == kNoChord ? "" : newChordNames[self.pick.id])
                .foregroundColor(Color.white)
                .font(.custom("Arial Rounded MT Bold", size: fontSize))
                .onChange(of: tempChordName) { newValue in
                    // reset newChordNames[selectedChordButtonIndex]
                    newChordNames[selectedChordButtonIndex] = tempChordName
                }
        }
    }
}

// BEHAVIOR
//      ON SAVE:
//         set first available chord as activeChord
//          set activeGroupName to our newChordGroupName
//              triggering a recalculation of concerned views
//      ON DISMISS:
//          Set activeChordGroupName back to saved value (or first value?)


struct CreateNewChordGroupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var iJamVM:IjamViewModel
    
    @State private var showingDuplicateChordsAlert  = false
    @State private var showingNotEnoughChordsAlert  = false
    @State private var showingUniqueGroupNameAlert  = false
    @State private var newChordGroupName:String     = ""
    @State private var tempChordName:String         = kNoChord
    @State private var selectedChordButtonIndex:Int = 0
    @State private var newChordNames                = Array(repeating: kNoChord, count: 10)
    private var picks:[Pick] = []
    
    init() {
        for i in 0...9 {
            picks.append(Pick(id:i, title:newChordNames[0], image: Image(kBlankPick)))
            
        }
    }
    
    // Behavior:
    //      the Picker's selected chordName appears in seleted PickButton's Label
    //      tempChordName replaces element at pick.id of newChordNames Array
    //      changing buttons, keeps chordName in old button label
  
    func duplicateChordsFound() -> Bool {
        var answer = false
        
        let actualChordsNameArray = newChordNames.filter { $0 != kNoChord }
        let dups = Dictionary(grouping: actualChordsNameArray, by: {$0}).filter { $1.count > 1 }.keys
        
        if dups.count > 0 {
            answer = true
        }
        
        return answer
    }
    
    let mySpacing:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 36.0 : 12.0
    
    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible())]
    
    var body: some View {
        VStack() {
            Text(kCreateNewGroup).foregroundColor(Color.white)
                .font(.custom("Arial Rounded MT Bold", size: 20.0))
            Spacer()
            HStack() {
                Spacer()
                Text("NAME").foregroundColor(Color.white)
                    .font(.custom("Futura Bold", size: 24.0))
                TextField("", text: $newChordGroupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .background(Color.gray)
                    .labelsHidden()
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing:mySpacing) {
                ForEach(picks, id: \.id) { pick in
                    PickView(pick: pick, selectedChordButtonIndex: $selectedChordButtonIndex, newChordNames:$newChordNames, tempChordName:$tempChordName)
                }
            }
            Spacer()
            Text("SELECT CHORDS").foregroundColor(Color.white)
                .font(.custom("Arial Rounded MT Bold", size: 20.0))
            ChordScrollerView(tempChordName: $tempChordName)
            Spacer()
            HStack() {
                Spacer()
                Button("Cancel") {
                    // chordGroupName was set to "CREATE NEW GROUP"
                    iJamVM.activeChordGroupName = iJamVM.activeChordGroup!.name!
                    dismiss()
                }
                .font(.body)
                .padding()
                .background(.black)
                .cornerRadius(10)
                
                Spacer()
                
                Button("Save") {
                    // 3 conditions for save to be valid
                    //  at least 3 chords defined
                    //  new chord group name not empty
                    //  new chord group name unique
                    if nuberNewDefinedChords() < 3 {
                        showingNotEnoughChordsAlert = true
                    } else if newChordGroupName.count < 1 || groupNameAlreadyExists(name: newChordGroupName) {
                        showingUniqueGroupNameAlert = true
                    } else if duplicateChordsFound() {
                        showingDuplicateChordsAlert = true
                    } else {
                        saveChordGroup()
                        
                        #if DEBUG
                        debugPrint("All conditions met")
                        #endif
                        
                        dismiss()
                    }
                }
                .font(.body)
                .padding()
                .background(.red)
                .cornerRadius(10)
                Spacer()
            }
            Spacer()
        }
        .background(RadialGradient(gradient: Gradient(colors: [.blue, .black]), center: .center, startRadius: 2, endRadius: 650))
        .alert("At least 3 chords are required.", isPresented: $showingNotEnoughChordsAlert, actions: {})
        .alert("Enter unique chord group name.", isPresented: $showingUniqueGroupNameAlert, actions: {})
        .alert("You have duplicate chords selectd.", isPresented: $showingDuplicateChordsAlert, actions: {})
    }
        
    func saveChordGroup() {
        // create and save new chord group as activeChordGroup of activeTuning
        // set first chord as activeChord for activeTuning
        // create new ChordGroup Entity
        let group = ChordGroup(context: viewContext)
        
        group.name                  = newChordGroupName
        group.isActive              = true
        group.availableChordNames   = chordNamesAsDashDelimitedString(chords: newChordNames)
        
        // mark former activeGroup as INACTIVE
        iJamVM.activeChordGroup?.isActive = false
        
        iJamVM.activeTuning!.addToChordGroups(group)
        group.tuning = iJamVM.activeTuning
        
        // setting ChordGroupName BELOW sets activeChordGroup and activeChord in its didSet
        iJamVM.activeChordGroupName = group.name!
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            
            #if DEBUG
            debugPrint( "Data not saved")
            #endif
        }
    }
    
    func chordNamesAsDashDelimitedString(chords:[String]) -> String {
        var chordsString = ""
        
        for chordName in chords {
            chordsString += "\(chordName)-"
        }
        
        return chordsString
    }
    
    
    func groupNameAlreadyExists(name:String) -> Bool {
        var answer = false
        
        for chordGroup in iJamVM.activeTuning!.chordGroups! {
            let thisChordGroup = chordGroup as? ChordGroup
            if thisChordGroup!.name == name {
                answer = true
                break
            }
        }
        
        return answer
    }
    
    func nuberNewDefinedChords() ->Int {
        var numberChords = 0
        
        for name in newChordNames {
            if name != kNoChord && name.count > 0 {
                numberChords += 1
            }
        }
        
        return numberChords
    }
}

struct ChordScrollerView: View {
    @Binding var tempChordName:String
    @EnvironmentObject var iJamVM:IjamViewModel
    
    var body: some View {
        let chords = iJamVM.getActiveTuningsChordNames()
        
        Picker("Chords", selection: $tempChordName) {
            ForEach(chords, id: \.self) {
                Text($0)
            }
        }
        .background(Color.cyan)
        .font(.custom("Arial Rounded MT Bold", size: 20.0))
        .frame(width:200.0)
        .pickerStyle(.wheel)
        .labelsHidden()
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white, lineWidth: 4)
        )
    }
}

struct CreateNewChordGroupView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
        
        CreateNewChordGroupView()
            .environmentObject(IjamViewModel(context: viewContext))
    }
}
