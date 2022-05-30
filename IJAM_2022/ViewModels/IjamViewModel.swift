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
            saveContext()
        }
    }
    @Published var selectedChordBtn:Int?{
        didSet {
            saveContext()
        }
    }
    @Published var volumeLevel:Double = 50.0 {
        didSet {
            saveContext()
        }
    }
    @Published var savedVolumeLevel = 50.0{
        didSet {
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
            saveContext()
        }
    }
    @Published var activeChordGroupName = "" {
        didSet {
            // set the activeChordGroup based on name
            // then set: tuning.activeChord, fretMapIndex, selectedButton so chordButttons and Strings display properly]
            activeChordGroup            = getActiveChordGroupFromName(name: self.activeChordGroupName)
            activeTuning?.activeChord   = getNewActiveChordFrom(group:activeChordGroup!, tuning:activeTuning!)
            fretIndexMap                = getFretIndexMap()
            selectedChordBtn            = getSelectedButtonIndex()
            
            saveContext()
        }
    }
    @Published var activeTuningName = "" {
        didSet {
            // set the activeTuning based on name
            // then set: tuning.activeChordGroup, tuning.activeChord, fretMapIndex so chordButtons and Strings display properly
            activeTuning                = getActiveTuningFromName(name: self.activeTuningName)
            activeChordGroup            = getActiveChordGroup(tuning: activeTuning!)
            activeTuning?.activeChord   = getNewActiveChordFrom(group:activeChordGroup!, tuning:activeTuning!)
            fretIndexMap                = getFretIndexMap()
            selectedChordBtn            = getSelectedButtonIndex()
            
            saveContext()
        }
    }
       
    init(context:NSManagedObjectContext) {
        self.context                = context
        self.appState               = getAppState()
        self.activeTuning           = getActiveTuning()
        self.activeTuningName       = self.activeTuning!.name!
        self.activeChordGroup       = getActiveChordGroup(tuning: self.activeTuning!)
        self.activeChord            = self.activeTuning!.activeChord!
        self.fretIndexMap           = getFretIndexMap()
        self.activeChordGroupName   = self.activeChordGroup!.name!
        self.selectedChordBtn       = getSelectedButtonIndex()
        
        saveContext()
    }
}











