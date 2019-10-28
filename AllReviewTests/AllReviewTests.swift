//
//  AllReviewTests.swift
//  AllReviewTests
//
//  Created by 정하민 on 2019/10/28.
//  Copyright © 2019 swift. All rights reserved.
//

import XCTest
@testable import AllReview

class AllReviewTests: XCTestCase {

    private let request = OneLineReviewAPI.sharedInstance
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            let data = [
                "memberId": "5d25b1a9b692d8fa466e8a75",
                "memberEmail": "shjo@naver.com",
                "platformCode": "EM",
                "deviceCheckId": "macos-yond",
                "password": "alfkzmf1!"
            ]
            request.rxTestLogin(userData: data)
        }
    }

}
