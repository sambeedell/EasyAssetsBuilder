//
//  ImageViewController.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa


class ImageViewController: NSViewController {
    
    // Show print statements for debugging
    let DEBUG = true
    
    @IBOutlet var topLayer: DestinationView!
    @IBOutlet var targetLayer: NSView!
    @IBOutlet var invitationLabel: NSTextField!
    @IBOutlet var infoLabel: NSTextField!
    @IBOutlet var outputURLTextField: NSTextField!
    @IBOutlet var outputURLSearchButton: NSButton!
    @IBOutlet weak var quickHelpMessage: NSTextField!
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var appleWatch: NSButton!
    @IBOutlet weak var iPhone: NSButton!
    @IBOutlet weak var iPad: NSButton!
    @IBOutlet weak var mac: NSButton!
    @IBOutlet weak var appleTV: NSButton!
    @IBOutlet weak var devicesLabel: NSTextField!
    
    @IBOutlet weak var errorLabel: NSTextField!
    var errorMessage: String = "" {
        didSet {
            if errorMessage == "" {
                showAlert(message: errorMessage)
            } else {
                showAlert(message: errorMessage, isHidden: false)
            }
        }
    }
    
    var inputImage: NSImage?
    var path: NSString! { // this must be mutable
        didSet {
            // Convert to String
            var string: String = path as String
            if path == File.desktop {
                // NOTE: - Turn off sandbox for correct expansion of tilda
                string = path.expandingTildeInPath
            }
            baseURL = URL(fileURLWithPath: string)
        }
    }
    var baseURL: URL! {
        didSet {
            // Ensure we have a correct path to Desktop / Xcode Project
            if FileManager.default.fileExists(atPath: baseURL.path) {
                if DEBUG { print("Valid baseURL:", baseURL.path) }
            } else {
                fatalError("Folder does not exist!")
            }
            
        }
    }
    
    let deviceList = DeviceList()
    var devices: [Device] = []
    var assetBundle: AssetBundleJSON?
    //Users/sambeedell/Documents/GitHub/EasyAssetsBuilder/EasyAssetsBuilder/Default JSON/Contents.json
    
//    let fm = FileManager.SearchPathDirectory.self
    let fm = FileManager.default

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        // Init default URL
        path = File.desktop
        quickHelpMessage.stringValue = ""
        
        // User must first select devices...
        // TODO: Use property listeners!
        devices.append(deviceList.iOS)
        //devices.append(deviceList.Mac)
        printDevices()
        
        // TODO: Implement tab view or some method of changing which devices to include in another window...
        
        // TODO: Fix constraints
        
        let key = "hint"
        let searchArea = NSTrackingArea.init(rect: outputURLSearchButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: [key: "outputURLSearch"])
        outputURLSearchButton.addTrackingArea(searchArea)
        
        topLayer.delegate = self
        
