//
//  WorldObject.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/12/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import SpriteKit
import CoreMotion


struct WorldObjectProperties
{
    var name : String
    var texture: [SKTexture]
    var speedRatio : CGFloat
    var distanceMin : CGFloat
    var distanceMax: CGFloat
}
class WorldObject : SKSpriteNode
{
    var distanceToNext: CGFloat?
    let speedRatio: CGFloat
    required init?(coder aDecoder: NSCoder)
    {
        speedRatio = 0
        super.init(coder: aDecoder)
    }
    init(properties: WorldObjectProperties)
    {
        speedRatio = 0
        super.init()
        name = properties.name
        texture = properties.texture[Int(arc4random()) % properties.texture.count]
        size = texture!.size()
        distanceToNext = (CGFloat(arc4random()) % (properties.distanceMax - properties.distanceMin)) + properties.distanceMin
        speedRatio = properties.speedRatio
    }
    override init(texture: SKTexture!, color: UIColor!, size: CGSize)
    {
        speedRatio = 0
        super.init(texture: texture, color: color, size: size)
    }
    func checkBounds() -> Bool
    {
        
        var width = scene?.view?.bounds.width
        if (width? == nil)
        {
            width = 0
        }
        if (position.x + size.width / 2 < -width!)
        {
            position.x = (width! * 2) - size.width
        }
        if (position.x - size.width / 2 > width! * 2)
        {
            position.x = -width! + size.width
        }
        if (position.y - size.height / 2 > scene?.view?.bounds.height)
        {
            return true
        }
        return false
    }
    func update(speed: CGFloat, deltaTime: CGFloat)
    {
//        if (physicsBody? != nil)
//        {
//            physicsBody!.velocity = CGVector(physicsBody!.velocity.dx, speed * speedRatio)
//        }
//        else
//        {
            position.y += speed * speedRatio * deltaTime
//        }
//        if (checkBounds())
//        {
//            removeFromParent()
//        }
    }
    func moveHorizontally(gravity : CMAcceleration)
    {
        let moveByX = SKAction.moveByX(CGFloat(-gravity.x) * accelerationScale * speedRatio, y: 0, duration: 0.1)
        moveByX.timingMode = SKActionTimingMode.EaseInEaseOut
        runAction(moveByX, completion: {() in
            if (self.checkBounds())
            {
                self.removeFromParent()
            }
        })
    }
}
