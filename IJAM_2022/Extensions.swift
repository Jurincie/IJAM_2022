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
    
    func convertToSetOfChords(dict: Dictionary<String,String>, parentTuning: Tuning) ->NSSet {
        // create a NSMutableSet of Chord managed Objects
        let context = coreDataManager.shared.PersistentStoreController.viewContext
        let set     = NSMutableSet()
        
        for entry in dict{
            let chord       = Chord(context:context)
            chord.name      = entry.key
            chord.fretMap   = entry.value
            chord.tuning    = parentTuning
            set.add(chord)
        }
    
        try? context.save()
        
        return set
    }

    func convertToSetOfChordGroups(dict: Dictionary<String,String>, parentTuning: Tuning) ->NSSet {
        // build NSMutableSet of ChordGroups
        let chordGroupsSet = NSMutableSet()

        for entry in dict {
            // create new group
            let chordGroup                  = ChordGroup(context: self.context)
            chordGroup.name                 = entry.key
            chordGroup.availableChordNames  = entry.value
            chordGroup.isActive             = false
            chordGroup.tuning               = parentTuning
            
            chordGroupsSet.add(chordGroup)
        }
        
        // assign one group isActive = true
        let activeGroup = chordGroupsSet.anyObject() as? ChordGroup
        activeGroup?.isActive = true
        
        // the ACTIVE chordGroup needs to set it's parentTuning.activeChord
        let activeChordName = activeGroup?.availableChordNames![0]
        
        for chord in parentTuning.chords! {
            let thisChord = chord as! Chord
             
            if thisChord.name == activeChordName {
                parentTuning.activeChord = thisChord
                break
            }
        }

        try? context.save()
        
        return chordGroupsSet
    }
    
    func selectActiveChord(chordNames:[String], tuning: Tuning) -> Chord {
        var activeChord:Chord?
        let firstChordName = chordNames[0]
        
        for chord in tuning.chords! {
            let thisChord = chord as! Chord
            if thisChord.name == firstChordName {
                activeChord = thisChord
                break
            }
        }
        
        return activeChord!
    }
}

extension StringView {
    
    func getFretNoteTitle(openNote:String, offset:Int) -> String {
        let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        let index = notes.firstIndex(of:openNote)
        var finalIndex = index! + offset + iJamVM.capoPosition
        
        if finalIndex < 0 {
            finalIndex += 12
        }
            
        finalIndex %= 12
        
        return notes[finalIndex]
    }
}

extension IjamViewModel
{
    
    func getNewActiveChordFrom(group:ChordGroup, tuning:Tuning) -> Chord {
        var newActiveChord:Chord?
        let newActiveChordName = group.availableChordNames?.components(separatedBy: ["-"])[0]
        
        for chord in tuning.chords! {
            let thisChord = chord as? Chord
            
            if newActiveChordName == thisChord!.name {
                newActiveChord = thisChord
                break
            }
        }
        
        return newActiveChord!
    }
    
    func getChordWithName(name:String, tuning: Tuning) -> Chord {
        var thisChord:Chord?
        
        for chord in tuning.chords! {
            let testChord = chord as? Chord
            if testChord!.name! == name {
                thisChord = testChord
                break
            }
        }
        
        return thisChord!
    }
    
    func getAvailableChordNames() -> [String] {
        return self.activeChordGroup!.availableChordNames!.components(separatedBy: ["-"])
    }
    func getActiveTuningFromName(name: String) ->Tuning {
        var thisTuning:Tuning?
        
        for tuning in self.appState!.tunings! {
            let tun = tuning as! Tuning
            
            if tun.name == name {
                thisTuning = tun
                break
            }
        }
        
        return thisTuning!
    }
    
    func getActiveChordGroupFromName(name: String) ->ChordGroup {
        var thisChordGroup:ChordGroup?
        
        for chordGroup in self.activeTuning!.chordGroups! {
            let cg = chordGroup as! ChordGroup
            
            if cg.name == name {
                thisChordGroup = cg
                break
            }
        }
        
        return thisChordGroup!
    }
    
    func getTuningNames() -> [String] {
        var namesArray:[String] = []

        for tunings in self.appState!.tunings! {
            let tuning = tunings as! Tuning
            namesArray.append(tuning.name!)
        }
        
        return namesArray
    }
    
    func getChordGroupNames() -> [String] {
        var namesArray:[String] = []

        for chordGroup in self.activeTuning!.chordGroups! {
            let cg = chordGroup as! ChordGroup
            namesArray.append(cg.name!)
        }
        
        return namesArray
    }
    
    func getMinDisplayedFret(fretString:String) -> Int {
        var lowest      = 0
        var highest     = 0
        var thisFretVal = 0

        for char in fretString {
            switch char {
                // span does NOT include open string nor muted strings
            case "x":
                break
            case "0":
                break
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
        var index = 0
        let activeChordName = self.activeTuning!.activeChord!.name
        
        let chordNames = getAvailableChordNames()
       
        for name in chordNames {
            if name == activeChordName {
                break
            }
            
            index += 1
        }
        
        return index
    }
    
    // Must acccept both: "xx0212" "9ABCAA" and "320003"
    func getFretFromString(string:String) -> Int {
        var returnInt = -1
        
        if string == "x" {
            returnInt = -1
        } else if string == "A" {
            returnInt = 10
        } else if string == "B" {
            returnInt = 11
        } else if string == "C" {
            returnInt = 12
        } else {
            returnInt = Int(string)!
        }
        
        return returnInt
    }
    
    func getFretIndexMap() -> [Int] {
        var fretIndexMap:[Int] = []
                
        for index in 0...5 {
            let fretSymbol:String = self.activeTuning!.activeChord!.fretMap![index]
            let index = getFretFromString(string: fretSymbol)
            
            fretIndexMap.append(index)
        }
        
        return fretIndexMap
    }
    
    func getOpenStringIndicesFrom(tuningString:String) -> [Int] {
        var openStringIndices   = [Int]()
        let splitName           = tuningString.components(separatedBy:"-")

        for component in splitName{
            let index = Int(component)
            openStringIndices.append(index!)
        }

        return openStringIndices
    }

    func getAppState() -> AppState {
        var thisAppState:AppState?
        
        let moc     = coreDataManager.shared.PersistentStoreController.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppState")
    
        do {
            let results:NSArray = try moc.fetch(request) as NSArray
            
            for appState in results as! [AppState] {
                thisAppState = appState
           }
        } catch {
          fatalError("Failed to fetch Tuning: \(error)")
        }
        
        return thisAppState!
    }
    
    func getActiveChordGroup(tuning:Tuning) -> ChordGroup? {
        // return the first group we find
        // ONLY run at setup
        let chordGroupSet = tuning.chordGroups!
        let chordGroupArray = Array(chordGroupSet) as! [ChordGroup]
        
        for chordGroup in chordGroupArray {
            return chordGroup
        }
        
        return nil
    }
    
    func getActiveTuning() ->Tuning? {
        let moc     = coreDataManager.shared.PersistentStoreController.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppState")
        
        var activeTuning: Tuning?

        do {
            let results:NSArray =  try moc.fetch(request) as NSArray
            
            for appState in results as! [AppState] {
                
                for tuning in appState.tunings! {
                    let thisTuning = tuning as? Tuning
                    if thisTuning!.isActive {
                        activeTuning = thisTuning
                        break
                    }
                }
            }
        } catch {
          fatalError("Failed to fetch Tuning: \(error)")
        }
        
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
