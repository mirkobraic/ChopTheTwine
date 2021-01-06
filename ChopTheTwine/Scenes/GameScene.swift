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
    
    private let openMouthTresh: CGFloat = 170
    private var areCrocMouthOpen = false
    
    private var isLevelOver = false
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupCrocodile()
        setupPrize()
        setupVines()
    }
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
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
    
    private func setupPrize() {
        prize = SKSpriteNode(imageNamed: Images.prize)
        prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        prize.zPosition = Layers.prize
        let prizeTexture = SKTexture(imageNamed: Images.prizeMask)
        prize.physicsBody = SKPhysicsBody(texture: prizeTexture, size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5

        addChild(prize)
    }
    
    private func setupVines() {
        let decoder = PropertyListDecoder()
        
        guard let dataFile = Bundle.main.url(forResource: GameConfiguration.vineDataFile, withExtension: nil) else { return }
        guard let data = try? Data(contentsOf: dataFile) else { return }
        guard let vines = try? decoder.decode([VineData].self, from: data) else { return }
        
        for (i, vineData) in vines.enumerated() {
            let anchorX = vineData.relAnchorPoint.x * size.width
            let anchorY = vineData.relAnchorPoint.y * size.height
            let anchorPoint = CGPoint(x: anchorX, y: anchorY)
            
            let vine = VineNode(length: vineData.length, anchorPoint: anchorPoint, name: "\(i)")
            
            vine.addToScene(self)
            vine.attachToPrize(prize)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check if vine is cut
            scene?.physicsWorld.enumerateBodies(
                alongRayStart: startPoint,
                end: endPoint,
                using: { body, _, _, _ in
                    self.checkIfVineIsCut(withBody: body)
                })
            
            // TODO: add effect
        }
    }
    
    private func checkIfVineIsCut(withBody body: SKPhysicsBody) {
        let node = body.node!
        
        // if it has a name it must be a vine node
        guard let name = node.name else { return }
        
        node.removeFromParent()
        // fade out all nodes matching name
        enumerateChildNodes(withName: name, using: { node, _ in
            let fadeAway = SKAction.fadeOut(withDuration: 0.25)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeAway, removeNode])
            node.run(sequence)
        })
    }
    
    private func setCrocMouth(open: Bool) {
        // don't set texture if not needed
        guard areCrocMouthOpen != open else { return }
        
        areCrocMouthOpen = open
        if open {
            crocodile.texture = SKTexture(imageNamed: Images.crocMouthOpen)
        } else {
            crocodile.texture = SKTexture(imageNamed: Images.crocMouthClosed)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isLevelOver == false else { return }
        
        let distance = prize.position.distance(toPoint: crocodile.position)
        if distance < openMouthTresh {
            setCrocMouth(open: true)
        } else {
            setCrocMouth(open: false)
        }
        print(distance)
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            
            // shrink the pineapple away
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([shrink, removeNode])
            prize.run(sequence)
            
            isLevelOver = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                self.setCrocMouth(open: false)
            }
        }
    }
}
