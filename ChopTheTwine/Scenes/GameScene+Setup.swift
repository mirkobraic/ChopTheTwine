//
//  GameScene+Setup.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 06/01/2021.
//

import SpriteKit
import AVFoundation

extension GameScene {
    func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
    }
    
    func setupBackground() {
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
        water.size = CGSize(width: size.width, height: waterHeight)
        addChild(water)
    }
    
    func setupLevel(levelData: LevelData) {
        setupCrocodile(at: levelData.crocodileLocation)
        setupPrize(at: levelData.prizeLocation)
        setupVines(fromAnchors: levelData.anchorLocations, toPrizeLocation: levelData.prizeLocation)
    }
    
    private func setupCrocodile(at location: CGPoint) {
        crocodile = SKSpriteNode(imageNamed: Images.crocMouthClosed)
        crocodile.position = location
        crocodile.zPosition = Layers.crocodile
        let crocodileTexture = SKTexture(imageNamed: Images.crocMask)
        crocodile.physicsBody = SKPhysicsBody(texture: crocodileTexture, size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.prize
        crocodile.physicsBody?.isDynamic = false

        addChild(crocodile)
    }
    
    private func setupPrize(at location: CGPoint) {
        prize = SKSpriteNode(imageNamed: Images.prize)
        prize.position = location
        prize.zPosition = Layers.prize
        let prizeTexture = SKTexture(imageNamed: Images.prizeMask)
        prize.physicsBody = SKPhysicsBody(texture: prizeTexture, size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5

        addChild(prize)
    }
    
    private func setupVines(fromAnchors anchors: [CGPoint], toPrizeLocation prizeLocation: CGPoint) {
        for (index, anchor) in anchors.enumerated() {
            let vine = VineNode(startPoint: anchor, finishPoint: prizeLocation, name: "\(index)")
            vine.addToScene(self)
            vine.attachToPrize(prize)
        }
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.fontSize = 20
        scoreLabel!.horizontalAlignmentMode = .left
        scoreLabel!.position = CGPoint(x: 50, y: 40)
        scoreLabel!.zPosition = Layers.score
        scoreLabel!.text = "Score: \(score)"
        addChild(scoreLabel!)
    }
    
    func setupSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = Layers.sliceBG
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 4
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = Layers.sliceFG
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 3
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func setupAudio() {
        if GameScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(
                forResource: SoundFile.backgroundMusic,
                withExtension: nil)
            
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                GameScene.backgroundMusicPlayer = theme
            } catch {
                print("Audio error: could not load a file!")
            }
            
            GameScene.backgroundMusicPlayer.numberOfLoops = -1
        }
        
        if !GameScene.backgroundMusicPlayer.isPlaying {
            GameScene.backgroundMusicPlayer.play()
        }
        
        sliceSoundAction = .playSoundFileNamed(SoundFile.slice, waitForCompletion: false)
        splashSoundAction = .playSoundFileNamed(SoundFile.splash, waitForCompletion: false)
        nomNomSoundAction = .playSoundFileNamed(SoundFile.nomNom, waitForCompletion: false)
    }
}
