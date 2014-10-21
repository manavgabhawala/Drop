//
//  Environment.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/12/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import SpriteKit

class Environment : WorldObject
{
    init(properties: WorldObjectProperties, specialAction: SKAction?)
    {
        super.init(properties: properties)
        if ((specialAction?) != nil)
        {
            runAction(specialAction!)
        }
        self.setScale(0.5)
    }
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
}