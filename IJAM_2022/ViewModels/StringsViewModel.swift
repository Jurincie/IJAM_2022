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

final class StringsViewModel: ObservableObject {
    private (set) var context:NSManagedObjectContext
    var audioPlayerArray: [AVAudioPlayer?] = []
    
    func playWaveFile(noteName: String, stringNumber: Int, volume: Double) {
        // creates a NEW AVAudioPlayer and loads the .wav file for the noteName fils
        // assigns that player to the AudioPlayerArray
        // then plays sound at volume level
        
        guard stringNumber <= 6 && stringNumber > 0 else {return}
        guard noteName.count > 0 else {return}
        
        let newLength   = noteName.count - 4 // trims ".wav" from end
        let prefix      = String(noteName.prefix(newLength))
        
        if let asset = NSDataAsset(name:prefix) {
            do {
                audioPlayerArray[6 - stringNumber]!.stop() // FIX: ?
                
                // load a NEW audio player every time string is picked
                let thisAudioPlayer = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                audioPlayerArray[6 - stringNumber] = thisAudioPlayer

                thisAudioPlayer.volume = Float(volume)
                thisAudioPlayer.currentTime = 0.0
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
            debugPrint (error)
            throw InitializeErrors.InitializeSoundsError
        }
    }
    
    func muteAllAudio () {
        // does NOT work on simulator
        // test on adtual device
        for index in 0..<6 {
            audioPlayerArray[index]?.stop()
            audioPlayerArray[index]?.currentTime = 0.0
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
    
    var thisZone = -1
    
    @Published var stringNumber:Int     = 0
    @Published var xPosition:Double     = 0.0
    @Published var formerZone:Int       = -1
    @Published var zoneBreaks:[Double]  = []
    @Published var showingAlert:Bool    = false
    
    @Published var noteNamesArray = ["DoubleLow_C.wav", "DoubleLow_C#.wav", "DoubleLow_D.wav", "DoubleLow_D#.wav", "Low_E.wav", "Low_F.wav", "Low_F#.wav", "Low_G.wav", "Low_G#.wav", "Low_A.wav", "Low_A#.wav", "Low_B.wav", "Low_C.wav", "Low_C#.wav", "Low_D.wav", "Low_D#.wav", "E.wav", "F.wav", "F#.wav", "G.wav", "G#.wav", "A.wav", "A#.wav", "B.wav", "C.wav", "C#.wav", "D.wav", "D#.wav", "High_E.wav", "High_F.wav", "High_F#.wav", "High_G.wav", "High_G#.wav", "High_A.wav", "High_A#.wav", "High_B.wav", "High_C.wav", "High_C#.wav", "High_D.wav", "High_D#.wav", "DoubleHigh_E.wav", "DoubleHigh_F.wav", "DoubleHigh_F#.wav"]
    

    init(context:NSManagedObjectContext) {
        self.context = context
        do {
            try initializeAVAudioSession()
        } catch {
            fatalError()
        }
        
        loadWaveFilesIntoAudioPlayers()
    }
    
    func noteToPlay(_ fretIndexMap:[Int],_ openNoteIndices:String,_ stringToPlay: Int,_ capoPosition:Int) -> String {
        let thisStringsFretPosition = fretIndexMap[6 - stringToPlay]
        var noteToPlayName = ""
        
        if thisStringsFretPosition > -1 {
            let openNoteArray:[String]  = openNoteIndices.components(separatedBy:["-"])
            let thisStringsOpenIndex    = Int(openNoteArray[6 - stringToPlay])
            let index                   = thisStringsFretPosition + thisStringsOpenIndex! + capoPosition
            
            noteToPlayName = noteNamesArray[index]
        }
        
        return noteToPlayName
    }
    
    func dragTriggersStringToPlay(loc:CGPoint) -> Int {
        thisZone            = currentZone(loc:loc)
        var pickString      = false
        var stringToPlay    = -1
        
        if thisZone != formerZone {
            debugPrint("----> thisZone: \(thisZone)   formerZone: \(formerZone)")

            if formerZone == -1 {
                formerZone = thisZone
            } else {
                pickString = true
            }
            
            if pickString {
                stringToPlay = (formerZone + thisZone) / 2
            }
            
            // reset here regardless of whether string was played or not
            formerZone = thisZone
        } else {
            debugPrint("----> Same Zone \(thisZone)")
        }
        
        return stringToPlay
    }
    
    func playGuitar(_ stringNumber:Int,_ noteToPlay:String,_ volume: CGFloat) {
        if(AVAudioSession.sharedInstance().outputVolume == 0.0) {
            // Alert user that their volume is off
            showingAlert = true
        }
        
        playWaveFile(noteName:noteToPlay, stringNumber: stringNumber, volume: volume * kDefaultVolumeMagnification)
    }
        
    func currentZone(loc:CGPoint) -> Int
    {
        // returns current position
        // zone breaks derived from GeometryReader
        
        var zone:Int
        
        switch loc.x {
            case 0..<zoneBreaks[0]:             zone = 7
            case zoneBreaks[0]..<zoneBreaks[1]: zone = 6
            case zoneBreaks[1]..<zoneBreaks[2]: zone = 5
            case zoneBreaks[2]..<zoneBreaks[3]: zone = 4
            case zoneBreaks[3]..<zoneBreaks[4]: zone = 3
            case zoneBreaks[4]..<zoneBreaks[5]: zone = 2
            case zoneBreaks[5]...:              zone = 1
            default:                            zone = -1
        }

        return zone
    }
}

