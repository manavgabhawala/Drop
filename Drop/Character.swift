//
//  Character.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/11/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import SpriteKit
import CoreMotion

class Character : SKSpriteNode
{
    let maxHealth : Float = 100
    let characterTexture = SKTexture(imageNamed: "Character")
    var actionNeeded = false
    
    var health : Float = 0
    {
        didSet
        {
            if (oldValue >= health)
            {
                println("Old Health: \(oldValue)")
                println("New Health: \(health)")
                
                let redColor = UIColor(red: CGFloat(200.0 + ((health / maxHealth) * 55.0)), green: 0.0, blue: 0.0, alpha: 1.0)
                self.runAction(SKAction.sequence([SKAction.colorizeWithColor(redColor, colorBlendFactor: 1.0, duration: 0.2), SKAction.waitForDuration(0.2),SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.1)]))
            }
        }
    }
    override init()
    {
        super.init()
    }
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    override init(texture: SKTexture!, color: UIColor!, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    func setup()
    {
        
        texture = characterTexture
        size = texture!.size()
        health = maxHealth
        position = CGPointMake(self.scene!.view!.bounds.width / 2, scene!.view!.bounds.height / 2)
        name = "Character"
        zPosition = 100

        self.physicsBody = SKPhysicsBody(circleOfRadius: self.texture!.size().width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.usesPreciseCollisionDetection = true
        //self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.Character.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Ledge.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategories.Ledge.rawValue
    }
    func moveHorizontally(gravity : CMAcceleration)
    {
        //let moveByX = SKAction.moveByX(CGFloat(gravity.x) * accelerationScale, y: 0, duration: 0.1)
        //moveByX.timingMode = SKActionTimingMode.EaseInEaseOut
        //let groupedAction = SKAction.group([moveByX, rotate])
        let rotate = SKAction.rotateByAngle(CGFloat(gravity.x * M_PI / 180) * accelerationScale, duration: 0.1)
        rotate.timingMode = SKActionTimingMode.EaseInEaseOut
        runAction(rotate)
    }
    func notInPosition() -> Bool
    {
        if (position.x != scene!.view!.bounds.width / 2 || position.y != scene!.view!.bounds.height / 2)
        {
            return true
        }
        return false
    }
    func actionToMoveIntoPosition() -> CGVector
    {
        if (actionNeeded)
        {
            let delta = CGVectorMake((scene!.view!.bounds.width / 2) - position.x, (scene!.view!.bounds.height / 2) - position.y)
            return delta
        }
        else
        {
            let delta = CGVectorMake(0, 0)
            return delta
        }
    }
}