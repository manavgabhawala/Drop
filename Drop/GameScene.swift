//
//  GameScene.swift
//  Drop
//
//  Created by Manav Gabhawala on 10/11/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import SpriteKit
import CoreMotion
import Foundation

let accelerationScale : CGFloat = 10

enum PhysicsCategories : UInt32
{
    case Character = 1
    case Ledge = 2
    case Blade = 4
}
enum Difficulty : Int
{
    case Legendary = 0
    case Expert = 2
    case Medium = 4
    case Amateur = 6
    case Idiot = 8
}
class GameScene: SKScene {
    
    //Blade Properties
    var blade = Blade()
    var delta = CGPoint()

    var character = Character() //Character
    var worldObjects = [WorldObject]() //Ledges and Environment Objects
    var worldObjectProperties = [WorldObjectProperties]()
    
    //var ledges = [Ledge]() //Ledges
    //var environments = [Environment]() //Environment Objects
    var ledgesNotUnderCharacter = 0
    var difficultyLevel : Difficulty?
    
    let motionManager = CMMotionManager()
    
    let minimumSpeed : CGFloat = 100 //Minimum speed
    let maximumSpeed : CGFloat = 6000 //Maximum speed
    var moveSpeed : CGFloat = 0 //Current Speed
    
    
    var timeSinceLastUpdate: CFTimeInterval = 0 //Time since last update
    var pauseTime : CFTimeInterval = 0 //When paused calculate time
    var acceleration : CGFloat? //Acceleration per frame
    let seedAcceleration : CGFloat = 120.0
    
    
    let stoppingPercentage : CGFloat = 0.15 //Amount to reduce speed when on the ledge
    var contacted  = false //Whether or not the character is on the ledge
    
    let distanceRatio : CGFloat = 1.0
    var distanceTravelled : CGFloat = 0
    
    override var paused : Bool
    {
        didSet
        {
            pauseTime = CFAbsoluteTimeGetCurrent()
        }
    }
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        
        difficultyLevel = Difficulty.Expert
        if (difficultyLevel!.rawValue == 0)
        {
            acceleration = seedAcceleration
        }
        else
        {
            acceleration = (seedAcceleration / CGFloat(difficultyLevel!.rawValue))
        }
        self.backgroundColor = SKColor(red: 139.0/255.0, green: 205.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        physicsWorld.contactDelegate = self
        self.addChild(character)
        character.setup()
        
        //Read data from plist file about types of objects and create initial ones.
        let path = NSBundle.mainBundle().pathForResource("World Object Types", ofType: "plist")!
        let information = NSArray(contentsOfFile: path)!
        for dictionary in information
        {
            let name = dictionary.valueForKey("Name") as String
            let minDist = dictionary.valueForKey("Distance Minimum") as CGFloat
            let maxDist = dictionary.valueForKey("Distance Maximum") as CGFloat
            let speedRatio = dictionary.valueForKey("Speed Ratio") as CGFloat
            let textures = dictionary.valueForKey("Textures") as [String]
            var finalTextures = [SKTexture]()
            for textureString in textures
            {
                let texture = SKTexture(imageNamed: textureString)
                finalTextures.append(texture)
            }
            let property = WorldObjectProperties(name: name, texture: finalTextures, speedRatio: speedRatio, distanceMin: minDist, distanceMax: maxDist)
            worldObjectProperties.append(property)
        }
        createInitial()
        
        if (!motionManager.deviceMotionActive && motionManager.deviceMotionAvailable)
        {
            motionManager.deviceMotionUpdateInterval = 1 / 30
            motionManager.startDeviceMotionUpdates()
        }
//        if (!motionManager.deviceMotionActive)
//        {
//            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: {(deviceMotion, error) in
//                self.character.moveHorizontally(deviceMotion.gravity) //For rotation
//                
//                //var i = 0
//                //var indicesToRemove = [Int]()
//                for i in 0..<self.worldObjects.count
//                {
//                    if (i < self.worldObjects.count)
//                    {
//                        self.worldObjects[i].moveHorizontally(deviceMotion.gravity)
//                    }
//                }
//                for worldObject in self.worldObjects
//                {
//                    worldObject.moveHorizontally(deviceMotion.gravity)
//                    if (worldObject.checkBounds())
//                    {
//                        worldObject.removeFromParent()
//                        //indicesToRemove.append(i)
//                    }
//                    //++i
//                }
//                for index in indicesToRemove
//                {
//                    if (index < self.worldObjects.count)
//                    {
//                        self.worldObjects.removeAtIndex(index)
//                    }
//                }
                //Move all items in the world except character and move them horizontally
//            })
    }
    
