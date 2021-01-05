//
//  GameScene.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 04/01/2021.
//

import SpriteKit

class GameScene: SKScene {
    private var crocodile: SKSpriteNode!
    private var prize: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        setupBackground()
        setupCrocodile()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: Images.background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layers.background
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)
        
        let water = SKSpriteNode(imageNamed: Images.water)
        water.anchorPoint = CGPoint(x: 0, y: 0)
        water.position = CGPoint(x: 0, y: 0)
        water.zPosition = Layers.foreground
        water.size = CGSize(width: size.width, height: size.height * 0.2139)
        addChild(water)
    }
    
    private func setupCrocodile() {
        crocodile = SKSpriteNode(imageNamed: Images.crocMouthClosed)
        crocodile.position = CGPoint(x: size.width * 0.75, y: size.height * 0.312)
        crocodile.zPosition = Layers.crocodile
        let crocodileTexture = SKTexture(imageNamed: Images.crocMask)
        crocodile.physicsBody = SKPhysicsBody(texture: crocodileTexture, size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.prize
        crocodile.physicsBody?.isDynamic = false
            
        addChild(crocodile)
    }
}
