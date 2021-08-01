//
//  File.swift
//  
//
//  Created by Merch on 2021-02-14.
//

import Foundation

// https://github.com/pluwen/apple-device-model-list
public struct ModelLookup {

    // model is "iPhone" or "iPad"; platform is "iPhone11,8"
    static func getProduct(model: String, platform: String) -> String {

        var resource: String
        if model == "iPhone" {
            resource = "plist/iPhone"
        } else if model == "iPad" {
            resource = "plist/iPad"
        } else {
            return platform 
        }
        guard let url = Bundle.module.url(forResource: resource, withExtension: "plist") else { fatalError() }
        guard let dictionary = NSDictionary(contentsOf: url) else { fatalError() }
        return dictionary[platform] as? String ?? platform
    }

}
