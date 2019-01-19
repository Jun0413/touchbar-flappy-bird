//
//  ViewController.swift
//  project
//
//  Created by Junhao Zeng on 2019/1/18.
//  Copyright © 2019 Junhao Zeng. All rights reserved.
//

import Cocoa
import SpriteKit

struct Constants {
    static let touchBarWidth:CGFloat = 1005.0
    static let backgroundColor = NSColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
}

class ViewController: NSViewController {
    
    let gameView: NSView = NSView()
    let gameSKView = GameView()
    let mainTapReceiverButton = NSButton(title: " ", target: self, action: #selector(tap))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupGameView()
        setupMainTapReceiverButton()
    }
    
    @objc func tap() {
        gameSKView.gameScene.jump()
    }
    
    func setupGameView() {
        
        // Fix width
        gameSKView.translatesAutoresizingMaskIntoConstraints = false
        let c1 = NSLayoutConstraint(item: gameView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constants.touchBarWidth)
        // Constraints to sides
        let c2 = NSLayoutConstraint(item: gameSKView, attribute: .leading, relatedBy: .equal, toItem: gameView, attribute: .leading, multiplier: 1.0, constant: 0)
        let c3 = NSLayoutConstraint(item: gameSKView, attribute: .trailing, relatedBy: .equal, toItem: gameView, attribute: .trailing, multiplier: 1.0, constant: 0)
        let c4 = NSLayoutConstraint(item: gameSKView, attribute: .top, relatedBy: .equal, toItem: gameView, attribute: .top, multiplier: 1.0, constant: 0)
        let c5 = NSLayoutConstraint(item: gameSKView, attribute: .bottom, relatedBy: .equal, toItem: gameView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        gameView.addConstraints([c1, c2, c3, c4, c5])
        
        gameView.wantsLayer = true
        gameView.layer?.backgroundColor = Constants.backgroundColor.cgColor
        
        gameSKView.initScene()
        
        gameView.addSubview(gameSKView)
        gameView.addSubview(mainTapReceiverButton)
    }
    
    func setupGameViewOnAppear() {
        
        if let touchBarView = gameView.superview {
            
            // Constraints to sides
            let c1 = NSLayoutConstraint(item: gameView, attribute: .leading, relatedBy: .equal, toItem: touchBarView, attribute: .leading, multiplier: 1.0, constant: 0)
            let c2 = NSLayoutConstraint(item: gameView, attribute: .trailing, relatedBy: .equal, toItem: touchBarView, attribute: .trailing, multiplier: 1.0, constant: 0)
            let c3 = NSLayoutConstraint(item: gameView, attribute: .top, relatedBy: .equal, toItem: touchBarView, attribute: .top, multiplier: 1.0, constant: 0)
            let c4 = NSLayoutConstraint(item: gameView, attribute: .bottom, relatedBy: .equal, toItem: touchBarView, attribute: .bottom, multiplier: 1.0, constant: 0)
            
            touchBarView.addConstraints([c1, c2, c3, c4])
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.setupGameView()
            })
        }
    }
    
    func setupMainTapReceiverButton() {
        mainTapReceiverButton.isTransparent = true
        mainTapReceiverButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints to sides
        let c1 = NSLayoutConstraint(item: mainTapReceiverButton, attribute: .leading, relatedBy: .equal, toItem: gameView, attribute: .leading, multiplier: 1.0, constant: 0)
        let c2 = NSLayoutConstraint(item: mainTapReceiverButton, attribute: .trailing, relatedBy: .equal, toItem: gameView, attribute: .trailing, multiplier: 1.0, constant: 0)
        let c3 = NSLayoutConstraint(item: mainTapReceiverButton, attribute: .top, relatedBy: .equal, toItem: gameView, attribute: .top, multiplier: 1.0, constant: 0)
        let c4 = NSLayoutConstraint(item: mainTapReceiverButton, attribute: .bottom, relatedBy: .equal, toItem: gameView, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        gameView.addConstraints([c1, c2, c3, c4])
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

@available(OSX 10.12.2, *)
extension ViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .gameBar
        touchBar.defaultItemIdentifiers = [.gameItem]
        touchBar.customizationAllowedItemIdentifiers = [.gameItem]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.gameItem:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = gameView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.setupGameView()
            })
            return customViewItem
        default:
            return nil
        }
    }
}

extension NSTouchBar.CustomizationIdentifier {
    static let gameBar = NSTouchBar.CustomizationIdentifier("hacknroll2019.project.GameBar")
}

extension NSTouchBarItem.Identifier {
    static let gameItem = NSTouchBarItem.Identifier("hacknroll2019.project.GameBar.main")
}
