//
//  VineNode.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 05/01/2021.
//

import UIKit
import SpriteKit

class VineNode: SKNode {
    private let length: Int
    private let anchorPoint: CGPoint
    private var vineSegments: [SKNode] = []
    
    init(startPoint: CGPoint, finishPoint: CGPoint, name: String) {
        anchorPoint = startPoint
        
        let vineSegmentSize: CGFloat = 8
        length = Int((startPoint.distance(toPoint: finishPoint) - 20) / vineSegmentSize)
        
        super.init()
        
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func addToScene(_ scene: SKScene) {
        zPosition = Layers.vine
        scene.addChild(self)
        
        // create vine holder
        let vineHolder = SKSpriteNode(imageNamed: Images.vineHolder)
        vineHolder.position = anchorPoint
        vineHolder.zPosition = Layers.vine
            
        addChild(vineHolder)
            
        vineHolder.physicsBody = SKPhysicsBody(circleOfRadius: vineHolder.size.width / 2)
        vineHolder.physicsBody?.isDynamic = false
        vineHolder.physicsBody?.categoryBitMask = PhysicsCategory.vineHolder
        vineHolder.physicsBody?.collisionBitMask = 0
        
        // add each of the vine parts
        for i in 1 ... length {
            let vineSegment = SKSpriteNode(imageNamed: Images.vineTexture)
            let offset = vineSegment.size.height * CGFloat(i)
            vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
            vineSegment.name = name
            
            vineSegments.append(vineSegment)
            addChild(vineSegment)
            
            vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
            vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.vine
            vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.vineHolder
        }
        
        // set up joint for vine holder
        let joint = SKPhysicsJointPin.joint(
            withBodyA: vineHolder.physicsBody!,
            bodyB: vineSegments[0].physicsBody!,
            anchor: CGPoint(x: vineHolder.frame.midX, y: vineHolder.frame.midY))
        
        scene.physicsWorld.add(joint)
        
        // set up joints between vine parts
        for i in 1 ..< length {
            let nodeA = vineSegments[i - 1]
            let nodeB = vineSegments[i]
            let joint = SKPhysicsJointPin.joint(
                withBodyA: nodeA.physicsBody!,
                bodyB: nodeB.physicsBody!,
                anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
            
            scene.physicsWorld.add(joint)
        }
    }
    
    func attachToPrize(_ prize: SKSpriteNode) {
        let lastNode = vineSegments.last!
        lastNode.position = CGPoint(x: prize.position.x,
                                    y: prize.position.y + prize.size.height * 0.1)
            
        
        let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                            bodyB: prize.physicsBody!,
                                            anchor: lastNode.position)
            
        prize.scene?.physicsWorld.add(joint)
    }
}
