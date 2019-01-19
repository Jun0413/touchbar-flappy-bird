//
//  GameScene.swift
//  project
//
//  Created by Junhao Zeng on 2019/1/19.
//  Copyright © 2019 Junhao Zeng. All rights reserved.
//

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

class GameScene: SKScene, SKPhysicsContactDelegate {
    var sceneCreated = false
    var gameStarted = false
    var canJump = false
    var shouldSpawnObstacle = false
    var shouldUpdateScore = false
    
    let gameFontColor = SKColor(red: 83/255.0, green: 83/255.0, blue: 83/255.0, alpha: 1)
    
    let titleNode = SKLabelNode(fontNamed: "Courier")
    let subtitleNode = SKLabelNode(fontNamed: "Courier")
    let scoreNode = SKLabelNode(fontNamed: "Courier")
    let birdSpriteNode = SKSpriteNode(imageNamed: "BirdSprite")
    // let ground: SKPhysicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y:0), to: CGPoint(x:1005, y:0))
    let ground: SKPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x:0, y:0, width:1005, height:30))
    
    var currentScore = 0
    
    override func didMove(to view: SKView) {
        if !sceneCreated {
            sceneCreated = true
            createSceneContents()
        }
    }
    
    func startGame() {
        
        srand48(Int(arc4random()))
        
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                self.removeChildren(in: [node])
            }
        }
        
        gameStarted = true
        canJump = true
        currentScore = 0
        shouldUpdateScore = true
        updateScore()
        titleNode.isHidden = true
        subtitleNode.isHidden = true
        self.shouldSpawnObstacle = true
        self.spawnObstacle()
    }
    
    func createSceneContents() {
        self.addChild(titleLabel())
        self.addChild(subtitleLabel())
        self.addChild(birdSprite())
        self.addChild(scoreLabel())
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
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1) // [%]
        
        //self.logger()
        self.spawnObstacle()
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
        subtitleNode.text = "Touch anywhere to begin..."
        subtitleNode.fontSize = 7
        subtitleNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY-10)
        subtitleNode.fontColor = gameFontColor
        subtitleNode.zPosition = 50
        
        return subtitleNode
    }
    
    func scoreLabel() -> SKLabelNode {
        scoreNode.text = generateScore()
        scoreNode.fontSize = 13
        scoreNode.horizontalAlignmentMode = .right
        scoreNode.position = CGPoint(x: self.frame.maxX - 4, y:self.frame.midY + 2)
        scoreNode.fontColor = gameFontColor
        scoreNode.zPosition = 80
        
        return scoreNode
    }
    
    func generateScore() -> String {
        return String(format: "%07d", currentScore)
    }
    
    func birdSprite() -> SKSpriteNode {
        birdSpriteNode.setScale(0.5)
        birdSpriteNode.position = CGPoint(x: 20, y: birdSpriteNode.size.height/2) // [%]
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
    
    func endGame() {
        
        titleNode.isHidden = false
        subtitleNode.isHidden = false
        
        canJump = false
        shouldSpawnObstacle = false
        gameStarted = false
        shouldUpdateScore = false
        for node in self.children {
            if (node.physicsBody?.categoryBitMask == PhysicsCategory.Obstacle) {
                node.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }
    
    func jump() {
        
        if !gameStarted {
            startGame()
        }
        
        if !canJump {
            return
        }
        
        if let pb = birdSpriteNode.physicsBody {
            // dy = 8.8 initially
            // [%]
            pb.applyImpulse(CGVector(dx:0, dy:0.05), at: birdSpriteNode.position)
        }
    }
    
    func spawnObstacle() {
        if self.shouldSpawnObstacle == false {
            return
        }
        
        // let x = arc4random() % 3;
        
        let bottomOb = SKSpriteNode(imageNamed: "BottomPipe")
        let upperOb = SKSpriteNode(imageNamed: "upperPipe")
        // let obSize = CGFloat(0.5) // [%]
        let obWidth = Double(bottomOb.size.width)
        // bottomOb.setScale(obSize)
        // upperOb.setScale(obSize)
        let heightDist = drand48()
        bottomOb.size=CGSize(width:obWidth, height: 15*heightDist)
        upperOb.size=CGSize(width:obWidth, height: 15 - 15*heightDist)
        bottomOb.position = CGPoint(x: 1020, y: bottomOb.size.height/2)
        upperOb.position = CGPoint(x: 1020, y: 30)
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
            pb.velocity = CGVector(dx: -100, dy: 0)
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
            bp.velocity = CGVector(dx: -100, dy: 0)  //[%]
        }
        self.addChild(bottomOb)
        self.addChild(upperOb)

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
            if self.shouldSpawnObstacle {
                self.removeChildren(in: [bottomOb, upperOb])
            
            }
        })
        
        
        
        // let randDelay = drand48() * 0.3 - Double(currentScore) / 1000.0 //[%]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { //[%]
            if self.shouldSpawnObstacle == true {
                self.spawnObstacle()
            }
        })
    }
    
    func updateScore() {
        currentScore += 1
        scoreNode.text = generateScore()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if (self.shouldUpdateScore) {
                self.updateScore()
            }
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA == birdSpriteNode.physicsBody && contact.bodyB == ground) ||
            (contact.bodyB == birdSpriteNode.physicsBody && contact.bodyA == ground) {
            canJump = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
//        [%]
//        if (contact.bodyA == birdSpriteNode.physicsBody && contact.bodyB == ground) ||
//            (contact.bodyB == birdSpriteNode.physicsBody && contact.bodyA == ground) {
//            canJump = false
//        } else {
//            endGame()
//        }
        if !((contact.bodyA == birdSpriteNode.physicsBody && contact.bodyB == ground) ||
            (contact.bodyB == birdSpriteNode.physicsBody && contact.bodyA == ground)) {
            endGame()
        }
    }
    
    func logger() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            NSLog("Sprite at: %f, %f", self.birdSpriteNode.position.x, self.birdSpriteNode.position.y)
            self.logger()
        })
    }

}