        //let colour = CGColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        //self.view.layer?.backgroundColor = CGColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        //self.tabView.layer?.backgroundColor = CGColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    
    override func mouseEntered(with event: NSEvent) {
        // Identify which button triggered the mouseEntered event
        if let buttonName = event.trackingArea?.userInfo?.values.first as? String {
            switch (buttonName) {
            case "outputURLSearch":
                quickHelpMessage.stringValue = "Locate your 'Assets.xcassets' folder in your Xcode project to include automatically."
            default:
                quickHelpMessage.stringValue = ""
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        quickHelpMessage.stringValue = ""
    }
    
    override func awakeFromNib() {
        if let layer = self.view.layer {
            let colour = CGColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            layer.backgroundColor = colour
        }
    }
    
    func showAlert(message: String, isHidden: Bool = true) {
        errorLabel.stringValue = message
        errorLabel.isHidden = isHidden
        if isHidden == false {
            shakeWindow()
        }
    }
    
    func shakeWindow() {
        let numberOfShakes:Int = 6
        let durationOfShake:Float = 0.2
        let vigourOfShake:Float = 0.01
        
        let frame:CGRect = (self.view.window!.frame)
        let shakeAnimation = CAKeyframeAnimation()
        
        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: NSMinX(frame), y: NSMinY(frame)))
        
        for _ in 1...numberOfShakes {
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) - frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x:NSMinX(frame) + frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
        }
        
        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        self.view.window?.animations = ["frameOrigin":shakeAnimation]
        self.view.window?.animator().setFrameOrigin((self.view.window?.frame.origin)!)
    }
    
    @IBAction func deviceSelected(_ sender: NSButton) {
        
        // TODO: Draw border around button when selected - currently not obvious when device is selected/unselected
        
        switch sender.tag {
        case DeviceTag.aWatch.rawValue:
            //print(DeviceName.aWatch)
            break
            
        case DeviceTag.iPhone.rawValue:
            if sender.state == NSControlStateValueOn {
                devices.append(deviceList.iPhone)
            } else {
                if let index = devices.index(where: { $0.name == DeviceName.iPhone} ) {
                    devices.remove(at: index)
                }
                // If iOS devices exists, add iPad
                if devices.contains(where: { $0.name == DeviceName.iOS} ) {
                    devices.append(deviceList.iPad)
                }
            }
            
        case DeviceTag.iPad.rawValue:
            if sender.state == NSControlStateValueOn {
                devices.append(deviceList.iPad)
            } else {
                if let index = devices.index(where: { $0.name == DeviceName.iPad} ) {
                    devices.remove(at: index)
                }
                // If iOS devices exists, add iPhone
                if devices.contains(where: { $0.name == DeviceName.iOS} ) {
                    devices.append(deviceList.iPhone)
                }
            }
            
        case DeviceTag.Mac.rawValue:
            //print(DeviceName.Mac)
            break
            
        case DeviceTag.AppleTV.rawValue:
            //print(DeviceName.AppleTV)
            break
            
        default:
            break
        }
        
        // Check if iPhone and iPad is selected, if so mutate devices
        devices = checkForiOS(devices)
        
        printDevices()
    }
    
    // Create single device for when both iPhone and iPad are selected
    func checkForiOS(_ devices:[Device]) -> [Device] {
        var mutableDevices = devices
        var previousDevice: Device? = nil
        
        for device in mutableDevices where device.name == DeviceName.iPad || device.name == DeviceName.iPhone {
            // Check if we have already passed an iOS device
            if (device.name == DeviceName.iPad && previousDevice?.name == DeviceName.iPhone) || (device.name == DeviceName.iPhone && previousDevice?.name == DeviceName.iPad) {
                // Remove iPad & iPhone devices to mutable devices object
                if let index = mutableDevices.index(where: { $0.name == DeviceName.iPhone} ) {
                    mutableDevices.remove(at: index)
                }
                if let index = mutableDevices.index(where: { $0.name == DeviceName.iPad} ) {
                    mutableDevices.remove(at: index)
                }
                // Append devices with iOS device
                mutableDevices.append(deviceList.iOS)
                return mutableDevices
            } else {
                // Let's first remove the iOS devices in case only 1 iOS device is selected
                if let index = mutableDevices.index(where: { $0.name == DeviceName.iOS} ) {
                    mutableDevices.remove(at: index)
                }
            }
            // If its the first iOS device, store it and wait for another...
            previousDevice = device
        }
        return mutableDevices
    }
    
    func printDevices() {
        var str: String = "Devices Selected: "
        for device in devices {
            str = str + "\(device.name),"
        }
        if devices.count == 0 {
            str = str + "None "
        }
        str = str.substring(to: str.index(before: str.endIndex))
        devicesLabel.stringValue = str
        if DEBUG { print(str) }
    }
    
    
    @IBAction @objc func searchURLButtonPressed(_ sender: NSButton) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false // only folders
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        // It is modal so there is no title
        //panel.title = "Select an Assets.xcassets folder to replace"
        
        panel.beginSheetModal(for: window) { [unowned self] (result) in
            if result == NSFileHandlingPanelOKButton {
                let selectedPath = panel.urls[0].path
                self.errorMessage = ""
                
                // Check correct folder is selected - 'Assets.xcassets'
                if self.pathIsCorrect(selectedPath) {
                    // Update property
                    self.path = selectedPath as NSString
                    // Update UI
                    DispatchQueue.main.async {
                        self.outputURLTextField.stringValue = selectedPath
                    }
                } else {
                    self.errorMessage = "Error: Bad filepath"
                }
                
                // TODO: Textfield shows end of path (not beginning), similar to scroll to end
            } else {
                self.errorMessage = ""
            }
        }
    }
    
    func pathIsCorrect(_ path: String) -> Bool {
        
        let count = File.assetsBundle.count
        let string = path.substring(from: path.index(path.endIndex, offsetBy: -count))
        if string == File.assetsBundle {
            return true
        }
        return false
        
    }
    
    
    @IBAction func exportAction(_ sender: AnyObject) {
        
        guard let _ = inputImage else {
            errorMessage = "Error: Nothing to export..."
            return
        }
        
        guard devices.count > 0 else {
            errorMessage = "Error: No devices selected..."
            return
        }
        
        // Create template Contents.json for selected devices
        assetBundle = AssetBundleJSON(devices: devices)
        
        // Create mutatable devices object
        var mutableDevices = devices

        // Iterate through each device
        for var mutableDevice in mutableDevices {
            
            // Default to "Desktop" -> EAB/device/Assets
            var subfolderPath = "\(File.parentFolder)/\(mutableDevice.name.rawValue)/\(File.assetsBundle)"
            if path != File.desktop {
                // TODO: Warn user that only 1 devices can be selected (except iOS)
                if devices.count > 1 {
                    errorMessage = "Error: Multiple devices selected"
                    return
                }
                
                // Overwrite bundle -> XcodeProject/Assets
                subfolderPath = ""
            }
            
            // Make sure our parent directory is created -> Assets.xcassets
            let assetsURL = baseURL.appendingPathComponent(subfolderPath)
            // Create the AppIcon.appiconset
            let appIconsURL = assetsURL.appendingPathComponent(File.appIconFolder)
            if createFolderStructureFor(url: appIconsURL) {
                
                // Set the assetsURL on the device object
                mutableDevice.assetsURL = assetsURL
                
                // Process image into the desired icon sizes
                if processImageForDevice(mutableDevice, in: appIconsURL) {
                    if DEBUG { print("Folder populated with images: ", appIconsURL.path) }
                } else {
                    errorMessage = "Error: Failed to create all images"
                    // Clean up: remove created directories and return to original
                }
                
            }
            
            // Append devices to mutable devices object
            if let index = mutableDevices.index(where: { $0.name == mutableDevice.name} ) {
                mutableDevices.remove(at: index)
            }
            mutableDevices.append(mutableDevice)
        }
        
        // Replace the devices object with the mutated version
        devices = mutableDevices
        
        // Save the mutated Contents.json
        assetBundle?.saveAssetsBundleFor(devices: devices)
        
        // Update Error Message
        errorMessage = "Success"
        errorLabel.textColor = NSColor.green
    }
    
    func createFolderStructureFor(url: URL) -> Bool {
        
        // Check the AppIcon.appiconset already exist as we want to overwrite it
        do {
            if fm.fileExists(atPath: url.path) {
                if DEBUG { print("Folder already exists, overwriting...") }
                // TODO: Prompt user to overwrite..? (can do this before they select a path as default will be desktop)
                
                // Delete file
                try fm.removeItem(atPath: url.path)
                if DEBUG { print("Removed items at path: ", url.path) }
                
                // TODO: Store old Assets incase this fails?
                
            } else {
                if DEBUG { print("Folder does not exist, create it...") }
            }
            
            
            // Create the path to the Assets.xcassets bundle...
            do {
                try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                if DEBUG { print("Folder created: \(url)") }
                return true
            } catch let error as NSError {
                print("Fatal Error: Could not create folder structure - \(error.description)")
                return false
            }
        }
        catch let error as NSError {
            print("Fatal Error: Could not create folder structure - \(error.description)")
            return false
        }
    }
    
    
    func processImageForDevice(_ device:Device, in url: URL) -> Bool {
        
        // TODO: Update this error check...
        var count: Int = 0
        let total: Int = device.size.count
        
        for size in device.size {
            let filename = "\(size.filename).png"
            let imageURL = url.appendingPathComponent(filename)
            
            let resolution = NSSize(width: size.resolution.pixels, height: size.resolution.pixels)
            if let image = inputImage?.resized(to: resolution) {
                if saveImageToURL(image, url: imageURL) {
                    
                    //
                    // Updating JSON...
                    //
                    updateAssetsBundleFor(device, given:size, and: filename)
                    
                }
            } else {
                print("Could not create image for: \(device.name), \(size)")
            }
            // Update count of processed images
            count += 1
        }
        
        // TODO: This is not a good error checker.
        // We should still save what images are processed correctly
        // Just leave a warning of what resolutions did not succeed
        return (count == total) ? true : false
    }
    
    func updateAssetsBundleFor(_ device: Device, given size:Size, and filename: String) {
        // Get properties
        let idiom = device.name.rawValue.lowercased()
        var sizeString = "\(Int(size.resolution.pixel))x\(Int(size.resolution.pixel))"
        // Catch cases that are not int
        if size.resolution.pixel == 83.5 {
            sizeString = "\(size.resolution.pixel)x\(size.resolution.pixel)"
        }
        let scale = "\(Int(size.resolution.scale))x"
        
        if let assetBundlesValue = assetBundle?.assets[device.name.rawValue]?.images {
            // Immutable
            //assetBundlesValue.filter ({ $0.idiom == idiom }).first?.filename = filename
            
            // The Model objects are Structs not Classes, hence are passed by value not reference
            // This means we cannot use filter() as it is an immutable copy, instead we must use map()
            
            // Mutable
            assetBundle?.assets[device.name.rawValue]?.images = assetBundlesValue.map{
                var mutableAssetBundlesValue = $0
                // Catch 'iOS Devices' -> idiom = 'iphone' || 'ipad'
                if idiom == DeviceName.iOS.rawValue.lowercased() {
                    if $0.idiom == "iphone" || $0.idiom == "ipad" {
                        if $0.scale == scale && $0.size == sizeString {
                            mutableAssetBundlesValue.filename = filename
                        }
                    }
                } else {
                    // Single device
                    if $0.idiom == idiom && $0.scale == scale && $0.size == sizeString {
                            mutableAssetBundlesValue.filename = filename
                    }
                }
                
                // TODO: Check device as this idiom will change for non iOS
                if $0.idiom == "ios-marketing" && $0.scale == scale && $0.size == sizeString {
                    mutableAssetBundlesValue.filename = filename
                }
                return mutableAssetBundlesValue
            }
        }
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
                print("Error: Could not save image: \(error.description)")
            }
        }
        print("Error: saveImageToPath() -> could not create data")
        return false
    }
}


