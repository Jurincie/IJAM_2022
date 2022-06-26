//
//  StringsViewControllerXCTests.swift
//  Ijam2022Tests
//
//  Created by Ron Jurincie on 6/26/22.
//

import XCTest
@testable import Ijam2022
import AVFAudio


class StringsViewControllerXCTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_StringsViewModel_audioPlayerArray_ShouldHaveSixAudioPlayers() {
        // Given
        let stringsVM = StringsViewModel(context: coreDataManager.shared.PersistentStoreController.viewContext)
        
        // When
        XCTAssertNotNil(stringsVM.audioPlayerArray)
        XCTAssertEqual(stringsVM.audioPlayerArray.count, 6)
        
        // Then
        var thisAudioPlayer: AVAudioPlayer?
        
        for _ in 0...30 {
            thisAudioPlayer = stringsVM.audioPlayerArray[Int.random(in: 0..<6)]
            XCTAssertTrue(((thisAudioPlayer?.isKind(of: AVAudioPlayer.self)) != nil))
        }
    }
    
    func test_StringsViewModel_thisZone_shouldInitializeToNegativeOne ()
    {
        // Given
        let stringsVM = StringsViewModel(context: coreDataManager.shared.PersistentStoreController.viewContext)
        
        // When
        let zone = stringsVM.formerZone

        // Then
        XCTAssertEqual(zone, -1)
    }
    
    func test_StringsViewModel_formerZone_shouldInitializeToNegativeOne ()
    {
        // Given
        let stringsVM = StringsViewModel(context: coreDataManager.shared.PersistentStoreController.viewContext)
        
        // When
        let zone = stringsVM.formerZone
        
        // Then
        XCTAssertEqual(zone, -1)
    }
    
    
}
