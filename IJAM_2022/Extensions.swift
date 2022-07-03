//
//  Extensions.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/8/22.
//

import Foundation
import CoreData
import SwiftUI

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension NSDictionary {
    // creates a swiftDictionary from contents of Objective-C Dictionary
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()

        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }

        return swiftDictionary
    }
}

extension IjamModel {
    
    func buildTuning(appState:AppState, name:String, openNoteIndices:String, openNotes:String,
                     chordLibrary:String, chordGroups:String) -> Tuning {
        let newTuning               = Tuning(context: context)
        newTuning.name              = name
        newTuning.openNoteIndices   = openNoteIndices
        newTuning.openNoteNames     = openNotes 
        newTuning.isActive          = false
        newTuning.appState          = appState
        
        let chordSet:NSSet = convertToSetOfChords(fileName:chordLibrary, parentTuning: newTuning)
        newTuning.addToChords(chordSet)
        
        let chordGroupSet:NSSet = convertToSetOfChordGroups(fileName: chordGroups, parentTuning: newTuning)
        newTuning.addToChordGroups(chordGroupSet)
    
        return newTuning
    }
    
    func convertToSetOfChords(fileName:String, parentTuning: Tuning) ->NSSet {
        // create a NSMutableSet of Chord managed Objects
        let context = coreDataManager.shared.PersistentStoreController.viewContext
        let set     = NSMutableSet()
        
        if let path = Bundle.main.path(forResource: fileName, ofType: kPlist),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
                for entry in dict{
                    let chord       = Chord(context:context)
                    chord.name      = entry.key
                    chord.fretMap   = entry.value
                    chord.tuning    = parentTuning
                    set.add(chord)
                }
        }
    
        try? context.save()
        
        return set
    }

    func convertToSetOfChordGroups(fileName:String, parentTuning: Tuning) ->NSSet {
        // build NSMutableSet of ChordGroups
        let chordGroupsSet = NSMutableSet()
        
        if let path = Bundle.main.path(forResource: fileName, ofType: kPlist),
            let newChordGroupsDict  = NSDictionary(contentsOfFile: path) as? [String: String] {
            
            for entry in newChordGroupsDict {
                // create new group
                let chordGroup                  = ChordGroup(context: self.context)
                chordGroup.name                 = entry.key
                chordGroup.availableChordNames  = entry.value
                chordGroup.isActive             = false
                chordGroup.tuning               = parentTuning
                
                chordGroupsSet.add(chordGroup)
            }
        }
        
        // assign one group isActive = true
        let activeGroup         = chordGroupsSet.anyObject() as? ChordGroup
        activeGroup?.isActive   = true

        try? context.save()
        
        return chordGroupsSet
    }
    
    func getFirstRealChordName(chordNames:[String]) ->String {
        return chordNames.first{$0 != kNoChord} ?? ""
    }
    
    func selectActiveChord(chordNames:[String], tuning: Tuning) -> Chord {
        let firstRealChordName  = getFirstRealChordName(chordNames:chordNames)
        let activeChord         =  tuning.chords?.first{$0 as! String == firstRealChordName} as? Chord
        
        return activeChord!
    }
}

extension StringView {
    
    func getFretNoteTitle(openNote:String, offset:Int) -> String {
        let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        let index = notes.firstIndex(of:openNote)
        var finalIndex = index! + offset + contentVM.capoPosition
        
        if finalIndex < 0 {
            finalIndex += 12
        }
        
        finalIndex %= 12 // moding forces to fit in range 0...11
        
        return notes[finalIndex]
    }
}

extension ContentViewModel
{
    func getNewActiveChordFrom(group:ChordGroup, tuning:Tuning) -> Chord {
        let chordNames          = group.availableChordNames?.components(separatedBy: ["-"])
        let newActiveChordName  = chordNames?.first{$0 != kNoChord}
        let newActiveChord      = tuning.chords!.first{($0 as! Chord).name == newActiveChordName}
        
        return newActiveChord as! Chord
    }

    func getActiveGroupsChordNames() -> [String] {
        return self.activeChordGroup!.availableChordNames!.components(separatedBy: ["-"])
    }
    
    func getActiveTuningFromName(_ name: String) ->Tuning {
        return (self.appState?.tunings!.first{($0 as? Tuning)!.name == name} as? Tuning)!
    }
    
