//
//  StringsViewModel.swift
//  IJAM_2022
//
//  Created by Ron Jurincie on 5/26/22.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData

enum InitializeErrors: LocalizedError {
    case InitializeSoundsError
    case MissingResourseError
    case AVAudioSessionError
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = CGRect(x:0, y:0, width:0 , height:0)
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

class StringsViewModel: ObservableObject {
    private (set) var context:NSManagedObjectContext
    var audioPlayerArray: [AVAudioPlayer?] = []
    
    func playWaveFile(noteName: String, stringNumber: Int, volume: Double) {
        let newLength   = noteName.count - 4 // trims ".wav" from end
        let prefix      = String(noteName.prefix(newLength))
        
        if let asset = NSDataAsset(name:prefix) {
            do {
                let thisAudioPlayer = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                
                // load a NEW audio player every time string is picked
                audioPlayerArray[6 - stringNumber] = thisAudioPlayer
                
                thisAudioPlayer.volume = Float(volume)
                thisAudioPlayer.play()
            } catch {
                fatalError()
            }
        }
    }
    
    func initializeAVAudioSession() throws {
        do {
            // Attempts to activate session so you can play audio,
            // if other sessions have priority this will fail
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            #if DEBUG
            debugPrint (error)
            #endif
            
            throw InitializeErrors.InitializeSoundsError
        }
    }
    
    func prepareAudioPlayer(stringNumber:Int) throws {
        if let asset = NSDataAsset(name:kNoNoteWaveFile){
            do {
                let thisAudioPlayer = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                audioPlayerArray.append(thisAudioPlayer)
            } catch {
                throw InitializeErrors.AVAudioSessionError
            }
        }
    }

    func loadWaveFilesIntoAudioPlayers() {
        for stringNumber in 0..<6 {
            do {
                try prepareAudioPlayer(stringNumber:stringNumber)
            } catch {
                fatalError()
            }
        }
    }
   
    @Published var noteNamesArray = ["DoubleLow_C.wav", "DoubleLow_C#.wav", "DoubleLow_D.wav", "DoubleLow_D#.wav", "Low_E.wav", "Low_F.wav", "Low_F#.wav", "Low_G.wav", "Low_G#.wav", "Low_A.wav", "Low_A#.wav", "Low_B.wav", "Low_C.wav", "Low_C#.wav", "Low_D.wav", "Low_D#.wav", "E.wav", "F.wav", "F#.wav", "G.wav", "G#.wav", "A.wav", "A#.wav", "B.wav", "C.wav", "C#.wav", "D.wav", "D#.wav", "High_E.wav", "High_F.wav", "High_F#.wav", "High_G.wav", "High_G#.wav", "High_A.wav", "High_A#.wav", "High_B.wav", "High_C.wav", "High_C#.wav", "High_D.wav", "High_D#.wav", "DoubleHigh_E.wav", "DoubleHigh_F.wav", "DoubleHigh_F#.wav"]
    
    @Published var stringNumber:Int     = 0
    @Published var xPosition:Double     = 0.0
    @Published var formerZone           = -1
    @Published var zoneBreaks:[Double]  = []
    @Published var showingAlert         = false
    var thisZone = -1

    init(context:NSManagedObjectContext) {
        self.context = context
        do {
            try initializeAVAudioSession()
        } catch {
            fatalError()
        }
        
        loadWaveFilesIntoAudioPlayers()
    }
    
    func dragsNewPositionTriggersPlay(loc:CGPoint) -> Bool {
        thisZone        = currentZone(loc:loc)
        var pickString  = false
        
        if thisZone != formerZone {
            if formerZone == -1 {
                formerZone = thisZone
            } else {
                pickString = true
            }
        }
        
        return pickString
    }
    
    func pickString(fretIndexMap:[Int], openNoteIndices:String, capoPosition: Int, volumeLevel: CGFloat) {
        if(AVAudioSession.sharedInstance().outputVolume == 0.0) {
            // Alert user that their volume is off
            showingAlert = true
        }
        
        // algebra is cool
        let stringToPlay = (formerZone + thisZone) / 2
        debugPrint("---> thisZone: \(thisZone) : formerZone \(formerZone) : stringToplay: \(stringToPlay)")
        
        let thisStringsFretPosition = fretIndexMap[6 - stringToPlay]

        if thisStringsFretPosition > -1 {
            let openNoteArray:[String]  = openNoteIndices.components(separatedBy:["-"])
            let thisStringsOpenIndex    = Int(openNoteArray[6 - stringToPlay])
            let index                   = thisStringsFretPosition + thisStringsOpenIndex! + capoPosition
            let noteToPlayName          = noteNamesArray[index]
                                    
            playWaveFile(noteName:noteToPlayName, stringNumber: stringToPlay, volume: volumeLevel * kDefaultVolumeMagnification)
            
            formerZone = thisZone
        }
    }
        
    func currentZone(loc:CGPoint) -> Int
    {
        // returns current position
        // zone breaks derived from GeometryReader
        
        var zone = -1
        
        if loc.x <= zoneBreaks[0] {
            zone = 7  // left of 6th string
        } else if loc.x > zoneBreaks[0]  && loc.x <= zoneBreaks[1] {
            zone = 6 // between 6th and 5th strings
        } else if loc.x > zoneBreaks[1]  && loc.x <= zoneBreaks[2] {
            zone = 5 // between 5th and 4th strings
        } else if loc.x > zoneBreaks[2]  && loc.x <= zoneBreaks[3] {
            zone = 4 // between 4th and 3rd strings
        } else if loc.x > zoneBreaks[3]  && loc.x <= zoneBreaks[4] {
            zone = 3 // between 3rd and 2nd strings
        } else if loc.x > zoneBreaks[4]  && loc.x <= zoneBreaks[5] {
            zone = 2 // between 2nd and 1st strings
        } else {
            zone = 1 // right of 1st string
        }
            
        return zone
    }
}

