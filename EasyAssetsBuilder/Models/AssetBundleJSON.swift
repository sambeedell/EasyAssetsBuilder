//
//  AssetBundleJSON.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

class AssetBundleJSON: NSObject {

    var info: Content?
    var assets: [String:AssetBundle] = [:] {
        didSet {
            print("something changed...")
        }
    }
    
    // Devices available: iPhone, iPad, Mac, AppleTV, AppleWatch
    
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
        
        //print(self.parentJSON ?? "Empty...")
        
        for device in devices {
            if let data = self.jsonForDevice(device.name), checkValidity(jsonData: data) {
                do {
                    let deviceAssetBundle = try decoder.decode(AssetBundle.self, from: data)
                    self.assets[device.name.rawValue] = deviceAssetBundle
                } catch let err {
                    print(err)
                }
            }
        }
    }
    
    func jsonForDevice( _ device: DeviceName) -> Data? {
        
        var filepath = ""
        
        switch device {
        case .iPhone:
            filepath = "/iOS/\(filename)"
        case .iPad:
            filepath = "/iOS/\(filename)"
        case .Mac:
            filepath = "/Mac/\(filename)"
        case .Watch:
            break
            //filepath = ""
        case .tvOS:
            break
            //filepath = ""
//        default:
//            return [:]
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
    
    func saveAssetsBundleFor(devices:[Device], in infoURL: URL, and assetsURL: URL) {
        let jsonEncoder = JSONEncoder()
        
        for device in devices {
            
            // the filepath will change dependant on the device...
            
            // Info
            do {
                let data = try jsonEncoder.encode(info)
                saveJSON(data:data, to: infoURL.appendingPathComponent(filename))
            } catch let err {
                print(err)
            }
            
            // Assets
            do {
                let data = try jsonEncoder.encode(assets[device.name.rawValue])
                saveJSON(data:data, to: assetsURL.appendingPathComponent(filename))
            } catch let err {
                print(err)
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
