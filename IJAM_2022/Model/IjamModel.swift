//
//  IjamModel.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/8/22.
//

import SwiftUI
import CoreData
// context.deleteAllData()
// exit(0)


class IjamModel {
    
    let context = coreDataManager.shared.PersistentStoreController.viewContext
    
    init() {
        let firstLaunchKey  = "notFirstLaunchKey"
        let defaults        = UserDefaults.standard        
        
        // ONLY BUILD the dataModel once, on intial launch
        if defaults.bool(forKey: "notFirstLaunchKey") == false {
            loadDataModelFormPListsIntoPersistentStore()
            defaults.set(false, forKey: firstLaunchKey)
        }
    }
    
    func loadDataModelFormPListsIntoPersistentStore() {
       
        let appState            = AppState(context:context)
        appState.capoPosition   = 0
        appState.isMuted        = false
        appState.freeVersion    = true
        appState.volumeLevel    = 50.0
        
                            // Standard Tuning //
        let standardTuning              = Tuning(context: context)
        standardTuning.name             = "Standard"
        standardTuning.openNoteIndices  = "4-9-14-19-23-28" // E A D G B E
        standardTuning.openNoteNames    = "E-A-D-G-B-E"
        standardTuning.isActive         = true
        standardTuning.appState         = appState

        if let path = Bundle.main.path(forResource: "StandardTuning_ChordLibrary", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            
            let chordSet:NSSet = convertToSetOfChords(dict: dict, parentTuning: standardTuning)
            standardTuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: "StandardTuningChordGroups", ofType: "plist"),
                let StdTuningChordGroupsDict    = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet         = convertToSetOfChordGroups(dict: StdTuningChordGroupsDict, parentTuning: standardTuning)
               
                standardTuning.addToChordGroups(chordGroupSet)
            }
        }
        
                            // Drop-D Tuning //
        let dropDTuning             = Tuning(context: context)
        dropDTuning.name            = "Drop D"
        dropDTuning.openNoteIndices = "2-9-14-19-23-28" // D A D G B E
        dropDTuning.openNoteNames   = "D-A-D-G-B-E"
        dropDTuning.isActive        = false
        dropDTuning.appState        = appState
        
        if let path = Bundle.main.path(forResource: "DropD_ChordLibrary", ofType: "plist"),
           let dropDChordDict   = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet  = convertToSetOfChords(dict: dropDChordDict, parentTuning: dropDTuning)
           
            dropDTuning.addToChords(chordSet)
                                                    
            if let path = Bundle.main.path(forResource: "DropDTuningChordGroups", ofType: "plist"),
                let dropDChordGroupsDict    = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet     = convertToSetOfChordGroups(dict: dropDChordGroupsDict, parentTuning: standardTuning)
               
                dropDTuning.addToChordGroups(chordGroupSet)
            }
        }
        
                            // Open D //
        let openDTuning             = Tuning(context: context)
        openDTuning.name            = "Open D"
        openDTuning.openNoteIndices = "2-9-14-18-21-26"  // D A D F# A D
        openDTuning.openNoteNames   = "D-A-D-F#-A-D"
        openDTuning.isActive        = false
        openDTuning.appState        = appState

        if let path = Bundle.main.path(forResource: "OpenD_ChordLibrary", ofType: "plist"),
            let openDChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(dict: openDChordDict, parentTuning: openDTuning)
           
            openDTuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: "OpenDTuningChordGroups", ofType: "plist"),
                let openDChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: openDChordGroupsDict, parentTuning: openDTuning)
                
                openDTuning.addToChordGroups(chordGroupSet)
            }
        }
         
        appState.addToTunings(openDTuning)
        appState.addToTunings(dropDTuning)
        appState.addToTunings(standardTuning)
        
        saveContext()
    }
}
    
// MARK: - Save Core Data Context
func saveContext() {
    let moc = coreDataManager.shared.PersistentStoreController.viewContext
    
    if moc.hasChanges {
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
