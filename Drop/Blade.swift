//
//  Blade.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/11/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import SpriteKit

class Blade : SKNode
{
    override init()
    {
        super.init()
    }
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    init (position: CGPoint, target: SKNode, color: UIColor)
    {
        super.init()
        
        self.name = "Blade"
        self.position = position
        
        let tip:SKSpriteNode = SKSpriteNode(color: color, size: CGSizeMake(0, 0))
        
        self.addChild(tip)
        
        let emitter:SKEmitterNode = emitterNodeWithColor(color)
        emitter.targetNode = target
        emitter.zPosition = 10
        tip.addChild(emitter)
        self.setScale(0.75)
    }
    func enablePhysics(categoryBitMask:UInt32, contactTestBitmask:UInt32, collisionBitmask:UInt32)
    {
        self.physicsBody = SKPhysicsBody(circleOfRadius: 16)
        self.physicsBody!.categoryBitMask = categoryBitMask
        self.physicsBody!.contactTestBitMask = contactTestBitmask
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.dynamic = false
    }
    func emitterNodeWithColor(color:UIColor)->SKEmitterNode
    {
        var emitterNode:SKEmitterNode = SKEmitterNode()
        emitterNode.particleTexture = SKTexture(imageNamed: "Blade")
        emitterNode.particleBirthRate = 3000
        
        emitterNode.particleLifetime = 0.2
        emitterNode.particleLifetimeRange = 0
        
        emitterNode.particlePositionRange = CGVectorMake(0.0, 0.0)
        
        emitterNode.particleSpeed = 0.0
        emitterNode.particleSpeedRange = 0.0
        
        emitterNode.particleAlpha = 1.0
        emitterNode.particleAlphaRange = 0.1
        emitterNode.particleAlphaSpeed = -0.25
        
        emitterNode.particleScale = 0.5
        emitterNode.particleScaleRange = 0.001
        emitterNode.particleScaleSpeed = -1
        
        emitterNode.particleRotation = 0
        emitterNode.particleRotationRange = 0
        emitterNode.particleRotationSpeed = 0
        
        emitterNode.particleColorBlendFactor = 1
        emitterNode.particleColorBlendFactorRange = 0
        emitterNode.particleColorBlendFactorSpeed = 0
        
        emitterNode.particleColor = color
        emitterNode.particleBlendMode = SKBlendMode.Add
        
        return emitterNode
    }
}
