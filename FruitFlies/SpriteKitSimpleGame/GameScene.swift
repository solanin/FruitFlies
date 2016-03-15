import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b100     // 3
    static let Target    : UInt32 = 0b1000    // 4
    static let Border    : UInt32 = 0b10000   // 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - ivars -
    let player = SKSpriteNode(imageNamed: Constants.Image.Player)
    let target = SKSpriteNode(imageNamed: Constants.Image.Target)
    var monstersDestroyed = 0
    var fruitCollected = 0
    var startPos = CGPoint(x: 0, y: 0)
    var endPos = CGPoint(x: 0, y: 0)
    var labelKilled = SKLabelNode(fontNamed: Constants.Font.text)
    var labelAdded = SKLabelNode(fontNamed: Constants.Font.text)
    var labelFuel = SKLabelNode(fontNamed: Constants.Font.text)
    var labelHighScore = SKLabelNode(fontNamed: Constants.Font.text)
    var labelLives = SKLabelNode(fontNamed: Constants.Font.text)
    var touched:Bool = false;
    var touchLocation = CGPointMake(0, 0)
    var MAX_FUEL:CGFloat = 75;
    var fuel:CGFloat = 75;
    var MAX_LIVES = 5;
    var lives = 5;
    
    
    // MARK: - Initialization -
    
    convenience override init(size: CGSize) {
        self.init(size: size, scaleMode: SKSceneScaleMode.ResizeFill)
    }
    
    init(size: CGSize, scaleMode: SKSceneScaleMode) {
        super.init(size: size)
        self.scaleMode = scaleMode
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
    
    override func didMoveToView(view: SKView) {
        // 2
        backgroundColor = Constants.Color.BackgroundColor
        
        //should be looping to stop edge
        scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: (scene?.frame)!);
        scene?.physicsBody?.collisionBitMask = PhysicsCategory.None;
        scene?.physicsBody?.categoryBitMask = PhysicsCategory.Border;
        scene?.physicsBody?.contactTestBitMask = PhysicsCategory.Player;
        
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
        
        //Blender not effected by gravity
        target.physicsBody?.affectedByGravity = false;
        
        //Add edge collision to fruit
        
        
        // 4
        addChild(player)
        addChild(target)
        
        physicsWorld.gravity = CGVectorMake(0, -0.1)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(2.0)
                ])
            ))
        
        let backgroundMusic = SKAudioNode(fileNamed: Constants.Sound.background)
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        labelAdded.position = CGPointMake(5,self.frame.height-5)
        labelAdded.verticalAlignmentMode = .Top
        labelAdded.horizontalAlignmentMode = .Left
        labelAdded.text = Constants.Label.collected + "\(fruitCollected)"
        labelAdded.fontColor = Constants.Color.HUDFontColor
        labelAdded.fontSize = 20
        addChild(labelAdded)
        
        labelKilled.position = CGPointMake(135,self.frame.height-5)
        labelKilled.verticalAlignmentMode = .Top
        labelKilled.horizontalAlignmentMode = .Left
        labelKilled.text = Constants.Label.killed + "\(monstersDestroyed)"
        labelKilled.fontColor = Constants.Color.HUDFontColor
        labelKilled.fontSize = 20
        addChild(labelKilled)
        
        labelFuel.position = CGPointMake(305,self.frame.height-5)
        labelFuel.verticalAlignmentMode = .Top
        labelFuel.horizontalAlignmentMode = .Left
        labelFuel.text = Constants.Label.fuel + "\(fuel) / \(MAX_FUEL)"
        labelFuel.fontColor = Constants.Color.HUDFontColor
        labelFuel.fontSize = 20
        addChild(labelFuel)
        
        labelHighScore.position = CGPointMake(5, self.frame.height-5 - 20)
        labelHighScore.verticalAlignmentMode = .Top
        labelHighScore.horizontalAlignmentMode = .Left
        labelHighScore.text = Constants.Label.highScore + "\(DefaultsManager.sharedDefaultsManager.getHighScore())"
        labelHighScore.fontColor = Constants.Color.HUDFontColor
        labelHighScore.fontSize = 10
        addChild(labelHighScore)
        
        labelLives.position = CGPointMake(605,self.frame.height-5)
        labelLives.verticalAlignmentMode = .Top
        labelLives.horizontalAlignmentMode = .Left
        labelLives.text = Constants.Label.lives + "\(lives) / \(MAX_LIVES)"
        labelLives.fontColor = Constants.Color.HUDFontColor
        labelLives.fontSize = 20
        addChild(labelLives)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: Constants.Image.Monster)
        
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
        let actualDuration = random(min: CGFloat(8.0), max: CGFloat(16.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.runBlock() {
            SKAction.removeFromParent()
        }
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.locationInNode(self)
        
        touched = true;
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touched = false;
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touched = false;
    }
    
    override func update(currentTime: NSTimeInterval) {
        if(touched){
            launchFruit(touchLocation);
        }
        
        if(player.position.x <= 0){
            //fixing edge collision to bounce off
            let destination = CGPointMake(30, player.position.y)
            let actionRecover = SKAction.moveTo(destination, duration: 0.25)
            player.runAction(actionRecover)
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.angularVelocity = 0
        }
        
        if(player.position.x > frame.width){
            //fixing edge collision to bounce off
            let destination = CGPointMake(frame.width-30, player.position.y)
            let actionRecover = SKAction.moveTo(destination, duration: 0.25)
            player.runAction(actionRecover)
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.angularVelocity = 0
        }
        
        if(player.position.y < 0){
            //fixing edge collision to bounce off
            playerDied()
        }
        
        if(player.position.y > frame.height){
            //fixing edge collision to bounce off
            let destination = CGPointMake(player.position.x, 30)
            let actionRecover = SKAction.moveTo(destination, duration: 0.25)
            player.runAction(actionRecover)
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.angularVelocity = 0
        }
    }
    
    func launchFruit(touch: CGPoint) {
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: Constants.Image.Projectile)
        let projectileParticle = SKEmitterNode(fileNamed: Constants.Image.Particle)!
        projectile.addChild(projectileParticle)
        projectile.position = player.position
        
        // 3 - Determine offset of location to projectile
        let offset = touch - projectile.position
        
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
        let actionStart = SKAction.runBlock() {
            self.addForce(self.player, direction: direction)
        }
        
        // 10 - Fuel limit
        fuel = fuel - 1
        labelFuel.text = Constants.Label.fuel + "\(fuel) / \(MAX_FUEL)"
        if(fuel <= 0){
            print("NO MORE FUEL!!")
            playerDied()
        }
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionStart, actionMove, actionMoveDone]))
        
        //SFX
        runAction(SKAction.playSoundFileNamed(Constants.Sound.shooting, waitForCompletion: false))
    }
    
    func addForce(player:SKSpriteNode, direction:CGPoint) {
        print("Move Player")
        
        let shootAmount = direction * -50
        let maxSpeed:CGFloat = 0.5
        let thrustVector = CGVectorMake(maxSpeed*shootAmount.x, maxSpeed*shootAmount.y)
        //apply the thrustVector to player
        player.physicsBody?.applyForce(thrustVector, atPoint: shootAmount)
    }
    
    func playerDied(){
        print("player died")
        startPos = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        let actionDied = SKAction.moveTo(startPos, duration: 0.01)
        player.runAction(actionDied)
        
        lives = lives - 1;
        labelLives.text = Constants.Label.lives + "\(lives) / \(MAX_LIVES)"
        if lives <= 0 {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: fruitCollected)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        fuel = MAX_FUEL
        labelFuel.text = Constants.Label.fuel + "\(fuel) / \(MAX_FUEL)"
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.angularVelocity = 0
    }
    
    // MARK: - Methods - Collision -
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit Monster")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        fuel = fuel + 2;
        labelFuel.text = Constants.Label.fuel + "\(fuel) / \(MAX_FUEL)"
        labelKilled.text = Constants.Label.killed + "\(monstersDestroyed)"
    }
    
    func monsterDidCollideWithPlayer(player:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit Player")
        //monster.removeFromParent()
        playerDied()
    }

    func playerDidCollideWithTarget(player:SKSpriteNode) {
        print("Hit Target")
        
        fruitCollected++
        labelAdded.text = Constants.Label.collected + "\(fruitCollected)"
        startPos = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        let actionBlended = SKAction.moveTo(startPos, duration: 0.01)
        player.runAction(actionBlended)
        fuel = MAX_FUEL
        labelFuel.text = Constants.Label.fuel + "\(fuel) / \(MAX_FUEL)"
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.angularVelocity = 0
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
                if (firstBody.node != nil && secondBody.node != nil) {
                    projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
                }
        }
        
        //3
        else if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                monsterDidCollideWithPlayer(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        //4
        else if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Target != 0)) {
                playerDidCollideWithTarget(firstBody.node as! SKSpriteNode)
        }
        
        //Collision between edge and player?
        else if((firstBody.categoryBitMask & PhysicsCategory.Border != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                print("BORDER WORKS")
        }
    }
}
