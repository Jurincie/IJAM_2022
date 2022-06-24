//
//  Ijam2022Tests.swift
//  Ijam2022Tests
//
//  Created by Ron Jurincie on 6/20/22.
//

import XCTest
//import ViewInspector
@testable import Ijam2022

//extension ContentView: Inspectable { }
//extension StringsView: Inspectable { }
//extension StringView: Inspectable { }

class Ijam2022Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testContentViewExists() {
        let view = ContentView()
        XCTAssertNotNil(view)
    }
    
    func testCapoPositionPickerView() {
        let view = CapoPositionPickerView()
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view.frets.count, 8)
    }
    
    func testStringsView() {
        
    }
    
    
}
