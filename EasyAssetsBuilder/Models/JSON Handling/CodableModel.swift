//
//  CodableModel.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 13/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

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
