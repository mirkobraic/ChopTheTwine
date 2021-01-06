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
    
    func setupCrocodile() {
        crocodile = SKSpriteNode(imageNamed: Images.crocMouthClosed)
        crocodile.position = CGPoint(x: size.width * CGFloat.random(in: 0.15...0.85), y: groundHeight)
        crocodile.zPosition = Layers.crocodile
        let crocodileTexture = SKTexture(imageNamed: Images.crocMask)
        crocodile.physicsBody = SKPhysicsBody(texture: crocodileTexture, size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.prize
        crocodile.physicsBody?.isDynamic = false
            
        addChild(crocodile)
    }
    
    func setupPrize() {
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
    
    func setupVines() {
        let decoder = PropertyListDecoder()
        
        guard let dataFile = Bundle.main.url(forResource: GameScene.currentLevel, withExtension: nil) else { return }
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
