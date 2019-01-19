//
//  WindowController.swift
//  project
//
//  Created by Junhao Zeng, Zhenyuan Lu on 2019/1/18.
//  Copyright © 2019 Junhao Zeng, Zhenyuan Lu. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        guard let viewController = contentViewController as? ViewController else {
            return nil
        }
        return viewController.makeTouchBar()
    }
}
