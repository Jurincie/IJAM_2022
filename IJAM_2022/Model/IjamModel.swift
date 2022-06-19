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
       
        let notFirstLaunchKey   = kNotInitialRunKey
        let defaults            = UserDefaults.standard

        if defaults.bool(forKey: notFirstLaunchKey) == false {
            // ONLY BUILD the dataModel once, on intial launch
            loadDataModelViaPListsIntoPersistentStore()
            defaults.set(true, forKey: notFirstLaunchKey)
        }
    }
    
    func loadDataModelViaPListsIntoPersistentStore() {
       
        let appState = AppState(context:context)
        appState.capoPosition   = 0
        appState.volumeLevel    = kDefaultVolumeLevel
        appState.isMuted        = false
        appState.freeVersion    = true
        
        // Standard Tuning //
        let standardTuning              = Tuning(context: context)
        standardTuning.name             = kStandard
        standardTuning.openNoteIndices  = kStandardTuningIndices
        standardTuning.openNoteNames    = kStandardTuningNotes // E A D G B E
        standardTuning.isActive         = true
        standardTuning.appState         = appState

        if let path = Bundle.main.path(forResource: kStandardTuningChordLibrary, ofType: kPlist),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            
            let chordSet:NSSet = convertToSetOfChords(dict: dict, parentTuning: standardTuning)
            standardTuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: kStandardTuningChordGroups, ofType: kPlist),
                let StdTuningChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet      = convertToSetOfChordGroups(dict: StdTuningChordGroupsDict, parentTuning: standardTuning)
               
                standardTuning.addToChordGroups(chordGroupSet)
            }
        }
        
        // Drop-D Tuning //
        let dropDTuning             = Tuning(context: context)
        dropDTuning.name            = kDropD
        dropDTuning.openNoteIndices = kDropDTuningIndices // D A D G B E
        dropDTuning.openNoteNames   = kDropDTuningNotes
        dropDTuning.isActive        = false
        dropDTuning.appState        = appState
        
        if let path = Bundle.main.path(forResource: kDropDChordLibrary, ofType: kPlist),
           let dropDChordDict   = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet  = convertToSetOfChords(dict: dropDChordDict, parentTuning: dropDTuning)
           
            dropDTuning.addToChords(chordSet)
                                                    
            if let path = Bundle.main.path(forResource: kDropDTuningChordGroups, ofType: kPlist),
                let dropDChordGroupsDict    = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet     = convertToSetOfChordGroups(dict: dropDChordGroupsDict, parentTuning: standardTuning)
               
                dropDTuning.addToChordGroups(chordGroupSet)
            }
        }
        
        // Open D //
        let openDTuning             = Tuning(context: context)
        openDTuning.name            = kOpenD
        openDTuning.openNoteIndices = kOpenDTuningIndices  // D A D F# A D
        openDTuning.openNoteNames   = kOpenDTuningNotes
        openDTuning.isActive        = false
        openDTuning.appState        = appState

        if let path = Bundle.main.path(forResource: kOpenDChordLibrary, ofType: kPlist),
            let openDChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(dict: openDChordDict, parentTuning: openDTuning)
           
            openDTuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: kOpenDTuningChordGroups, ofType: kPlist),
                let openDChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                    let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: openDChordGroupsDict, parentTuning: openDTuning)
                    openDTuning.addToChordGroups(chordGroupSet)
                }
            }

        // Open G //
        let openGTuning             = Tuning(context: context)
        openGTuning.name            = "Open G"
        openGTuning.openNoteIndices = kOpenGTuningIndices  // D A D F# A D
        openGTuning.openNoteNames   = kOpenGTuningNotes
        openGTuning.isActive        = false
        openGTuning.appState        = appState

        if let path = Bundle.main.path(forResource: kOpenGChordLibrary, ofType: kPlist),
        let openGChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(dict: openGChordDict, parentTuning: openGTuning)
            openGTuning.addToChords(chordSet)

            if let path = Bundle.main.path(forResource: kOpenGTuningChordGroups, ofType: kPlist),
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
