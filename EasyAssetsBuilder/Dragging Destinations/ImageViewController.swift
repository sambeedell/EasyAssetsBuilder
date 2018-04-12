//
//  ImageViewController.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa


class ImageViewController: NSViewController {
    
    @IBOutlet var topLayer: DestinationView!
    @IBOutlet var targetLayer: NSView!
    @IBOutlet var invitationLabel: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    
    var inputImage: NSImage?
    
    let deviceList = DeviceList()
    var devices: [Device] = []
    var contents: JSONHandler?
    //Users/sambeedell/Documents/GitHub/EasyAssetsBuilder/EasyAssetsBuilder/Default JSON/Contents.json

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        
        // User must first select devices...
        devices.append(deviceList.iPhone)
        contents = JSONHandler(devices: devices)
        
        // MARK: - TEST (delete me)
        print(updatedContentsJSONFor(devices.first!, size: devices.first!.size.first!, filename: "MrPoopyPants.poo"))
        
        // TODO: Implement tab view or some method of changing which devices to include in another window...
        
        // TODO: Fix constraints
        
        
        topLayer.delegate = self
    }
    
    override func awakeFromNib() {
        if let layer = self.view.layer {
            let colour = CGColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            layer.backgroundColor = colour
        }
    }
    
    
    
    @IBAction func exportAction(_ sender: AnyObject) {
        
        guard let _ = inputImage else {
            Swift.print("Error: Nothing to export...")
            return
        }
        
        // NOTE: - Turn off sandbox for correct expansion of tilda
        //        let path: NSString = "~/Desktop/Test.png"
        // TEST
        let path: NSString = "~/Desktop" // this must be mutable
        let folderName = File.parent
        let parentURL = URL(fileURLWithPath: path.expandingTildeInPath).appendingPathComponent(folderName)
        
        // Check if folder exists
        // This should already exist as we want to overwrite the Assets Bundle...
        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: parentURL.path) {
                print("Folder already exists, overwriting...")
                // TODO: Prompt user to overwrite... (can do this before they select a path as default will be desktop)
                
                // Delete file
                try fm.removeItem(atPath: parentURL.path)
                
                // TODO: Store old Assets incase this fails
            } else {
                // File does not exist, continue as normal...
            }
        }
        catch let error as NSError {
            print("Error: Could not overwrite: \(error.description)")
        }
            
        // Create folder given URL
        let fm = FileManager.SearchPathDirectory.self
        if fm.desktopDirectory.createSubFolderForURL(parentURL) {
            let assetsURL = parentURL.appendingPathComponent(File.subfolder)
            if fm.desktopDirectory.createSubFolderForURL(assetsURL) {
                print("Folder successfully created")
                
                // Process image into the desired icon sizes
                if processImageForDevices(devices, in: assetsURL) {
                    print("Folder populated with images")
                } else {
                    print("Error: Failed to create all images")
                    // Clean up: remove created directories and return to original
                }
                
                // TODO: Save JSON
                if saveContentsJSON() {
                    print("Updated JSON saved")
                } else {
                    print("Error: Could nto save Contents.json")
                }
            }
        }
    }
    
    func processImageForDevices(_ devices:[Device], in url: URL) -> Bool {
        
        var count: Int = 0
        var total: Int = 0
        
        for device in devices {
            total += device.size.count
            for size in device.size {
                let filename = "\(size.filename).png"
                let imageURL = url.appendingPathComponent(filename)
                let resolution = NSSize(width: size.resolution.pixels, height: size.resolution.pixels)
                if let image = inputImage?.resized(to: resolution) {
                    if saveImageToURL(image, url: imageURL) {
                        count += 1
                        // Update .json
                        contents?.assetsJSON = updatedContentsJSONFor(device, size:size, filename: filename)
                    } else {
                        // TODO: 'device' is probably not readable, will display pointer
                        print("Could not create image for: \(device)")
                    }
                }
            }
        }
        return (count == total) ? true : false
    }
    
    
    func updatedContentsJSONFor(_ device: Device, size: Size, filename:String) -> [[String:AnyObject]] {
        let sizeString = "\(Int(size.resolution.pixel))x\(Int(size.resolution.pixel))"
        let idiom = device.name.rawValue.lowercased()
        let scale = "\(Int(size.resolution.scale))x"
        
        print("Looking for: \(idiom), \(sizeString), \(scale), \(filename)")
        
        if var assetsJSONCopy = contents?.assetsJSON {
            
            // Stupid way to update JSON:
            var count = 0
            // Mac / iOS / tvOS ....
            for var asset in assetsJSONCopy {
                // Match asset by its idiom, scale and size
                // Append/replace the asset with new image file name
                
                for var item in asset {
                    if item.key == "images" {
                        if var values = item.value as? [[String:AnyObject]] {
                            var index = 0
                            for var value in values {
                                print(value)
                                if let i = value["idiom"] as? String,
                                    let sz = value["size"] as? String,
                                    let sc = value["scale"]  as? String {
                                    if i == idiom && sz == sizeString && sc == scale {
                                        // Append mutable 'item' for 'image' given 'filepath'
                                        value["image"] = filename as AnyObject
                                        values.remove(at: index)
                                        values.append(value)
                                        item.value = values as AnyObject
                                        asset[item.key] = item as AnyObject
                                        assetsJSONCopy.remove(at: count)
                                        assetsJSONCopy.append(asset)
                                        print("Updated: \(i), \(sz), \(sc), \(filename)")
                                    } else if i == "ios-marketing" {
                                        if sc == scale {
                                            value["image"] = filename as AnyObject
                                        }
                                    }
                                }
                                index += 1
                            }
                        }
                    }
                }
                count += 1
            }
            return assetsJSONCopy
            
            
            // Codable
        }
        
        // BAD - Force unwrap
        return contents!.assetsJSON
        
    }
    
    func saveContentsJSON() -> Bool {
        // overwrite the contents of the original file.
//        do
//        {
//            let file = try FileHandle(forWritingToURL: url!)
//            file.writeData(jsonData)
//            print("JSON data was written to the file successfully!")
//        }
//        catch let error as NSError
//        {
//            print("Couldn't write to file: \(error.localizedDescription)")
//        }
        return false
    }
    
    
    func saveImageToURL(_ image: NSImage, url: URL) -> Bool {
        // Save Image to path
        if let tiffdata = image.tiffRepresentation,
            let bitmaprep = NSBitmapImageRep(data: tiffdata),
            let bitmapData = NSBitmapImageRep.representationOfImageReps(in: [bitmaprep], using: .PNG, properties: [:]) {
            do {
                try bitmapData.write(to: url, options: [])
                //print("Image saved to: \(url.path)")
                return true
            } catch let error as NSError {
                print("Error: Could not saved image: \(error.description)")
            }
        }
        Swift.print("Error: saveImageToPath() -> could not create data")
        return false
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    // TODO: Write the updateContentsJSONFor() function in here
}

