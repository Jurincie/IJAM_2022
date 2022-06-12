//
//  IjamModel.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/8/22.
//

import SwiftUI
import CoreData

class IjamModel {
    
    let context = coreDataManager.shared.PersistentStoreController.viewContext
    
    init() {
       
        let notFirstLaunchKey   = "notFirstLaunchKey"
        let defaults            = UserDefaults.standard

        if defaults.bool(forKey: notFirstLaunchKey) == false {
            // ONLY BUILD the dataModel once, on intial launch
            loadDataModelFormPListsIntoPersistentStore()
            defaults.set(true, forKey: notFirstLaunchKey)
        }
    }
    
    func loadDataModelFormPListsIntoPersistentStore() {
       
        let appState = AppState(context:context)
        appState.capoPosition   = 0
        appState.volumeLevel    = 33.0
        appState.isMuted        = false
        appState.freeVersion    = true
        
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

                            // Open G //
        let openGTuning             = Tuning(context: context)
        openGTuning.name            = "Open G"
        openGTuning.openNoteIndices = "2-7-14-19-23-26"  // D A D F# A D
        openGTuning.openNoteNames   = "D-G-D-G-B-D"
        openGTuning.isActive        = false
        openGTuning.appState        = appState

        if let path = Bundle.main.path(forResource: "OpenG_ChordLibrary", ofType: "plist"),
        let openGChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(dict: openGChordDict, parentTuning: openGTuning)
            openGTuning.addToChords(chordSet)

            if let path = Bundle.main.path(forResource: "OpenGTuningChordGroups", ofType: "plist"),
               let openGChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: openGChordGroupsDict, parentTuning: openGTuning)

                openGTuning.addToChordGroups(chordGroupSet)
            }
        }

        appState.addToTunings(openDTuning)
        appState.addToTunings(dropDTuning)
        appState.addToTunings(standardTuning)
        appState.addToTunings(openGTuning)
        
        saveContext()
    }
}
    
// MARK: - Save Core Data Context
func saveContext() {
    let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
    
    if viewContext.hasChanges {
        do {
            try viewContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
