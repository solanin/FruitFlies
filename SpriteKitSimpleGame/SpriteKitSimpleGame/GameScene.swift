import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b100     // 3
    static let Target    : UInt32 = 0b1000    // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 1
    let player = SKSpriteNode(imageNamed: "player")
    let target = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    var fruitCollected = 0
    var numToWin = 30
    var startPos = CGPoint(x: 0, y: 0)
    var endPos = CGPoint(x: 0, y: 0)
    var labelKilled = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    var labelAdded = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    
    override func didMoveToView(view: SKView) {
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        startPos = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.position = startPos
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        player.physicsBody?.dynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        endPos = CGPoint(x: size.width * 0.9, y: size.height * 0.5)
        target.position = endPos
        target.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        target.physicsBody?.dynamic = true // 2
        target.physicsBody?.categoryBitMask = PhysicsCategory.Target // 3
        target.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        target.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // 4
        addChild(player)
        addChild(target)
        
        
        //auto move
        let actionMove = SKAction.moveTo(endPos, duration: NSTimeInterval(CGFloat(4.0)))
        let loseAction = SKAction.runBlock() {
            // Run out of Fuel
        }
        player.runAction(SKAction.sequence([actionMove, loseAction]))
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        labelKilled.position = CGPointMake(5,self.frame.height-5)
        labelKilled.verticalAlignmentMode = .Top
        labelKilled.horizontalAlignmentMode = .Left
        labelKilled.text = "Killed: \(monstersDestroyed)"
        labelKilled.fontColor = UIColor.blackColor()
        labelKilled.fontSize = 20
        addChild(labelKilled)
        
        labelAdded.position = CGPointMake(105,self.frame.height-5)
        labelAdded.verticalAlignmentMode = .Top
        labelAdded.horizontalAlignmentMode = .Left
        labelAdded.text = "Collected: \(fruitCollected)"
        labelAdded.fontColor = UIColor.blackColor()
        labelAdded.fontSize = 20
        addChild(labelAdded)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.runBlock() {
            SKAction.removeFromParent()
        }
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        let projectileParticle = SKEmitterNode(fileNamed: "MyParticle")!
        projectile.addChild(projectileParticle)
        projectile.position = player.position
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        //projectileParticle.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        //SFX
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        labelKilled.text = "Killed: \(monstersDestroyed)"
    }
    
    func monsterDidCollideWithPlayer(player:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit PLayer")
        monster.removeFromParent()
        
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func playerDidCollideWithTarget(player:SKSpriteNode, target:SKSpriteNode) {
        print("Hit Target")
        
        fruitCollected++
        labelAdded.text = "Collected: \(fruitCollected)"
        
        player.position = startPos
        
        if (fruitCollected > numToWin) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        //3
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                monsterDidCollideWithPlayer(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        //4
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Target != 0)) {
                playerDidCollideWithTarget(firstBody.node as! SKSpriteNode, target: secondBody.node as! SKSpriteNode)
        }    }
}