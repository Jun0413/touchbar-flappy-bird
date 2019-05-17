//  Modified based on TouchBarDino by yuhuili
//  Granted by MIT License

import Cocoa
import SpriteKit

class GameView: SKView {

    let gameScene = GameScene(size: CGSize(width: 750, height: 30))
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
    func initScene() {
        self.presentScene(gameScene)
    }
}
