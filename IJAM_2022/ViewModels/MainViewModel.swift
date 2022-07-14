//
//  ContentViewModel.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/24/22.
//

import CoreData

final class MainViewModel: ObservableObject {
    private (set) var context:NSManagedObjectContext
    
    private func setActiveChordOptions() {
        if activeChordGroupName != kCreateNewGroup {
            if activeChordGroupName != self.activeChordGroup?.name {
                
                self.activeChordGroup           = getActiveChordGroupFromName(self.activeChordGroupName)
                self.activeChordGroup?.isActive = true
                self.activeChord                = getNewActiveChordFrom(group:activeChordGroup!, tuning:activeTuning!)
                self.fretIndexMap               = getFretIndexMap()
                self.selectedChordBtn           = getSelectedButtonIndex()
            }
        }
    }
    
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
            self.savedVolumeLevel = self.appState!.volumeLevel
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
            setActiveChordOptions()
        }
    }
    
    @Published var activeTuningName = "" {
        didSet {
            // ignore touches on existing tuning
            if activeTuningName != self.activeTuning!.name {
                // set old tuning to inactive and this tuning to active
                self.activeTuning!.isActive = false
                
                // set NEW activeTuning
                self.activeTuning           = getActiveTuningFromName(self.activeTuningName)
                self.activeTuning?.isActive = true
                
                // setting activeChordGroupName sets activeChord, fretIndexMap, selectedChordBtn, in it's didSet function
                self.activeChordGroupName = getActiveChordGroupName(tuning: activeTuning!)
            }
        }
    }
       
    init(context:NSManagedObjectContext) {
        self.context            = context
        self.appState           = getAppState()
        self.capoPosition       = Int(self.appState!.capoPosition)
        self.isMuted            = self.appState!.isMuted
        self.volumeLevel        = self.appState!.volumeLevel
        self.savedVolumeLevel   = self.appState!.savedVolumeLevel
        self.activeTuning       = getActiveTuning()
        self.activeTuningName   = self.activeTuning!.name!
        
        // setting activeChordGroupName's' didSet sets self.activeChordGroup
        self.activeChordGroupName = getActiveChordGroupName(tuning: self.activeTuning!)
        
        precondition(self.appState!.tunings!.count > 0, "There must be at least one tuning.")
        precondition(self.appState!.capoPosition >= -2 && self.appState!.capoPosition <= 5, "capo range: -2...5.")
        precondition(self.activeTuning!.chords!.count > 0, "There must be at least one chord for this tuning.")
        precondition(self.activeTuning!.chordGroups!.count > 0, "There must be at least one ChordGroup.")
        precondition(self.activeChordGroupName.count > 0, "There must be an avtiveChordGroupView.")

        saveContext()
    }
}











