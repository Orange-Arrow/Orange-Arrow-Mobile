//
//  Orange_Arrow_MobileUITests.swift
//  Orange Arrow MobileUITests
//
//  Created by 刘祥 on 3/26/19.
//  Copyright © 2019 xiangliu90. All rights reserved.
//

import XCTest

class Orange_Arrow_MobileUITests: XCTestCase {
    
    var app : XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
        super.tearDown()
    }
    
    // MARK -- UI Tests for landing page
    func testSegmentControl_WhenTapped_shouldShowSignupView(){
        app.segmentedControls["Sign Up"].tap()
        XCTAssertTrue(app.buttons["Sign Up"].exists, "Label should be show on screen.")
    }
    
    


}
