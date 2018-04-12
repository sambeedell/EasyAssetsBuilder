//
//  JSONHandler.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

class JSONHandler: NSObject {

    var parentJSON: [String:AnyObject]?
    var assetsJSON: [[String:AnyObject]] = []
    
    // Devices available: iPhone, iPad, Mac, AppleTV, AppleWatch
    
    fileprivate let docsPath = Bundle.main.resourcePath! + "/Default JSON"
    fileprivate let fileManager = FileManager.default
    
    init(devices: [Device]) {
        super.init()
    
        self.parentJSON = self.jsonForResource("/Contents.json")
        //print(self.parentJSON ?? "Empty...")
        
        for device in devices {
            self.assetsJSON.append(self.resourceForDevice(device.name))
        }
        //print(self.assetsJSON)
    }
    
    func resourceForDevice( _ device: DeviceName) -> [String:AnyObject] {
        
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
        
        // Safely unwrap resource
        if let resource = jsonForResource(filepath) {
            print("JSON Parsed successfully for \(device)")
            return resource
        }
        // Return empty dictionary if no resource :(
        return [:]
    }
    
    func jsonForResource(_ resource: String) -> [String:AnyObject]? {
        
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
        do { let jsonData = try Data.init(contentsOf: URL(fileURLWithPath: resourcePath))
            do { let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                // Check JSON is valid
                if JSONSerialization.isValidJSONObject(jsonObject) ? true : false {
                    if let json = jsonObject as? [String:AnyObject] {
                        return json
                }   }
            } catch { print(error) }
        } catch { print(error) }
        print("Error: Bad JSON")
        return nil
    }
    
}
