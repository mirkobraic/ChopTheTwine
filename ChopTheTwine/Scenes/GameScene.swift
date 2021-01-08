//
//  GameScene.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 04/01/2021.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    static var backgroundMusicPlayer: AVAudioPlayer!
    static var staticScore = 0
    
    var score = GameScene.staticScore {
        didSet {
            scoreLabel?.text = "Score: \(score)"
            GameScene.staticScore = score
        }
    }
    
    var crocodile: SKSpriteNode!
    var prize: SKSpriteNode!
    var scoreLabel: SKLabelNode?
    
    var sliceSoundAction: SKAction!
    var splashSoundAction: SKAction!
    var nomNomSoundAction: SKAction!
    
    var waterHeight: CGFloat = 0
    var groundHeight: CGFloat = 0
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    let activeSliceTresh = 10
    
    private let openMouthTresh: CGFloat = 100
    private var areCrocMouthOpen = false
    
    private var isLevelOver = false
    
    override func didMove(to view: SKView) {
        waterHeight = size.height * 0.2139
        groundHeight = size.height * 0.308
        
        let levelParser = LevelParser()
        var levelData = levelParser.parseLevel(withName: GameLevelManager.shared.randomLevel(), screenSize: size, groundOffset: groundHeight)
        levelData.crocodileLocation.y = groundHeight
        
        setupPhysics()
        setupBackground()
        setupLevel(levelData: levelData)
        setupScoreLabel()
        setupSlices()
        setupAudio()
    }
    
    private func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > activeSliceTresh {
            activeSlicePoints.removeFirst(activeSlicePoints.count - activeSliceTresh)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
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
        
        run(sliceSoundAction)
    }
    
    private func fadeOutSlice() {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.22))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.22))
    }
    
    private func switchToNewGame(withTransition transition: SKTransition) {
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run {
            let scene = GameScene(size: self.size)
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene, transition: transition)
        }
        
        run(.sequence([delay, sceneChange]))
    }
    
    private func runWaterAnimation(at point: CGPoint) {
        let waterEmitter = SKEmitterNode(fileNamed: Particles.waterSplash)!
        waterEmitter.position = point
        addChild(waterEmitter)
        
        let wait = SKAction.wait(forDuration: 3)
        let destroy = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, destroy])
        waterEmitter.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        activeSlicePoints.append(touch.location(in: self))
        
        redrawActiveSlice()
        
        // important so we don't fight fadeOutSlice
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let startPoint = touch.location(in: self)
        let endPoint = touch.previousLocation(in: self)
        
        activeSlicePoints.append(startPoint)
        redrawActiveSlice()
        
        // check if vine is cut
        scene?.physicsWorld.enumerateBodies(
            alongRayStart: startPoint,
            end: endPoint,
            using: { body, _, _, _ in
                self.checkIfVineIsCut(withBody: body)
            })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        fadeOutSlice()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fadeOutSlice()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isLevelOver == false else { return }
        
        if prize.position.y <= waterHeight {
            run(splashSoundAction)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                self.setCrocMouth(open: false)
            }
            runWaterAnimation(at: CGPoint(x: prize.position.x, y: waterHeight))
            switchToNewGame(withTransition: .fade(withDuration: 0.8))
            isLevelOver = true
            GameScene.staticScore = 0
        }

        let distance = prize.position.distance(toPoint: crocodile.position)
        if distance < openMouthTresh {
            setCrocMouth(open: true)
        } else {
            setCrocMouth(open: false)
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard isLevelOver == false else { return }
        
        if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
            || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
            
            // shrink the pineapple away
            let move = SKAction.move(to: crocodile.position, duration: 0.10)
            let shrink = SKAction.scale(to: 0, duration: 0.08)
            let dissapearGroup = SKAction.group([move, shrink])
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([dissapearGroup, removeNode])
            prize.run(sequence)
            run(nomNomSoundAction)
            
            isLevelOver = true
            GameScene.staticScore += 1
            switchToNewGame(withTransition: .flipVertical(withDuration: 0.8))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                self.setCrocMouth(open: false)
            }
        }
    }
}
