//
//  Ledge.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/11/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import CoreMotion
import SpriteKit

enum LedgeType
{
    case Normal
    case Cuttable
}
class Ledge : WorldObject
{
    var type  = LedgeType.Normal
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    init(properties: WorldObjectProperties, type : LedgeType)
    {
        super.init(properties: properties)
        self.type = type
        setup()
    }
    override init(texture: SKTexture!, color: UIColor!, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    func setup()
    {
        physicsBody = SKPhysicsBody(rectangleOfSize: texture!.size())
        physicsBody?.categoryBitMask = PhysicsCategories.Ledge.rawValue
        if (self.type == .Cuttable)
        {
            physicsBody?.contactTestBitMask = PhysicsCategories.Character.rawValue | PhysicsCategories.Blade.rawValue
        }
        else
        {
            physicsBody?.contactTestBitMask = PhysicsCategories.Character.rawValue
        }
        physicsBody?.collisionBitMask = PhysicsCategories.Character.rawValue
        physicsBody?.affectedByGravity = false
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.dynamic = false
    }
}