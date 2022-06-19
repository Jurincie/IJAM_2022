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
    @Published var tuningJustChanged:Bool = false {
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
            
            if activeChordGroupName != kCreateNewGroup {
                if activeChordGroupName != self.activeChordGroup?.name {
                    // only set old chordGroup's isActive to false if it this is the same tuning
                    if self.tuningJustChanged == false {
                        self.activeChordGroup?.isActive = false
                    }
                    
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
            // ignore touches on existing tuning
            if activeTuningName != self.activeTuning!.name {
                // set old tuning to inactive and this tuning to active
                self.activeTuning!.isActive = false
                
                // set NEW activeTuning
                self.activeTuning           = getActiveTuningFromName(name: self.activeTuningName)
                self.activeTuning?.isActive = true
                
                // setting activeChordGroupName sets activeChord, fretIndexMap, selectedChordBtn, in it's didSet function
                self.tuningJustChanged      = true
                self.activeChordGroupName   = getActiveChordGroupName(tuning: activeTuning!)
                self.tuningJustChanged      = false
            }
        }
    }
       
    init(context:NSManagedObjectContext) {
        self.context    = context
        self.appState   = getAppState()
        precondition(self.appState!.tunings!.count > 0, "There must be at least one tuning.")
        
        self.capoPosition = Int(self.appState!.capoPosition)
        precondition(self.appState!.capoPosition > -3 && self.appState!.capoPosition < 6, "capo range: -2...5.")

        self.isMuted            = self.appState!.isMuted
        self.volumeLevel        = self.appState!.volumeLevel
        self.savedVolumeLevel   = self.appState!.savedVolumeLevel
        self.activeTuning       = getActiveTuning()
        precondition(self.activeTuning!.chords!.count > 0, "There must be at least one chord.")
        precondition(self.activeTuning!.chordGroups!.count > 0, "There must be at least one ChordGroup.")

        self.activeTuningName   = self.activeTuning!.name!
        self.tuningJustChanged  = false
        
        // setting activeChordGroupName's' didSet sets self.activeChordGroup
        self.activeChordGroupName = getActiveChordGroupName(tuning: self.activeTuning!)
        precondition(self.activeChordGroupName.count > 0, "There must be at least one chord.")

        saveContext()
    }
}











