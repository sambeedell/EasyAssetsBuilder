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
//    let aWatchKit = Device(name: DeviceName.aWatch, size: appleWatchKitAppSizes)
//    let aWatchExt = Device(name: DeviceName.aWatch, size: appleWatchKitExtensionSizes)
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
        let width: CGFloat
        let height: CGFloat
        let scale: CGFloat
        let pixels: Int
        init(width:CGFloat, height:CGFloat) {
            self.width = width
            self.height = height
            self.scale = 1
            self.pixels = 0 // Unused if not square
        }
        init(width:CGFloat, scale:CGFloat) {
            self.width = width
            self.height = width
            self.scale = scale
            self.pixels = Int(width * scale) // Ensure whole number
        }
    }
    let filename: String
    let resolution: Resolution
    init(filename:String, width:CGFloat, height:CGFloat) {
        self.filename = filename
        self.resolution = Resolution(width:width, height:height)
    }
    init(filename:String, width:CGFloat, scale:CGFloat) {
        self.filename = filename
        self.resolution = Resolution(width:width, scale:scale)
    }
}

// App Icons on iPhone, iPad and Apple Watch
// https://developer.apple.com/library/content/qa/qa1686/_index.html

// According to Xcode 9.3
let iPhoneSizes: [Size] = [
    Size(filename: "Icon-Small@2x",     width: 20, scale: 2),
    Size(filename: "Icon-Small@3x",     width: 20, scale: 3),
    Size(filename: "Icon-Small-29@2x",  width: 29, scale: 2),
    Size(filename: "Icon-Small-29@3x",  width: 29, scale: 3),
    Size(filename: "Icon-Small-40@2x",  width: 40, scale: 2),
    Size(filename: "Icon-Small-40@3x",  width: 40, scale: 3),
    Size(filename: "Icon-60@2x" ,       width: 60, scale: 2),
    Size(filename: "Icon-60@3x" ,       width: 60, scale: 3),
    Size(filename: "iTunesArtwork",     width: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Xcode 9.3
let iPadSizes: [Size] = [
    Size(filename: "Icon-Small",        width: 20, scale: 1),
    Size(filename: "Icon-Small@2x",     width: 20, scale: 2),
    Size(filename: "Icon-Small-29",     width: 29, scale: 1),
    Size(filename: "Icon-Small-29@2x",  width: 29, scale: 2),
    Size(filename: "Icon-Small-40",     width: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  width: 40, scale: 2),
    Size(filename: "Icon-76" ,          width: 76, scale: 1),
    Size(filename: "Icon-76@2x",        width: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     width: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     width: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Xcode 9.3
let iOSDevicesSizes: [Size] = [
    Size(filename: "Icon-Small",        width: 20, scale: 1),
    Size(filename: "Icon-Small@2x",     width: 20, scale: 2),
    Size(filename: "Icon-Small@3x",     width: 20, scale: 3),
    Size(filename: "Icon-Small-29",     width: 29, scale: 1),
    Size(filename: "Icon-Small-29@2x",  width: 29, scale: 2),
    Size(filename: "Icon-Small-29@3x",  width: 29, scale: 3),
    Size(filename: "Icon-Small-40",     width: 40, scale: 1),
    Size(filename: "Icon-Small-40@2x",  width: 40, scale: 2),
    Size(filename: "Icon-Small-40@3x",  width: 40, scale: 3),
    Size(filename: "Icon-60@2x" ,       width: 60, scale: 2),
    Size(filename: "Icon-60@3x" ,       width: 60, scale: 3),
    Size(filename: "Icon-76" ,          width: 76, scale: 1),
    Size(filename: "Icon-76@2x",        width: 76, scale: 2),
    Size(filename: "Icon-83.5@2x" ,     width: 83.5, scale: 2),
    Size(filename: "iTunesArtwork",     width: 1024, scale: 1)
] // Not including iOS 6.1 and earlier

// According to Xcode 9.3
let macSizes: [Size] = [
    Size(filename: "Icon-Small",        width: 16,  scale: 1),
    Size(filename: "Icon-Small@2x",     width: 16,  scale: 2),
    Size(filename: "Icon-Small-32",     width: 32,  scale: 1),
    Size(filename: "Icon-Small-32@2x",  width: 32,  scale: 2),
    Size(filename: "Icon-128",          width: 128, scale: 1),
    Size(filename: "Icon-128@2x",       width: 128, scale: 2),
    Size(filename: "Icon-256" ,         width: 256, scale: 1),
    Size(filename: "Icon-256@2x",       width: 256, scale: 2),
    Size(filename: "App-Store" ,        width: 512, scale: 1),
    Size(filename: "App-Store@2x",      width: 512, scale: 2)
] // Not including iOS 6.1 and earlier

// Assets.xcassets/AppIcon.appiconset
let appleWatchKitAppSizes: [Size] = [
    Size(filename: "Notification-Center-24@2x",   width: 24,   scale: 2),
    Size(filename: "Notification-Center-27.5@2x", width: 27.5, scale: 2),
    Size(filename: "Companion-Settings-29@2x",    width: 29,   scale: 2),
    Size(filename: "Companion-Settings-29@3x",    width: 29,   scale: 3),
    Size(filename: "App-Launcher-40@2x",          width: 40,   scale: 2),
    Size(filename: "Long-Look-44@2x",             width: 44,   scale: 2),
    Size(filename: "Quick-Look-86@2x",            width: 86,   scale: 2),
    Size(filename: "Quick-Look-98@2x",            width: 98,   scale: 2)
]
// Assets.xcassets/Complication.complicationset
let appleWatchKitExtensionSizes: [Size] = [
    // ~/Circular.imageset/
    Size(filename: "Circular-38mm",     width: 32,   scale: 1),
    Size(filename: "Circular-42mm",     width: 36,   scale: 1),
    // ~/Extra Large.imageset/
    Size(filename: "Extra-Large-38mm",  width: 182,  scale: 1),
    Size(filename: "Extra-Large-42mm",  width: 203,  scale: 1),
    // ~/Modular.imageset/
    Size(filename: "Modular-38mm",      width: 52,   scale: 1),
    Size(filename: "Modular-42mm",      width: 58,   scale: 1),
    // ~/Utilitarian.imageset/
    Size(filename: "Utilitarian-38mm",  width: 40,   scale: 1),
    Size(filename: "Utilitarian-42mm",  width: 44,   scale: 1),
]

// Assets.xcassets/App Icon & Top Shelf Image.brandassets
let appleTVBrandSizes: [Size] = [
    //
    // The App Icon is a stack of 3 different images to create a 3D parallax effect
    // This should probably not be completed by this app
    //
    // ~/App Icon - App Store.imagestack/Back.imagestacklayer/Content.imageset/
    // ~/App Icon - App Store.imagestack/Front.imagestacklayer/Content.imageset/
    // ~/App Icon - App Store.imagestack/Middle.imagestacklayer/Content.imageset/
    Size(filename: "App-Store-@1x",   width: 1280,   height: 768), //1280x768
    // ~/App Icon.imagestack/Front.imagestacklayer/Content.imageset/
    // ~/App Icon.imagestack/Back.imagestacklayer/Content.imageset/
    // ~/App Icon.imagestack/Middle.imagestacklayer/Content.imageset/
    Size(filename: "App-Icon-@1x",  width: 400,   height: 240), // 400x240
    Size(filename: "App-Icon-@2x",  width: 400,   height: 240),
    //
    // These are good to go
    //
    // ~/Top Shelf Image Wide.imageset/
    Size(filename: "Top-Shelf-Wide-@1x", width: 2320,   height: 720), // 2320x720
    Size(filename: "Top-Shelf-Wide-@2x", width: 4640,   height: 1440), // 4640x1440
    // ~/Top Shelf Image.imageset/
    Size(filename: "Top-Shelf-@1x", width: 44,   height: 1), // 1920x720
    Size(filename: "Top-Shelf-@2x", width: 44,   height: 2)  // 3840x1440
]











// extension = .appiconset
// contents  = .png files
// metadata  = Contents.json File (required) -> see Online

// Verify -> CFBundleIcons key in plist



