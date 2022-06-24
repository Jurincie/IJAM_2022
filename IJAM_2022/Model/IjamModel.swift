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
            loadDataModel()
            defaults.set(true, forKey: notFirstLaunchKey)
        }
    }
    
    func loadDataModel() {
        // loads data from property lists and loads them into persistant storage
        let appState = AppState(context:context)
        
        appState.capoPosition   = 0
        appState.volumeLevel    = kDefaultVolumeLevel
        appState.isMuted        = false
        appState.freeVersion    = true
        
        let standardTuning = buildTuning(appState:appState, name:kStandard, openNoteIndices:kStandardTuningIndices,
                                         openNotes:kStandardTuningNotes, chordLibrary:kStandardTuningChordLibrary,
                                         chordGroups:kStandardTuningChordGroups)
        
        let dropDTuning = buildTuning(appState: appState, name:kDropD, openNoteIndices:kDropDTuningIndices,
                                      openNotes: kDropDTuningNotes, chordLibrary:kDropDChordLibrary,
                                      chordGroups: kDropDTuningChordGroups)
        
        let openDTuning = buildTuning(appState:appState, name:kOpenD, openNoteIndices:kOpenDTuningIndices,
                                      openNotes:kOpenDTuningNotes, chordLibrary:kOpenDChordLibrary,
                                      chordGroups:kOpenDTuningChordGroups)
        
        let openGTuning = buildTuning(appState:appState, name:kOpenG, openNoteIndices:kOpenGTuningIndices,
                                      openNotes:kOpenGTuningNotes, chordLibrary:kOpenGChordLibrary,
                                      chordGroups:kOpenGTuningChordGroups)
        
        appState.addToTunings(openDTuning)
        appState.addToTunings(dropDTuning)
        appState.addToTunings(standardTuning)
        appState.addToTunings(openGTuning)
        
        // make just one of the tunings active
        standardTuning.isActive = true
        
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
