//
//  GameView.swift
//  project
//
//  Created by Junhao Zeng on 2019/1/19.
//  Copyright © 2019 Junhao Zeng. All rights reserved.
//

import Cocoa
import SpriteKit

class GameView: SKView {

    let gameScene = GameScene(size: CGSize(width: 1005, height: 30))
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func initScene() {
        self.presentScene(gameScene)
    }
}