//
// MARK: - DestinationViewDelegate
//
extension ImageViewController: DestinationViewDelegate {
    
    func processImageURL(_ url: URL) {
        // Create an Image with the contents of the URL
        if let image = NSImage(contentsOf: url) {
            
            // Error Check!
            print(infoAbout(url: url))
            
            // Apple App Icon Attributes
            // All app icons must adhere to these specifications
            //
            // Format = PNG
            // Color Space = sRGB or P3 -> see Apples documentation
            // Layers = Flattened, no transparency
            // Resolution = Ideal(1536), Min(1024)?
            // Shape = Square, no rounded corners
            
            // Ensure correct resolution
            if let tiff = image.tiffRepresentation {
                if let imageRep = NSBitmapImageRep(data: tiff) {
                    guard imageRep.pixelsWide == 1024, imageRep.pixelsHigh == 1024 else {
                        print("Error: image resolution too low, please submit a 1024x1024 image")
                        return
                    }
                }
            }
            
            // Display the image
            inputImage = image
            invitationLabel.isHidden = true
            infoLabel.isHidden = true
            // Configure max size of image to fit in view while retaining the aspect ratio
            let constraintSize = image.aspectFitSizeForMaxDimension(targetLayer.frame.width)
            let center = CGPoint(x: targetLayer.frame.width / 2, y: targetLayer.frame.height / 2)
            // Add image to targetLayer
            let imageView = NSImageView(frame: NSRect(x: center.x - constraintSize.width/2, y: center.y - constraintSize.height/2, width: constraintSize.width, height: constraintSize.height))
            imageView.imageScaling = .scaleProportionallyDown
            imageView.image = image
            targetLayer.addSubview(imageView)
        }
    }
    
    // MARK: - Wrong extension but should be included somewhere
    func infoAbout(url: URL) -> String {
        // 1
        let fileManager = FileManager.default
        
        // 2
        do {
            // 3
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            var report: [String] = ["\(url.path)", ""]
            
            // 4
            for (key, value) in attributes {
                // ignore NSFileExtendedAttributes as it is a messy dictionary
                if key.rawValue == "NSFileExtendedAttributes" { continue }
                report.append("\(key.rawValue):\t \(value)")
            }
            // 5
            return report.joined(separator: "\n")
        } catch {
            // 6
            return "No information available for \(url.path)"
        }
    }
}

extension NSImage {
    /**
     Derives new size for an image constrained to a maximum dimension while keeping AR constant
     - parameter maxDimension: maximum horizontal or vertical dimension for new size
     - returns: new size
     */
    func aspectFitSizeForMaxDimension(_ maxDimension: CGFloat) -> NSSize {
        var width =  size.width
        var height = size.height
        if size.width > maxDimension || size.height > maxDimension {
            let aspectRatio = size.width/size.height
            width = aspectRatio > 0 ? maxDimension : maxDimension*aspectRatio
            height = aspectRatio < 0 ? maxDimension : maxDimension/aspectRatio
        }
        return NSSize(width: width, height: height)
    }
    
    /**
     Derives new size for an image from exact pixel dimensions
     - parameter newSize: specified pixel dimensions (regardless of current screen DPI)
     - returns: new NSImage
     - source: https://stackoverflow.com/questions/11949250/how-to-resize-nsimage
     */
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0
            ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: bitmapRep))
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        
        return nil
    }
    
}

// MARK: - Folder Creation in Swift 3.0
// https://stackoverflow.com/questions/27753442/create-folder-in-swift/27755060
extension FileManager.SearchPathDirectory {
    func createSubFolder(named: String, withIntermediateDirectories: Bool = false) -> Bool {
        guard let url = FileManager.default.urls(for: self, in: .userDomainMask).first else { return false }
        do {
            try FileManager.default.createDirectory(at: url.appendingPathComponent(named), withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
            return true
        } catch let error as NSError {
            print(error.description)
            return false
        }
    }
    
    func createSubFolderForURL(_ url: URL, withIntermediateDirectories: Bool = false) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
            return true
        } catch let error as NSError {
            print(error.description)
            return false
        }
    }
}

