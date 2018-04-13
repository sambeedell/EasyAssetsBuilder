//
//  Models.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

enum File {
    // Setup filenames as standard for xcassets
    static let parent = "Assets.xcassets"
    static let subfolder = "AppIcon.appiconset"
}



// All possible devices available
struct DeviceList {
    let iPhone = Device(name: DeviceName.iPhone, size: iPhoneSizes)
    let iPad   = Device(name: DeviceName.iPad,   size: iPadSizes)
}

struct Device {
    let name: DeviceName
    let size: [Size]
    init(name:DeviceName, size:[Size]) {
        self.name = name
        self.size = size
    }
}

enum DeviceName: String {
    case iPhone = "iPhone"
    case iPad   = "iPad"
    case Mac    = "Mac"
    case Watch  = "Apple Watch"
    case tvOS   = "Apple TV"
}


// extension = .appiconset
// contents  = .png files
// metadata  = Contents.json File (required) -> see Online

// Verify -> CFBundleIcons key in plist

// App Icons on iPhone, iPad and Apple Watch
// https://developer.apple.com/library/content/qa/qa1686/_index.html

// According to Xcode 9.3
let iPhoneSizes: [Size] = [
    Size(filename: "Icon-Small@2x",     pixel: 20, scale: 2),
    Size(filename: "Icon-Small@3x",     pixel: 20, scale: 3),
    Size(filename: "Icon-Small-29@2x",  pixel: 29, scale: 2),
    Size(filename: "Icon-Small-29@3x",  pixel: 29, scale: 3),
    Size(filename: "Icon-Small-40@2x",  pixel: 40, scale: 2),
    Size(filename: "Icon-Small-40@3x",  pixel: 40, scale: 3),
    Size(filename: "Icon-60@2x" ,       pixel: 60, scale: 2),
    Size(filename: "Icon-60@3x" ,       pixel: 60, scale: 3),
    Size(filename: "iTunesArtwork",     pixel: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Apple:
/*
let iPhoneSizes: [Size] = [
    Size(filename: "Icon-Small",        pixel: 29, scale: 1),
    Size(filename: "Icon-Small@2x",     pixel: 29, scale: 2),
    Size(filename: "Icon-Small@3x" ,    pixel: 29, scale: 3),
    Size(filename: "Icon-Small-40",     pixel: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  pixel: 40, scale: 2),
    Size(filename: "Icon-Small-40@3x",  pixel: 40, scale: 3),
    Size(filename: "Icon-60@2x" ,       pixel: 60, scale: 2),
    Size(filename: "Icon-60@3x" ,       pixel: 60, scale: 3),
    Size(filename: "Icon-76" ,          pixel: 76, scale: 1),
    Size(filename: "Icon-76@2x",        pixel: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     pixel: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     pixel: 512, scale: 1),
    Size(filename: "iTunesArtwork@2x",  pixel: 512, scale: 2)
] // Not including iOS 6.1 and earlier
*/

// TODO: This is actually repeated code -> if user selected both iPad and iPhone use filter()

// According to Xcode 9.3
let iPadSizes: [Size] = [
    Size(filename: "Icon-Small",        pixel: 20, scale: 1),
    Size(filename: "Icon-Small@2x",     pixel: 20, scale: 2),
    Size(filename: "Icon-Small-29",     pixel: 29, scale: 1),
    Size(filename: "Icon-Small-29@2x",  pixel: 29, scale: 2),
    Size(filename: "Icon-Small-40",     pixel: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  pixel: 40, scale: 2),
    Size(filename: "Icon-76" ,          pixel: 76, scale: 1),
    Size(filename: "Icon-76@2x",        pixel: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     pixel: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     pixel: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Apple:
/*
let iPadSizes: [Size] = [
    Size(filename: "Icon-Small",        pixel: 29, scale: 1),
    Size(filename: "Icon-Small@2x",     pixel: 29, scale: 2),
    Size(filename: "Icon-Small-40",     pixel: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  pixel: 40, scale: 2),
    Size(filename: "Icon-76" ,          pixel: 76, scale: 1),
    Size(filename: "Icon-76@2x",        pixel: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     pixel: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     pixel: 512, scale: 1),
    Size(filename: "iTunesArtwork@2x",  pixel: 512, scale: 2)
] // Not including iOS 6.1 and earlier
*/

struct Size {
    struct Resolution {
        let pixel: CGFloat
        let scale: CGFloat
        let pixels: Int
        init(pixel:CGFloat, scale:CGFloat) {
            self.pixel = pixel
            self.scale = scale
            self.pixels = Int(pixel * scale) // Ensure whole number
        }
    }
    let filename: String
    let resolution: Resolution
    init(filename:String, pixel:CGFloat, scale:CGFloat) {
        self.filename = filename
        self.resolution = Resolution(pixel:pixel, scale:scale)
    }
}

struct Content: Codable {
    let info : Info
}

struct Info: Codable {
    let author: String
    let version: Int // Probably should be Float
    private enum CodingKeys: String, CodingKey {
        case author
        case version
    }
}

struct AssetBundle: Codable {
    struct Image: Codable {
        let idiom: String
        let scale: String
        let size:  String
        var filename: String?
    }
    let info: Info
    var images: [Image]
}


