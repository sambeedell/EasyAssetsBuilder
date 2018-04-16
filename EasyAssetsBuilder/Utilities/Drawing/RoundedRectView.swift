//
//  RoundedRectView.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//

import Cocoa

class RoundedRectView: NSView {
    
    let radius: CGFloat = 10.0

    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)

        // Drawing code here.
        let path = NSBezierPath(roundedRect: NSInsetRect(bounds, radius, radius), xRadius: radius, yRadius: radius)
        NSColor.white.set()
        path.fill()
    }
    
}
