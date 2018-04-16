//
//  DestinationView.swift
//  EasyAssetsBuilder
//
//  Created by Sam Beedell on 11/04/2018.
//  Copyright © 2018 Sam Beedell. All rights reserved.
//


import Cocoa

protocol DestinationViewDelegate {
    func processImageURL(_ url: URL)
    //    func processImageURL(_ url: URL, center: NSPoint)
    //    func processImage(_ image: NSImage, center: NSPoint)
    //    func processAction(_ action: String, center: NSPoint)
}

class DestinationView: NSView {
    
    enum Appearance {
        static let lineWidth: CGFloat = 10.0
        static let dashPattern: [CGFloat] = [ 20, 2 ]
        static let radius: CGFloat = 10.0
    }
    
    var delegate: DestinationViewDelegate?
    
    // Define supported file types (via thier URLs)
    var acceptableTypes: Set<String> { return [NSURLPboardType] }
    
    // Create listener for dragging session (action recieved)
    var isReceivingDrag = false {
        didSet {
            // Trigger a redraw
            needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup() {
        // Register the supported file types
        register(forDraggedTypes: Array(acceptableTypes))
    }
    
    // Create a Dictionary to define the desired URL types (images)
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]
    // NSDraggingInfo is a protocol that declares methods to supply information about the dragging session. You don’t create them, nor do you store them between events. The system creates the necessary objects during the dragging session.
    func shouldAllowDrag( _ draggingInfo: NSDraggingInfo) -> Bool {
        // Ask pasteboard if it has any URLs and whether those URLs are references to images. If it has images, accept the drag. Otherwise, reject it.
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
    }
    
    // Draw a system-colored border when a valid drag enters the view.
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.black.set()
            let radius = Appearance.radius
            
            // TODO: Tidy this UI
            let path = NSBezierPath(roundedRect: NSInsetRect(bounds, radius, radius), xRadius: radius, yRadius: radius)
            path.lineWidth = Appearance.lineWidth
            path.setLineDash(Appearance.dashPattern, count: Appearance.dashPattern.count, phase: 0.0)
            path.stroke()
        }
    }
    
    //we override hitTest so that this view which sits at the top of the view hierachy
    //appears transparent to mouse clicks
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
}

//
// MARK: - Protocols to handle drag action
//
extension DestinationView {
    
    // Entered NSView
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        // Either allow the image and copy it into the NSView or do not accept
        return allow ? .copy : NSDragOperation()
    }
    
    // Exited NSView
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    // Mouse released inside NSView
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // If accepted, the system removes the drag image and invokes the next method in the protocol sequence: performDragOperation(_:).
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    // Drag accepted in NSView
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        // Convert the window-based coordinate to a view-relative coordinate.
        let pasteBoard = sender.draggingPasteboard()
        //let point = convert(sender.draggingLocation(), from: nil)
        
        // TODO: Create animated drag sequence...
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL], // Must be array as [Any] is returned
            urls.count > 0 {
            // Ensure only a single image can be used
            if urls.count > 1 {
                Swift.print("Error: please drag one a single image")
                return false
            }
            if let url = urls.first {
                // Hand off image URL to the delegate for processing
                delegate?.processImageURL(url)
                return true
            }
            return false
        }
        return false
    }
}
