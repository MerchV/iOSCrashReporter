//
//  File.swift
//  
//
//  Created by Merch on 2021-02-14.
//

import Foundation

public enum Platform {
    case iOS
    case iPadOS
}

// https://github.com/pluwen/apple-device-model-list
public struct ModelLookup {

    static func getProduct(platform: Platform, model: String) -> String {

        var resource: String
        switch platform {
            case .iOS:
                resource = "plist/iPhone"
            case .iPadOS:
                resource = "plist/iPad"
        }
        guard let url = Bundle.module.url(forResource: resource, withExtension: "plist") else { fatalError() }
        guard let dictionary = NSDictionary(contentsOf: url) else { fatalError() }
        return dictionary[model] as? String ?? model
    }

}
