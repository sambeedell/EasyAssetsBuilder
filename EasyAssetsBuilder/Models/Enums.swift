//
//  Enums.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 13/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

enum File {
    // Desktop path is default - must be NSString for expansion of tilda
    static let desktop: NSString = "~/Desktop"
    // Setup filenames as standard for xcassets
    static let parentFolder  = "EasyAssetsBuilder"
    static let assetsBundle  = "Assets.xcassets"
    static let appIconFolder = "AppIcon.appiconset"
}

enum DeviceName: String {
    case aWatch  = "Apple Watch"
    case iPhone  = "iPhone"
    case iPad    = "iPad"
    case Mac     = "Mac"
    case AppleTV = "Apple TV"
    case iOS     = "iOS"
}

enum DeviceTag: Int {
    case aWatch  = 0
    case iPhone  = 1
    case iPad    = 2
    case Mac     = 3
    case AppleTV = 4
}
