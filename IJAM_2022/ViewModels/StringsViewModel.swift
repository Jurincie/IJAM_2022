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

enum InitializeErrors: Error {
    case InitializeSoundsError
    case MissingResourseError
    case AVAudioSessionError
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = CGRect(x:0, y:0, width:0 , height:0)
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

extension View {
  func readFrame(onChange: @escaping (CGRect) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: .global))
      }
    )
    .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
  }
}

class StringsViewModel: ObservableObject {
    private (set) var context:NSManagedObjectContext
    @Published var audioPlayerArray = [AVAudioPlayer?]()     // contains 1 audioPlayer for each guitar string  6-1
    
    func playWaveFile(noteName: String, stringNumber: Int, volume: Double) {
        let newLength   = noteName.count - 4 // trims ".wav" from end
        let prefix      = String(noteName.prefix(newLength))
        
        if let asset = NSDataAsset(name:prefix) {
            do {
                let thisAudioPlayer                 = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                audioPlayerArray[6 - stringNumber]  = thisAudioPlayer
                thisAudioPlayer.volume              = Float(volume)
                
                thisAudioPlayer.prepareToPlay()
                thisAudioPlayer.play()
            } catch InitializeErrors.AVAudioSessionError{
                exit(1)
            } catch { }
        }
    }
    
    func initializeAVAudioSession() {
        do {
            // Attempts to activate session so you can play audio,
            // if other sessions have priority this will fail
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
           print (error)
        }
    }
    
    func prepareAudioPlayer(stringNumber:Int) {
        if let asset = NSDataAsset(name:"NoNote"){
            do {
                let thisAudioPlayer = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                audioPlayerArray.append(thisAudioPlayer)
            } catch InitializeErrors.AVAudioSessionError{
                exit(1)
            } catch { }
        }
    }

    func loadWaveFilesIntoAudioPlayers() {
        for stringNumber in 0...5 {
            prepareAudioPlayer(stringNumber:stringNumber)
        }
    }
   
    @Published var noteNamesArray = ["DoubleLow_C.wav", "DoubleLow_C#.wav", "DoubleLow_D.wav", "DoubleLow_D#.wav", "Low_E.wav", "Low_F.wav", "Low_F#.wav", "Low_G.wav", "Low_G#.wav", "Low_A.wav", "Low_A#.wav", "Low_B.wav", "Low_C.wav", "Low_C#.wav", "Low_D.wav", "Low_D#.wav", "E.wav", "F.wav", "F#.wav", "G.wav", "G#.wav", "A.wav", "A#.wav", "B.wav", "C.wav", "C#.wav", "D.wav", "D#.wav", "High_E.wav", "High_F.wav", "High_F#.wav", "High_G.wav", "High_G#.wav", "High_A.wav", "High_A#.wav", "High_B.wav", "High_C.wav", "High_C#.wav", "High_D.wav", "High_D#.wav", "DoubleHigh_E.wav"]
    
    @Published var stringNumber:Int     = 0
    @Published var xPosition:Double     = 0.0
    @Published var formerZone           = -1
    @Published var zoneBreaks:[Double]  = []

    init(context:NSManagedObjectContext) {
        self.context = context
        initializeAVAudioSession()
        loadWaveFilesIntoAudioPlayers()
    }
    
    
    func getZone(loc:CGPoint) -> Int{
        // assign zone
        // 90 160 230 290 350 420
        
        var zone = -1
        
        if loc.x <= zoneBreaks[0] {
            zone = 0
        } else if loc.x > zoneBreaks[0]  && loc.x <= zoneBreaks[0] + 10 {
            zone = 1 // string 6
        } else if loc.x <= zoneBreaks[1] {
            zone = 2
        } else if loc.x > zoneBreaks[1] && loc.x <= zoneBreaks[1] + 10 {
            zone = 3 // string 5
        } else if loc.x <= zoneBreaks[2] {
            zone = 4
        } else if loc.x > zoneBreaks[2] && loc.x <= zoneBreaks[2] + 10 {
            zone = 5 // string 4
        } else if loc.x <= zoneBreaks[3] {
            zone = 6
        } else if loc.x > zoneBreaks[3] && loc.x <= zoneBreaks[3] + 10 {
            zone = 7 // string 3
        } else if loc.x <= zoneBreaks[4] {
            zone = 8
        } else if loc.x > zoneBreaks[4] && loc.x <= zoneBreaks[4] + 10 {
            zone = 9 // string 2
        } else if loc.x <= zoneBreaks[5] {
            zone = 10
        } else if loc.x > zoneBreaks[5] && loc.x <= zoneBreaks[5] + 10 {
            zone = 11 // string 1
        } else {
            zone = 12
        }
        
        print ("----> zone: \(zone)")
        
        return zone
    }
}

