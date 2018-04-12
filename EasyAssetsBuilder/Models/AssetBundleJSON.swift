//
//  AssetBundleJSON.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

class AssetBundleJSON: NSObject {

    var info: Info?
    var assets: [String:Asset] = [:]
    
    // Devices available: iPhone, iPad, Mac, AppleTV, AppleWatch
    
    fileprivate let docsPath = Bundle.main.resourcePath! + "/Default JSON"
    fileprivate let fileManager = FileManager.default
    
    init(devices: [Device]) {
        super.init()
        
        let decoder = JSONDecoder()
    
        do {
            if let data = self.jsonForResource("/Contents.json") {
                self.info = try decoder.decode(Info.self, from: data)
            }
        } catch let err {
            print(err)
        }
        
        //print(self.parentJSON ?? "Empty...")
        
        for device in devices {
            if let data = self.jsonForDevice(device.name) {
                do {
                    let deviceAssetBundle = try decoder.decode(Asset.self, from: data)
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
            filepath = "/iOS/Contents.json"
        case .iPad:
            filepath = "/iOS/Contents.json"
        case .Mac:
            filepath = "/Mac/Contents.json"
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
            /*
            do { let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                // Check JSON is valid
                if JSONSerialization.isValidJSONObject(jsonObject) ? true : false {
                    return jsonObject
                    //if let json = jsonObject as? [String:AnyObject] {
                    //    return json
                }   //}
            } catch { print(error) }
             */
        } catch { print(error) }
        print("Error: Bad JSON")
        return nil
    }
    
}
