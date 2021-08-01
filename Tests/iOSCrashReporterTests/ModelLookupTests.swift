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
        let modelLookup = ModelLookup.getProduct(model: "iPhone", platform: "iPhone0,0")
        XCTAssert(modelLookup == "iPhone0,0")
    }

    func testiPhoneX() throws {
        XCTAssert(ModelLookup.getProduct(model: "iPhone", platform: "iPhone10,3") == "iPhone X")
    }

    func testSimulator() throws {
        XCTAssert(ModelLookup.getProduct(model: "iPhone", platform: "x86_64") == "x86_64")
    }

    func testiPad11() throws {
        XCTAssert(ModelLookup.getProduct(model: "iPad", platform: "iPad8,9") == "iPad Pro 11-inch 2")
    }

    func testMacOS() throws {
        XCTAssert(ModelLookup.getProduct(model: "macOS", platform: "MacBookPro16,1") == "MacBookPro16,1")
    }

    func testiPod() throws {
        XCTAssert(ModelLookup.getProduct(model: "iOS", platform: "iPod9,1") == "iPod9,1")
    }


}