    func createInitial()
    {
        for property in worldObjectProperties
        {
            let initialObjects = 2
            for i in -1...1 //Loop through three screens "Right - Current View - Left"
            {
                for j in 1...initialObjects
                {
                    let minPos = CGFloat(i) * view!.bounds.width
                    let maxPos = CGFloat(i + 1) * view!.bounds.width
                    let x = generateRandomX(minValue: minPos, maxValue: maxPos)
                    let y = CGFloat(j) * -view!.bounds.height / 2
                    worldObjects.append(createWorldObject(x, yPosition: y, property: property))
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
//        if (moveSpeed < minimumSpeed && character.notInPosition()) //Correction needed for character
//        {
//            let actionRequired = character.actionToMoveIntoPosition()
//            for worldObject in worldObjects
//            {
//                worldObject.runAction(actionRequired)
//            }
//        }
        var deltaTime = currentTime - timeSinceLastUpdate - pauseTime
        pauseTime = 0
        if (deltaTime < 0 || deltaTime > 0.5) //Reality check!
        {
            deltaTime = 0.00001
        }
        if (contacted)
        {
            moveSpeed = clamp(moveSpeed * stoppingPercentage, minimum: 0, maximum: maximumSpeed)
            if (moveSpeed <= minimumSpeed)
            {
                moveSpeed = 0
            }
        }
        else
        {
            if (moveSpeed < minimumSpeed)
            {
                moveSpeed = minimumSpeed
            }
            moveSpeed = clamp(moveSpeed + (acceleration! * CGFloat(deltaTime)), minimum: minimumSpeed, maximum: maximumSpeed)
            distanceTravelled += (CGFloat)(deltaTime) * moveSpeed * distanceRatio
        }
        var gravity: CMAcceleration? = motionManager.deviceMotion?.gravity
        if (gravity? == nil)
        {
            gravity = CMAcceleration(x: 0, y: 0, z: 0)
        }
        self.character.moveHorizontally(gravity!) //For rotation
        for worldObject in worldObjects
        {
            worldObject.update(moveSpeed, deltaTime: CGFloat(deltaTime))
            worldObject.moveHorizontally(gravity!)
        }
        if (!contacted && character.notInPosition())
        {
            let valueToMove = character.actionToMoveIntoPosition()
            if (valueToMove != CGVectorMake(0, 0))
            {
                let actionRequired = SKAction.moveBy(valueToMove, duration: 0)
                character.runAction(actionRequired)
                for worldObject in worldObjects
                {
                    worldObject.runAction(actionRequired)
                }
                character.actionNeeded = false
            }
        }
        
        //If the character somehow goes offscreen, reset to center of the screen and don't give any credit for the distance travelled
        if (character.position.x + character.size.width / 2 < 0 || character.position.x - character.size.width / 2 > view!.bounds.width || character.position.y - character.size.height / 2 > view!.bounds.height || character.position.y + character.size.height / 2 < 0)
        {
            character.position = CGPointMake(view!.bounds.width / 2, view!.bounds.height / 2)
        }
        
        updateBlade()
        timeSinceLastUpdate = currentTime
    }
    override func didFinishUpdate()
    {
        var createdObjects = [WorldObject]()
        for worldObject in worldObjects
        {
            if (worldObject.distanceToNext? != nil)
            {
                //If the next object is in the upper half of the frame below draw it
                if(worldObject.position.y - worldObject.distanceToNext! >= -self.view!.bounds.height)
                {
                    var property = worldObjectProperties[0]
                    for worldObjectProperty in worldObjectProperties
                    {
                        if (worldObjectProperty.name == worldObject.name)
                        {
                            property = worldObjectProperty
                        }
                    }
                    createdObjects.append(createWorldObject(generateRandomX(seed: worldObject.position.x), yPosition: worldObject.position.y - worldObject.distanceToNext!, property: property))
                    worldObject.distanceToNext = nil
                }
            }
        }
        for createdObject in createdObjects
        {
            worldObjects.append(createdObject)
        }
        var i = 0
        var newArray = [WorldObject]()
        for worldObject in worldObjects
        {
            if worldObject.parent? != nil
            {
                newArray.append(worldObject)
            }
        }
        worldObjects = newArray
    }
}
typealias WorldObjectFunctions = GameScene
extension WorldObjectFunctions
{
    //MARK: - World Objects
    func createWorldObject(xPosition: CGFloat, yPosition: CGFloat, property: WorldObjectProperties) -> WorldObject
    {
        if (property.name == "Ledge")
        {
            //TODO: Fix type
            //TODO
            var ledge = Ledge(properties: property, type: LedgeType.Normal)
            //worldObjects.append(ledge)
            self.addChild(ledge)
            ledge.position = CGPointMake(xPosition, yPosition)
            ledge.zPosition = 5
            return ledge
        }
        else
        {
            var specialAction : SKAction? = nil
            if (property.name == "Cloud")
            {
                let randomAmount : CGFloat = CGFloat(random()) % (50 - 20) + 20
                let positiveMove = SKAction.moveByX(randomAmount, y: 0, duration: 1.5)
                let negativeMove = SKAction.moveByX(randomAmount, y: 0, duration: 1.5)
                specialAction = SKAction.repeatActionForever(SKAction.sequence([positiveMove, SKAction.waitForDuration(0.5), negativeMove]))
                specialAction!.timingMode = SKActionTimingMode.EaseInEaseOut
            }
            var object = Environment(properties: property, specialAction: specialAction)
            //worldObjects.append(object)
            self.addChild(object)
            object.position = CGPointMake(xPosition, yPosition)
            return object
        }
    }
    //mARK: - Ledge
    //MARK: - Blade
    func presentBladeAtPosition(position:CGPoint)
    {
        blade = Blade(position: position, target: self, color: UIColor.redColor())
        blade.zPosition = 2
        blade.enablePhysics(PhysicsCategories.Blade.rawValue, contactTestBitmask: PhysicsCategories.Ledge.rawValue, collisionBitmask: 0)
        self.addChild(blade)
    }
    func updateBlade()
    {
        blade.position = CGPointMake(blade.position.x + delta.x, blade.position.y + delta.y)
        delta = CGPointZero
    }
    func removeBlade()
    {
        delta = CGPointZero
        blade.removeFromParent()
    }
}

typealias ContactDelegate = GameScene
extension ContactDelegate : SKPhysicsContactDelegate
{
    func didBeginContact(contact: SKPhysicsContact)
    {
        var body1 = SKNode(), body2 = SKNode()
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            body1 = contact.bodyA.node!
            body2 = contact.bodyB.node!
        }
        else
        {
            body1 = contact.bodyB.node!
            body2 = contact.bodyA.node!
        }
        if (body1.physicsBody!.categoryBitMask == PhysicsCategories.Character.rawValue && body2.physicsBody!.categoryBitMask == PhysicsCategories.Ledge.rawValue)
        {
            if (body1.position.y - body2.position.y > 0.8 * (character.texture!.size().height / 2))
            {
                if (moveSpeed >= (1.5 * minimumSpeed))
                {
                    if (moveSpeed >= 0.9 * maximumSpeed)
                    {
                        character.health = 0
                    }
                    else
                    {
                        let scale = (0.9 * maximumSpeed - 1.5 * minimumSpeed) / CGFloat(character.maxHealth * 0.75)
                        character.health -= Float(moveSpeed / scale)
                    }
                    
                }
                contacted = true
                character.actionNeeded = true
            }
            else
            {
                if (contacted == false)
                {
                    character.actionNeeded = true
                }
            }
        }
        if (body1.physicsBody!.categoryBitMask == PhysicsCategories.Ledge.rawValue && body2.physicsBody!.categoryBitMask == PhysicsCategories.Blade.rawValue)
        {
        }
    }
    func didEndContact(contact: SKPhysicsContact)
    {
        var body1 = SKNode(), body2 = SKNode()
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            body1 = contact.bodyA.node!
            body2 = contact.bodyB.node!
        }
        else
        {
            body1 = contact.bodyB.node!
            body2 = contact.bodyA.node!
        }
        if (body1.physicsBody!.categoryBitMask == PhysicsCategories.Character.rawValue && body2.physicsBody!.categoryBitMask == PhysicsCategories.Ledge.rawValue)
        {
            contacted = false
            character.actionNeeded = true
        }
    }
}

typealias UtilityFunctions = GameScene
extension UtilityFunctions
{
    func clamp <T: Comparable> (value: T, minimum: T, maximum: T) -> T
    {
        var valueRequired = max(minimum, value)
        valueRequired = min(maximum, value)
        return valueRequired
    }
    func generateRandomX(#minValue: CGFloat, maxValue: CGFloat) -> CGFloat
    {
        return CGFloat(arc4random()) % (maxValue - minValue) + minValue
    }
    func generateRandomX (#seed: CGFloat) -> CGFloat
    {
        //let halfWidth = self.view!.bounds.width / 2
        //return CGFloat(random()) % ((seed + halfWidth) - (seed - halfWidth)) + seed - halfWidth
        ++ledgesNotUnderCharacter
        if (seed >= -view!.bounds.width && seed < 0)
        {
            return CGFloat(arc4random()) % (-view!.bounds.width) + (-view!.bounds.width)
        }
        else if (seed >= 0 && seed < self.view!.bounds.width)
        {
            if ((ledgesNotUnderCharacter / 2) >= difficultyLevel!.rawValue)
            {
                ledgesNotUnderCharacter = 0
                return character.position.x
            }
            return CGFloat(arc4random()) % (view!.bounds.width)
        }
        else if (seed >= self.view!.bounds.width && seed <= self.view!.bounds.width * 2)
        {
            return CGFloat(arc4random()) % (view!.bounds.width * 2 - view!.bounds.width) + view!.bounds.width
        }
        else
        {
            return seed
        }
    }
}

typealias UserInteraction = GameScene
extension UserInteraction
{
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            presentBladeAtPosition(location)
        }
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
    {
        let currentPoint:CGPoint = touches.anyObject()!.locationInNode(self)
        let previousPoint:CGPoint = touches.anyObject()!.previousLocationInNode(self)
        delta = CGPointMake(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y)
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        removeBlade()
    }
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent)
    {
        removeBlade()
    }
}