    func getActiveChordGroupFromName(_ name: String) -> ChordGroup {
        return self.activeTuning!.chordGroups!.first{ name == ($0 as! ChordGroup).name!} as! ChordGroup
    }
    
    func getTuningNames() -> [String] {
        // returns an unsorted array of tuning names
        let unorderedTuningNamesArray = Array(self.appState?.tunings as! Set<Tuning>)
        let namesArray: [String] = unorderedTuningNamesArray.map { $0.name! }
        
        return namesArray
    }
    
    func getActiveTuningsChordNames() -> [String]{
        // returns sorted array of chords available in activeTuning
        var chordNameArray = Array(activeTuning?.chords as! Set<Chord>).map ({ $0.name! })
        chordNameArray.sort()
    
        return chordNameArray
    }
    
    func getChordGroupNames() -> [String] {
        // get chord group names from adtiveTuning's chordGroups
        // then append "NEW CHORD GROUP" to end of array
        let chordGroupdNameArray: [ChordGroup] = Array(activeTuning?.chordGroups as! Set<ChordGroup>).map ({ $0 })

        var namesArray = chordGroupdNameArray.map{$0.name!}
        namesArray.append("CREATE NEW GROUP")
        
        return namesArray
    }
    
    func getMinDisplayedFret(from fretString:String) -> Int {
        var lowest  = 0
        var highest = 0
        var thisFretVal = -1

        for char in fretString {
            switch char {
                // span does NOT include open string nor muted strings
            case "x": thisFretVal = -1
            case "0": thisFretVal = 0
            case "A":
                thisFretVal = 11
            case "B":
                thisFretVal = 12
            case "C":
                thisFretVal = 13
            case "D":
                thisFretVal = 14
            default:
                if let intValue = char.wholeNumberValue {
                    thisFretVal = intValue
                }
            }

            if thisFretVal > highest {
                highest = thisFretVal
            }
        }

        if highest <= 4 {
            lowest = 0
        } else {
            lowest = highest - 5
        }

        return lowest
    }
  
    func getSelectedButtonIndex() ->Int {
        
        let chordNames = getActiveGroupsChordNames()
        
        return chordNames.firstIndex(of: self.activeChord!.name!) ?? 0
    }
    
    // Must acccept both: "xx0212" "9ABCAA" and "320003"
    func getFretFromString(_ string:String) -> Int {
        var returnInt: Int
        
        switch(string) {
            case "x": returnInt = -1
            case "A": returnInt = 10
            case "B": returnInt = 11
            case "C": returnInt = 12
            case "D": returnInt = 13
            case "E": returnInt = 14
            default: returnInt = Int(string)!
        }
        
        return returnInt
    }
    
    func getFretIndexMap() -> [Int] {
        var fretIndexMap:[Int] = []
                        
        for index in 0...5 {
            let fretSymbol:String = self.activeChord!.fretMap![index]
            let index = getFretFromString(fretSymbol)
            
            fretIndexMap.append(index)
        }
        
        return fretIndexMap
    }
    
    func getOpenStringIndicesFrom(tuningsString:String) -> [Int] {
        let splitName = tuningsString.components(separatedBy:"-")
        let openStringindices: [Int] = splitName.map({Int($0)!})

        return openStringindices
    }

    func getAppState() -> AppState {
        var appState:AppState?
        
        let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
        let request     = NSFetchRequest<NSFetchRequestResult>(entityName: "AppState")
    
        do {
            let results:NSArray = try viewContext.fetch(request) as NSArray
            
            for thisAppState in results as! [AppState] {
                 appState = thisAppState
           }
        } catch {
          fatalError("Failed to fetch Tuning: \(error)")
        }
        
        return appState!
    }

    
    func getActiveChordGroupName(tuning:Tuning) -> String {
        // return the first group we find (ONLY called on intial setup)
        let chordGroupArray = Array(tuning.chordGroups!) as! [ChordGroup]
        let chordGroup      = chordGroupArray.first { $0.isActive == true }
        
        return (chordGroup?.name)!
    }
    
    func getActiveTuning() ->Tuning? {
        let appState = getAppState()
        activeTuning = appState.tunings?.first{ (($0) as! Tuning).isActive == true } as? Tuning
        
        return activeTuning
    }
}

extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }

        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }

        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { /*dealing with errors up to the usage*/ }
        }
    }
}

extension View {
  func readFrame(onChange: @escaping (CGRect) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: .global))
      }
    )
    .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
  }
}

