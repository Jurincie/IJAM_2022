//
//  IJAM_2022App.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/15/22.
//

import SwiftUI
import CoreData

@main
struct iJam_2022App: App {
    func sceneDidEnterBackground(_ scene: UIScene) {
      saveContext()
    }
    
    let persistenceController = PersistenceController.shared
    var dataModel:IjamModel = IjamModel()
    
    var body: some Scene {
        WindowGroup {
            // inject the view context into the ContentView and all its offspring
            let viewContext = coreDataManager.shared.PersistentStoreController.viewContext
                    
            ContentView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
