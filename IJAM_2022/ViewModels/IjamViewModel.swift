//
//  IjamViewModel.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/24/22.
//

import Foundation
import CoreData

class IjamViewModel: ObservableObject {
    private (set) var context:NSManagedObjectContext
    
    @Published var appState:AppState?{
        didSet {
            saveContext()
        }
    }
    @Published var activeTuning:Tuning?{
        didSet {
            saveContext()
        }
    }
    @Published var activeChordGroup:ChordGroup?{
        didSet {
            saveContext()
        }
    }
    @Published var activeChord:Chord?{
        didSet {
            saveContext()
        }
    }
    @Published var isMuted:Bool = false {
        didSet {
            self.appState!.isMuted = isMuted
            saveContext()
        }
    }
    @Published var selectedChordBtn:Int?{
        didSet {
            saveContext()
        }
    }
    @Published var volumeLevel:Double = 0.0 {
        didSet {
            self.appState?.volumeLevel = volumeLevel
            saveContext()
        }
    }
    @Published var savedVolumeLevel = 0.0{
        didSet {
            self.appState?.savedVolumeLevel = savedVolumeLevel
            saveContext()
        }
    }
    @Published var fretIndexMap:[Int] = []{
        didSet {
            saveContext()
        }
    }
    @Published var capoPosition:Int = 0 {
        didSet {
            self.appState?.capoPosition = Int16(capoPosition)
            saveContext()
        }
    }
    @Published var activeChordGroupName = "" {
        didSet {
            // set the activeChordGroup based on name
            // then set: tuning.activeChord, fretMapIndex, selectedButton so chordButttons and Strings display properly]
            
            if activeChordGroupName != "CREATE NEW GROUP" {
                if activeChordGroupName != self.activeChordGroup?.name {
                    // set FORMER chordGroup.isActive to false
                    self.activeChordGroup?.isActive = false
                    
                    self.activeChordGroup           = getActiveChordGroupFromName(name: activeChordGroupName)
                    self.activeChordGroup?.isActive = true
                    self.activeChord                = getNewActiveChordFrom(group:activeChordGroup!, tuning:activeTuning!)
                    self.fretIndexMap               = getFretIndexMap()
                    self.selectedChordBtn           = getSelectedButtonIndex()
                }
            }
        }
    }
    
    @Published var activeTuningName = "" {
        didSet {
            
            if activeTuningName != self.activeTuning!.name {
                // set old tuning to inactive and this tuning to active
                self.activeTuning!.isActive = false
                
                // set NEW activeTuning
                self.activeTuning           = getActiveTuningFromName(name: self.activeTuningName)
                self.activeTuning?.isActive = true

                // setting activeChordGroupName sets activeChord, fretIndexMap, selectedChordBtn, in it's didSet function
                self.activeChordGroupName = getActiveChordGroupName(tuning: activeTuning!)
            }
        }
    }
       
    init(context:NSManagedObjectContext) {
        self.context                = context
        self.appState               = getAppState()
        self.capoPosition           = Int(self.appState!.capoPosition)
        self.isMuted                = self.appState!.isMuted
        self.volumeLevel            = self.appState!.volumeLevel
        self.savedVolumeLevel       = self.appState!.savedVolumeLevel
        self.activeTuning           = getActiveTuning()
        self.activeTuningName       = self.activeTuning!.name!
        
        // getting activeChordGroupName causes didSet to initiate self.activeChordGroup
        self.activeChordGroupName = getActiveChordGroupName(tuning: self.activeTuning!)
        
        saveContext()
    }
}











