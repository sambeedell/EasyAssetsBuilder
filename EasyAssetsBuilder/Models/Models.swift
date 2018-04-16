//
//  Models.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

// All possible devices available
struct DeviceList {
    let iPhone = Device(name: DeviceName.iPhone, size: iPhoneSizes)
    let iPad   = Device(name: DeviceName.iPad,   size: iPadSizes)
    let iOS    = Device(name: DeviceName.iOS,    size: iOSDevicesSizes)
    let Mac    = Device(name: DeviceName.Mac,    size: macSizes)
}

struct Device {
    let name: DeviceName
    let size: [Size]
    var assetsURL: URL?
    init(name:DeviceName, size:[Size]) {
        self.name = name
        self.size = size
    }
}

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

// According to Xcode 9.3
let iOSDevicesSizes: [Size] = [
    Size(filename: "Icon-Small",        pixel: 20, scale: 1),
    Size(filename: "Icon-Small@2x",     pixel: 20, scale: 2),
    Size(filename: "Icon-Small@3x",     pixel: 20, scale: 3),
    Size(filename: "Icon-Small-29",     pixel: 29, scale: 1),
    Size(filename: "Icon-Small-29@2x",  pixel: 29, scale: 2),
    Size(filename: "Icon-Small-29@3x",  pixel: 29, scale: 3),
    Size(filename: "Icon-Small-40",     pixel: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  pixel: 40, scale: 2),
    Size(filename: "Icon-Small-40@3x",  pixel: 40, scale: 3),
    Size(filename: "Icon-60@2x" ,       pixel: 60, scale: 2),
    Size(filename: "Icon-60@3x" ,       pixel: 60, scale: 3),
    Size(filename: "Icon-76" ,          pixel: 76, scale: 1),
    Size(filename: "Icon-76@2x",        pixel: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     pixel: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     pixel: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Xcode 9.3
let macSizes: [Size] = [
    Size(filename: "Icon-Small",        pixel: 16,  scale: 1),
    Size(filename: "Icon-Small@2x",     pixel: 16,  scale: 2),
    Size(filename: "Icon-Small-32",     pixel: 32,  scale: 1),
    Size(filename: "Icon-Small-32@2x",  pixel: 32,  scale: 2),
    Size(filename: "Icon-Small-128",    pixel: 128, scale: 1),
    Size(filename: "Icon-Small-128@2x", pixel: 128, scale: 2),
    Size(filename: "Icon-256" ,         pixel: 256, scale: 1),
    Size(filename: "Icon-256@2x",       pixel: 256, scale: 2),
    Size(filename: "App-Store" ,        pixel: 512, scale: 1),
    Size(filename: "App-Store@2x",      pixel: 512, scale: 2)
] // Not including iOS 6.1 and earlier


















// extension = .appiconset
// contents  = .png files
// metadata  = Contents.json File (required) -> see Online

// Verify -> CFBundleIcons key in plist



