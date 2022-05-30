//
//  IjamModel.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/8/22.
//

import SwiftUI
import CoreData

// this class serves as "Source of Truth" for all data used by the app

class IjamModel {
        
    init() {
        loadDataModelFormPListsIntoPersistentStore()
    }
    
    func loadDataModelFormPListsIntoPersistentStore(){
        let context = coreDataManager.shared.PersistentStoreController.viewContext
        
        let appStateEntity  = NSEntityDescription.entity(forEntityName: "AppState", in:context)
        let appStateMO      = NSManagedObject(entity: appStateEntity!, insertInto:context) as! AppState
      
        // we ONLY want to build these managedObjects IFF they don't already exist
        if dataBaseAlreadyExists(context:context) == true {
            context.deleteAllData()
        }
        
        let tuningEntity = NSEntityDescription.entity(forEntityName: "Tuning", in:context)

        // Standard Tuning //
        let standardTuningMO = NSManagedObject(entity: tuningEntity!, insertInto:context) as! Tuning
        
        if let path = Bundle.main.path(forResource: "StandardTuning_ChordLibrary", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            standardTuningMO.name           = "Standard"
            standardTuningMO.openIndices    = "4-9-14-19-23-28" // E A D G B E
            standardTuningMO.openNoteNames  = "E-A-D-G-B-E"
            
            let chordSet:NSSet = convertToSetOfChords(dict: dict)
            standardTuningMO.addToAllChords(chordSet)
            
            if let path = Bundle.main.path(forResource: "StandardTuningChordGroups", ofType: "plist"), let StdTuningChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordArray = chordSet.allObjects as! [Chord]
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: StdTuningChordGroupsDict, chordArray:chordArray)
                standardTuningMO.addToAllChordGroups(chordGroupSet)
                let activeGroup = chordGroupSet.anyObject() as! ChordGroup
                standardTuningMO.setValue(activeGroup, forKey: "activeChordGroup")
            }
            
            appStateMO.setValue(standardTuningMO, forKey: "activeTuning")
        }
        
        // Drop-D Tuning //
        let dropD_TuningMO = NSManagedObject(entity: tuningEntity!, insertInto:context) as! Tuning
        
        if let path = Bundle.main.path(forResource: "DropD_ChordLibrary", ofType: "plist"), let dropDChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            dropD_TuningMO.name             = "Drop D"
            dropD_TuningMO.openIndices      = "2-9-14-19-23-28" // D A D G B E
            dropD_TuningMO.openNoteNames    = "D-A-D-G-B-E"
            
            let chordSet:NSSet = convertToSetOfChords(dict: dropDChordDict)
            dropD_TuningMO.addToAllChords(chordSet)
            
            if let path = Bundle.main.path(forResource: "DropDTuningChordGroups", ofType: "plist"), let dropDChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                
                let chordArray = chordSet.allObjects as! [Chord]
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: dropDChordGroupsDict, chordArray:chordArray)
                dropD_TuningMO.addToAllChordGroups(chordGroupSet)
                
                let activeGroup = chordGroupSet.anyObject() as! ChordGroup
                dropD_TuningMO.setValue(activeGroup, forKey: "activeChordGroup")
            }
        }
        
        // Open D
        let openD_TuningMO = NSManagedObject(entity: tuningEntity!, insertInto:context) as! Tuning
        
        if let path = Bundle.main.path(forResource: "OpenD_ChordLibrary", ofType: "plist"), let openDChordDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            openD_TuningMO.name             = "Open D"
            openD_TuningMO.openIndices      = "2-9-14-18-21-26"  // D A D F# A D
            openD_TuningMO.openNoteNames    = "D-A-D-F#-A-D"
            
            let chordSet:NSSet = convertToSetOfChords(dict: openDChordDict)
            openD_TuningMO.addToAllChords(chordSet)
            
            if let path = Bundle.main.path(forResource: "OpenDTuningChordGroups", ofType: "plist"), let openDChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                
                let chordArray = chordSet.allObjects as! [Chord]
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: openDChordGroupsDict, chordArray:chordArray)
                openD_TuningMO.addToAllChordGroups(chordGroupSet)
                
                let activeGroup = chordGroupSet.anyObject() as! ChordGroup
                openD_TuningMO.setValue(activeGroup, forKey: "activeChordGroup")
            }
        }
         
        appStateMO.addToAllTunings(openD_TuningMO)
        appStateMO.addToAllTunings(dropD_TuningMO)
        appStateMO.addToAllTunings(standardTuningMO)
        
        appStateMO.setValue(0, forKey: "capoPosition")
        appStateMO.setValue(50.0, forKey: "volumeLevel")
        appStateMO.setValue(false, forKey: "isMuted")
        appStateMO.setValue(true, forKey: "freeVersion")
        
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
