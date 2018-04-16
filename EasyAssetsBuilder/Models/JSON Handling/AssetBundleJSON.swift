//
//  AssetBundleJSON.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//
/* Description:
 
 This class imports the default JSON files required to build the asset bundle
 iPhone and iPad share the same 'Contents.json'
 The remaining devices have thier own specified files
 These files are added to the 'assets' property
 
 'info' contains details about the xcode project and must match the 'info' value in the 'assets' JSON
 
 */

import Cocoa

class AssetBundleJSON: NSObject {

    // TODO: I can probably remove this...
    // Warning: The info much match the info in the assets
    var info: Content?
    var assets: [String:AssetBundle] = [:]
    
    // Devices available: iPhone, iPad, Mac, AppleTV, AppleWatch
    // Devices programmed: iPhone, iPad, Mac
    
    // TODO: Move to File object?
    fileprivate let docsPath = Bundle.main.resourcePath! + "/Default JSON"
    fileprivate let fileManager = FileManager.default
    fileprivate let filename = "Contents.json"
    
    
    init(devices: [Device]) {
        super.init()
        
        let decoder = JSONDecoder()
        do {
            if let data = self.jsonForResource("/\(filename)"), checkValidity(jsonData: data) {
                self.info = try decoder.decode(Content.self, from: data)
            }
        } catch let err {
            print(err)
        }
        
        for device in devices {
            if let data = self.jsonForDevice(device.name), checkValidity(jsonData: data) {
                do {
                    let deviceAssetBundle = try decoder.decode(AssetBundle.self, from: data)
                    self.assets[device.name.rawValue] = deviceAssetBundle
                } catch let err {
                    print(err)
                }
            }
            print("\(device.name) - Contents.json created")
        }
    }
    
    
    
    func jsonForDevice( _ device: DeviceName) -> Data? {
        
        var filepath = ""
        
        switch device {
        case .aWatch:
            break
        case .iPhone, .iPad, .iOS:
            filepath = "/iOS/\(filename)"
        case .Mac:
            filepath = "/Mac/\(filename)"
        case .AppleTV:
            break
        }
        
        return jsonForResource(filepath)
    }
    
    func jsonForResource(_ resource: String) -> Data? {
        
        // Check the resources exist
        do {
            let _ = try fileManager.contentsOfDirectory(atPath: docsPath)
            //print(docsArray)
        } catch {
            print(error)
            // TODO: Handle Error
            return nil
        }
        
        // Create a path to the resource
        let resourcePath = docsPath + resource
        
        // Get the JSON object
        do {
            let jsonData = try Data.init(contentsOf: URL(fileURLWithPath: resourcePath))
            return jsonData
        } catch { print(error) }
        print("Error: Bad JSON")
        return nil
    }
    
    func saveAssetsBundleFor(devices:[Device]) {
        let jsonEncoder = JSONEncoder()
        
//        // Create mutable copy
//        var totalDevices = devices
//
//        //print(devices)
//
//        // Check for if iPhone & iPad is selected...
//        if checkForiOS(devices) {
//            // If they are both selected, merge the assets and remove one of the devices
//            // This will ensure only a single info and assets Content.json is written
//            totalDevices = mergeAssetsForiOS(devices)
//        }
        
        for device in devices {
            
            // TODO: the filepath must change dependant on the device...
            if let url = device.assetsURL {
        
                // Info
                do {
                    let data = try jsonEncoder.encode(info)
                    saveJSON(data:data, to: url.appendingPathComponent(filename))
                } catch let err {
                    print(err)
                }
                
                // Assets
                let appIconURL = url.appendingPathComponent(File.appIconFolder)
                do {
                    let data = try jsonEncoder.encode(assets[device.name.rawValue])
                    saveJSON(data:data, to: appIconURL.appendingPathComponent(filename))
                } catch let err {
                    print(err)
                }
            }
        }
    }
    
    func saveJSON(data:Data, to url:URL) {
        do {
            try data.write(to: url)
            print("JSON data written successfully to \(url)")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
}

extension AssetBundleJSON {
    func checkValidity(jsonData:Data) -> Bool {
        do { let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            // Check JSON is valid
            if JSONSerialization.isValidJSONObject(jsonObject) ? true : false {
                //print(jsonObject)
                return true
            }
        } catch { print(error) }
        return false
    }
}
