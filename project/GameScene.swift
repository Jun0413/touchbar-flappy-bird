//  Modified based on TouchBarDino by yuhuili
//  Granted by MIT License

import Cocoa
import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Edge: UInt32 = 0b1
    static let Character: UInt32 = 0b10
    static let Collider: UInt32 = 0b100
    static let Obstacle: UInt32 = 0b1000
}

struct GameLevel {
    static let initspawnDistance: Int = 80
    static let initobstacleVelocity: Int = 80
    static let finspawnDistance: Int = 30
    static let finobstacleVelocity: Int = 130
    static var spawnDistance: Int?
    static var obstacleVelocity: Int?
}

let touchBarWidth = 750

class GameScene: SKScene, SKPhysicsContactDelegate {

    var sceneCreated = false
    var gameStarted = false
    var canJump = false
    var shouldSpawnObstacle = false
    var shouldUpdateScore = false

    let gameFontColor = SKColor(red: 83/255.0, green: 83/255.0, blue: 83/255.0, alpha: 1)
    
    let titleNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    let subtitleNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    let birdSpriteNode = SKSpriteNode(imageNamed: "BirdSprite")
    let ground: SKPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x:0, y:0, width: touchBarWidth, height:30))

    var currentScore = 0
    
    var gameNo:Int = 1
    var scoreboardCallback:((String)->Void)?
    var bestscoreCallback:((Bool)->Void)?
    var canStart = true
    var backgroundSound = SKAudioNode(fileNamed: "flappy_bgm.mp3")
    let wingSound = SKAction.playSoundFileNamed("flappy_wing.mp3", waitForCompletion: false)
    let hitSound = SKAction.playSoundFileNamed("flappy_hit.mp3", waitForCompletion: false)
    let updateScoreWaiting:Double = 6.6 // second
    
    override func didMove(to view: SKView) {
        if !sceneCreated {
            sceneCreated = true
            createSceneContents()
        }
    }
    
    func startGame() {
        
        bestscoreCallback!(true) // hide best score
        
        srand48(Int(arc4random()))
        self.removeChildren(in: [backgroundSound])
        
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                self.removeChildren(in: [node])
            }
        }
        
        initGameLevel(spawnDistance: GameLevel.initspawnDistance,
                      obstacleVelocity: GameLevel.initobstacleVelocity)
        
        gameStarted = true
        canJump = true
        currentScore = -1
        shouldUpdateScore = true
        
        scoreboardCallback!("0000000")
        DispatchQueue.main.asyncAfter(deadline: .now() + self.updateScoreWaiting, execute: {
            self.updateScore()
        })

        titleNode.isHidden = true
        subtitleNode.isHidden = true
        titleNode.text = "You lose"
        subtitleNode.text = "Touch to retry..."
        self.shouldSpawnObstacle = true
        self.spawnObstacle(assignedGameNo: self.gameNo)
    }
    
    func createSceneContents() {

        self.addChild(backgroundSound)
        self.addChild(background())
        self.addChild(titleLabel())
        self.addChild(subtitleLabel())
        self.addChild(birdSprite())
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.lightGray
        //self.scaleMode = .aspectFit
        
        self.physicsBody = ground
        ground.categoryBitMask = PhysicsCategory.Edge | PhysicsCategory.Collider
        ground.contactTestBitMask = PhysicsCategory.Character
        ground.friction = 0
        ground.restitution = 0
        ground.linearDamping = 0
        ground.angularDamping = 1
        ground.isDynamic = false
        ground.affectedByGravity = false
        ground.allowsRotation = false
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1)

        self.spawnObstacle(assignedGameNo: self.gameNo)
    }
    
    func titleLabel() -> SKLabelNode {
        titleNode.text = "Flappy Bird"
        titleNode.fontSize = 10
        titleNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        titleNode.fontColor = gameFontColor
        titleNode.zPosition = 50
        
        return titleNode
    }
    
    func subtitleLabel() -> SKLabelNode {
        subtitleNode.text = "Touch to start..."
        subtitleNode.fontSize = 7
        subtitleNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY-10)
        subtitleNode.fontColor = gameFontColor
        subtitleNode.zPosition = 50
        
        return subtitleNode
    }
    
    func birdSprite() -> SKSpriteNode {
        birdSpriteNode.setScale(0.5)
        birdSpriteNode.position = CGPoint(x: 20, y: birdSpriteNode.size.height/2)
        birdSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: birdSpriteNode.size)
        if let pb = birdSpriteNode.physicsBody {
            pb.isDynamic = true
            pb.affectedByGravity = true
            pb.allowsRotation = false
            pb.categoryBitMask = PhysicsCategory.Character
            pb.collisionBitMask = PhysicsCategory.Edge
            pb.contactTestBitMask = PhysicsCategory.Collider
            pb.restitution = 0
            pb.friction = 1
            pb.linearDamping = 1
            pb.angularDamping = 1
        }
        return birdSpriteNode
    }
    
    func background() -> SKSpriteNode {
        let background = SKSpriteNode(imageNamed: "backgroundImg")
        background.size = CGSize(width: touchBarWidth, height: 30)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        return background
    }
    
    func endGame() {
        
        var filename:String = "flappy_failed.mp3"
        var filelength:Double = 3.5
        
        if updateBestScore(score: currentScore) {
            // update windows UI
            // first score not shown up
            print("##### Best score ##### \(currentScore)")
            bestscoreCallback!(false)
            filename = "bestscore.mp3"
            filelength = 2.0
        }
        
        self.gameNo += 1

        titleNode.isHidden = false
        subtitleNode.isHidden = false
        
        canStart = false
        canJump = false
        shouldSpawnObstacle = false
        gameStarted = false
        shouldUpdateScore = false
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                node.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.backgroundSound = SKAudioNode(fileNamed: filename)
            self.addChild(self.backgroundSound)
            DispatchQueue.main.asyncAfter(deadline: .now() + filelength, execute: {
                self.removeChildren(in: [self.backgroundSound])
                self.canStart = true
            })
        })
    }
    
    func jump() {
        
        if !gameStarted && canStart {
            startGame()
        }
        
        if !canJump {
            return
        }
        
        if let pb = birdSpriteNode.physicsBody {
            pb.applyImpulse(CGVector(dx:0, dy:0.07), at: birdSpriteNode.position)

            run(wingSound)
        }
    }
    
    func spawnObstacle(assignedGameNo:Int) {
        if self.shouldSpawnObstacle == false {
            return
        }
        
        let bottomOb = SKSpriteNode(imageNamed: "BottomPipe")
        let upperOb = SKSpriteNode(imageNamed: "upperPipe")
        let obWidth = Double(bottomOb.size.width)
        let heightDist = drand48()
        bottomOb.size=CGSize(width:obWidth, height: 15*heightDist)
        upperOb.size=CGSize(width:obWidth, height: 15 - 15*heightDist)
        bottomOb.position = CGPoint(x: 700, y: bottomOb.size.height/2)
        upperOb.position = CGPoint(x: 700, y: 30)
        bottomOb.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "BottomPipe"), size: bottomOb.size)
        upperOb.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "upperPipe"), size: upperOb.size)
        if let pb = bottomOb.physicsBody {
            pb.isDynamic = true
            pb.affectedByGravity = false
            pb.allowsRotation = false
            pb.categoryBitMask = PhysicsCategory.Obstacle
            pb.contactTestBitMask = PhysicsCategory.Character
            pb.collisionBitMask = 0
            pb.restitution = 0
            pb.friction = 0
            pb.linearDamping = 0
            pb.angularDamping = 0
            pb.velocity = CGVector(dx: -GameLevel.obstacleVelocity!, dy: 0)
        }
        if let bp = upperOb.physicsBody {
            bp.isDynamic = true
            bp.affectedByGravity = false
            bp.allowsRotation = false
            bp.categoryBitMask = PhysicsCategory.Obstacle
            bp.contactTestBitMask = PhysicsCategory.Character
            bp.collisionBitMask = 0
            bp.restitution = 0
            bp.friction = 0
            bp.linearDamping = 0
            bp.angularDamping = 0
            bp.velocity = CGVector(dx: -GameLevel.obstacleVelocity!, dy: 0)
        }
        self.addChild(bottomOb)
        self.addChild(upperOb)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
            if self.shouldSpawnObstacle {
                self.removeChildren(in: [bottomOb, upperOb])
            
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(GameLevel.spawnDistance!)/Double(GameLevel.obstacleVelocity!), execute: { //[%]
            if self.shouldSpawnObstacle == true && assignedGameNo == self.gameNo {
                self.spawnObstacle(assignedGameNo: assignedGameNo)
            }
        })

    }
    
    func updateScore() {
        updateLevel()

        currentScore += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if (self.shouldUpdateScore) {
                self.updateScore()
                self.scoreboardCallback?(String(format: "%07d", self.currentScore))
            }
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if !canStart {
            return
        }
        if (contact.bodyA == birdSpriteNode.physicsBody && contact.bodyB == ground) ||
            (contact.bodyB == birdSpriteNode.physicsBody && contact.bodyA == ground) {
            canJump = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if !canStart {
            return
        }
        if !((contact.bodyA == birdSpriteNode.physicsBody && contact.bodyB == ground) ||
            (contact.bodyB == birdSpriteNode.physicsBody && contact.bodyA == ground)) {
            run(hitSound)
            endGame()
        }
    }
    
    func logger() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            NSLog("Sprite at: %f, %f", self.birdSpriteNode.position.x, self.birdSpriteNode.position.y)
            self.logger()
        })
    }
    
    func receiveSbCallback(scoreboardCallback:@escaping (String)->Void) {
        self.scoreboardCallback = scoreboardCallback
    }
    
    func receiveBsCallback(bestscoreCallback:@escaping (Bool)->Void) {
        self.bestscoreCallback = bestscoreCallback
    }
    
    func initGameLevel(spawnDistance:Int, obstacleVelocity:Int) {
        GameLevel.spawnDistance = spawnDistance
        GameLevel.obstacleVelocity = obstacleVelocity
    }
    
    func updateLevel() {
        if GameLevel.spawnDistance! > GameLevel.finspawnDistance {
            GameLevel.spawnDistance! -= 1
        }
        if GameLevel.obstacleVelocity! < GameLevel.finobstacleVelocity {
            GameLevel.obstacleVelocity! += 1
        }
    }
    
    func updateBestScore(score:Int) -> Bool {
        print("updateBestScore called")
        let userDefaults = UserDefaults.standard
        var shouldUpdate = false
        if let bestScore:Int = userDefaults.object(forKey: "bestscore") as! Int? {
            if bestScore < score {
                shouldUpdate = true
                print("New best score")
            } else {
                print("New score less than best score")
            }
        } else {
            // initialize
            userDefaults.set(score, forKey: "bestscore")
            userDefaults.synchronize()
            print("initialize")
            return true
        }
        if shouldUpdate {
            userDefaults.set(score, forKey: "bestscore")
            userDefaults.synchronize()
            print("updating")
        }
        return shouldUpdate
    }
}