//
// MARK: - DestinationViewDelegate
//
extension ImageViewController: DestinationViewDelegate {
    
    func processImageURL(_ url: URL) {
        // Create an Image with the contents of the URL
        if let image = NSImage(contentsOf: url) {
            
            // Reset UI
            errorMessage = ""
            errorLabel.textColor = NSColor.red
            
            // TODO: Error Check!
            //print(infoAbout(url: url))
            
            // Apple App Icon Attributes
            // All app icons must adhere to these specifications
            // https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/#color-management
            // Format = PNG
            // Color Space = sRGB or P3 -> see Apples documentation
            // Layers = Flattened, no transparency
            // Resolution = Ideal(1536), Min(1024)?
            // Shape = Square, no rounded corners
            
            // Ensure correct resolution
            if let tiff = image.tiffRepresentation {
                if let imageRep = NSBitmapImageRep(data: tiff) {
                    guard imageRep.pixelsWide == 1024, imageRep.pixelsHigh == 1024 else {
                        errorMessage = "Error: Image resolution too low, please submit a 1024x1024 image"
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
            // TODO: When image is added, the parent does not have maskToBounds = true. The image have square edges rather than rounded...
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

class RoundedTextFieldCell: NSTextFieldCell {
    
    @IBInspectable var borderColor: NSColor = .clear
    @IBInspectable var cornerRadius: CGFloat = 3
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        let bounds = NSBezierPath(roundedRect: cellFrame, xRadius: cornerRadius, yRadius: cornerRadius)
        bounds.addClip()
        super.draw(withFrame: cellFrame, in: controlView)
        if borderColor != .clear {
            bounds.lineWidth = 1
            borderColor.setStroke()
            bounds.stroke()
        }
    }
}

