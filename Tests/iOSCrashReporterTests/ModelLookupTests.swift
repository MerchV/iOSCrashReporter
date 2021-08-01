//
//  File.swift
//  
//
//  Created by Merch on 2021-02-14.
//

@testable import iOSCrashReporter
import XCTest

class ModelLookupTests: XCTestCase {

    func testNonExistingModelLookup() throws {
        let modelLookup = ModelLookup.getProduct(platform: .iOS, model: "iPhone0,0")
        XCTAssert(modelLookup == "iPhone0,0")
    }

    func testiPhoneX() throws {
        XCTAssert(ModelLookup.getProduct(platform: .iOS, model: "iPhone10,3") == "iPhone X")
    }

    func testSimulator() throws {
        XCTAssert(ModelLookup.getProduct(platform: .iOS, model: "x86_64") == "x86_64")
    }

    func testiPad11() throws {
        XCTAssert(ModelLookup.getProduct(platform: .iPadOS, model: "iPad8,9") == "iPad Pro 11-inch 2")
    }


}
