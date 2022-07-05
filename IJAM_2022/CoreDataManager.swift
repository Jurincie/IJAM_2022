//
//  CoreDataManager.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/4/22.
//

import CoreData

class coreDataManager {
    
    // the purpose of coreDataManager is to INITIALIZE the coreData Stack
    let PersistentStoreController: NSPersistentContainer
    static let shared = coreDataManager()
    
    private init() {
        PersistentStoreController = NSPersistentContainer(name:"Ijam_2022Model")
        PersistentStoreController.loadPersistentStores { description, error in
            if let error = error {
                #if DEBUG
                debugPrint("Fatal Error: Unable to initialize CoreData \(error)")
                #endif
            }
        }
    }
}
