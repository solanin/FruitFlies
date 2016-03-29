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
    let player = Player(imageNamed: Constants.Image.Player)
    let target = SKSpriteNode(imageNamed: Constants.Image.Smoothie0)
    var startPos:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var endPos:CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    // UI
    var labelKilled = SKLabelNode(fontNamed: Constants.Font.text)
    var labelAdded = SKLabelNode(fontNamed: Constants.Font.text)
    var labelFuel = SKLabelNode(fontNamed: Constants.Font.text)
    var labelSmoothie = SKLabelNode(fontNamed: Constants.Font.text)
    var labelHighScore = SKLabelNode(fontNamed: Constants.Font.text)
    var labelLives = SKLabelNode(fontNamed: Constants.Font.text)
    var fuelBarBack = SKShapeNode(rect: CGRectZero)
    var fuelBar = SKShapeNode(rect: CGRectZero)
    var smoothieBarBack = SKShapeNode(rect: CGRectZero)
    var smoothieBar = SKShapeNode(rect: CGRectZero)
    var currentSmoothie = 0
    let MAX_SMOOTHIE = 6
    var touched:Bool = false
    var touchLocation = CGPointMake(0, 0)
    let shoot = SKAction.playSoundFileNamed(Constants.Sound.shooting, waitForCompletion: false)
    
    
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
        //backgroundColor = Constants.Color.BackgroundColor
        let bgImage = SKSpriteNode(imageNamed: Constants.Image.BG)
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.zPosition = -100
        addChild(bgImage)
        
        //should be looping to stop edge
        scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: (scene?.frame)!)
        scene?.physicsBody?.collisionBitMask = PhysicsCategory.None
        scene?.physicsBody?.categoryBitMask = PhysicsCategory.Border
        scene?.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        // Make
        startPos = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.setup(startPos, screen: frame)
        
        endPos = CGPoint(x: size.width * 0.9, y: size.height * 0.3)
        target.position = endPos
        target.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        target.physicsBody?.dynamic = true // 2
        target.physicsBody?.categoryBitMask = PhysicsCategory.Target // 3
        target.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
        target.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        //Blender not effected by gravity
        target.physicsBody?.affectedByGravity = false
        
        //Add edge collision to fruit
        
        
        // Add to screen
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
        
        labelAdded.position = CGPointMake(20,self.frame.height-15)
        labelAdded.verticalAlignmentMode = .Top
        labelAdded.horizontalAlignmentMode = .Left
        labelAdded.text = Constants.Label.collected + "\(player.smoothiesCollected)"
        labelAdded.fontColor = Constants.Color.HUDFontColor
        labelAdded.fontSize = 20
        addChild(labelAdded)
        
        labelHighScore.position = CGPointMake(20, self.frame.height-40)
        labelHighScore.verticalAlignmentMode = .Top
        labelHighScore.horizontalAlignmentMode = .Left
        labelHighScore.text = Constants.Label.highScore + "\(DefaultsManager.sharedDefaultsManager.getHighScore())"
        labelHighScore.fontColor = Constants.Color.HUDFontColor
        labelHighScore.fontSize = 10
        addChild(labelHighScore)
        
        labelKilled.position = CGPointMake(155,self.frame.height-15)
        labelKilled.verticalAlignmentMode = .Top
        labelKilled.horizontalAlignmentMode = .Left
        labelKilled.text = Constants.Label.killed + "\(player.monstersDestroyed)"
        labelKilled.fontColor = Constants.Color.HUDFontColor
        labelKilled.fontSize = 20
        addChild(labelKilled)
        
        labelSmoothie.position = CGPointMake(self.frame.width - 750,self.frame.height-15)
        labelSmoothie.verticalAlignmentMode = .Top
        labelSmoothie.horizontalAlignmentMode = .Left
        labelSmoothie.text = Constants.Label.smoothie //+ "\(currentSmoothie) / \(MAX_SMOOTHIE)"
        labelSmoothie.fontColor = Constants.Color.HUDFontColor
        labelSmoothie.fontSize = 20
        addChild(labelSmoothie)
        
        labelFuel.position = CGPointMake(self.frame.width - 450,self.frame.height-15)
        labelFuel.verticalAlignmentMode = .Top
        labelFuel.horizontalAlignmentMode = .Left
        labelFuel.text = Constants.Label.fuel //+ "\(player.fuel) / \(player.MAX_FUEL)"
        labelFuel.fontColor = Constants.Color.HUDFontColor
        labelFuel.fontSize = 20
        addChild(labelFuel)
        
        labelLives.position = CGPointMake(self.frame.width - 150, self.frame.height-15)
        labelLives.verticalAlignmentMode = .Top
        labelLives.horizontalAlignmentMode = .Left
        labelLives.text = Constants.Label.lives + "\(player.lives) / \(player.MAX_LIVES)"
        labelLives.fontColor = Constants.Color.HUDFontColor
        labelLives.fontSize = 20
        addChild(labelLives)
        
        addChild(fuelBarBack)
        addChild(fuelBar)
        addChild(smoothieBarBack)
        addChild(smoothieBar)
        updateFuelLabel()
        updateSmoothieLabel()
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        if(touched){
            launchFruit(touchLocation)
        }
        
        if(player.position.y < 0){
            //fixing edge collision to bounce off
            playerDied()
        }
        
        
        if player.isOutOfBounds {
            let destination:CGPoint = player.bounce();
            let actionRecover = SKAction.moveTo(destination, duration: 0.25)
            player.runAction(actionRecover)
            player.physicsBody?.velocity = CGVectorMake(0, 0)
            player.physicsBody?.angularVelocity = 0
        }

    }
    
    func updateFuelLabel() {
        //labelFuel.text = Constants.Label.fuel + "\(player.fuel) / \(player.MAX_FUEL)"
        
        // Rm old
        fuelBarBack.removeFromParent()
        fuelBar.removeFromParent()
        
        // Calc new
        var box = CGRectMake(self.frame.width - 400, self.frame.height-40, 150, 20);
        fuelBarBack = SKShapeNode(rect: box)
        fuelBarBack.fillColor = Constants.Color.Bar
        fuelBarBack.lineWidth = 0;
        addChild(fuelBarBack)
        
        let width = (player.fuel / player.MAX_FUEL) * 150
        //print (width)
        box = CGRectMake(self.frame.width - 400, self.frame.height-40, width, 20);
        
        fuelBar = SKShapeNode(rect: box)
        fuelBar.fillColor = Constants.Color.Fuel
        fuelBar.lineWidth = 0;
        addChild(fuelBar)
    }
    
    func updateSmoothieLabel() {
        //labelSmoothie.text = Constants.Label.smoothie + "\(currentSmoothie) / \(MAX_SMOOTHIE)"
        
        // Rm old
        smoothieBarBack.removeFromParent()
        smoothieBar.removeFromParent()
        
        // Calc new
        var box = CGRectMake(self.frame.width - 650, self.frame.height-40, 150, 20);
        smoothieBarBack = SKShapeNode(rect: box)
        smoothieBarBack.fillColor = Constants.Color.Bar
        smoothieBarBack.lineWidth = 0;
        addChild(smoothieBarBack)
        
        let width:CGFloat = CGFloat (Float(currentSmoothie) / Float(MAX_SMOOTHIE)) * 150.0
        box = CGRectMake(self.frame.width - 650, self.frame.height-40, width, 20)
        
        smoothieBar = SKShapeNode(rect: box)
        smoothieBar.fillColor = Constants.Color.Smoothie
        smoothieBar.lineWidth = 0;
        addChild(smoothieBar)
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: Constants.Image.Monster)
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2 - player.UI_BORDER)
        
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
        player.useFuel()
        updateFuelLabel();
        if (player.isOutOfFuel) {
            playerDied()
        }
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionStart, actionMove, actionMoveDone]))
        
        //SFX
        playSound(shoot)
    }
    
    func playSound(soundVariable : SKAction)
    {
        runAction(soundVariable)
    }
    
    func addForce(player:SKSpriteNode, direction:CGPoint) {
        //print("Move Player")
        
        let shootAmount = direction * -50
        let maxSpeed:CGFloat = 0.5
        let thrustVector = CGVectorMake(maxSpeed*shootAmount.x, maxSpeed*shootAmount.y)
        //apply the thrustVector to player
        player.physicsBody?.applyForce(thrustVector, atPoint: shootAmount)
    }
    
    func changeSmoothie(){
        updateSmoothieLabel()
        
        if(currentSmoothie >= MAX_SMOOTHIE) {
            currentSmoothie = 0
            player.madeSmoothie()
            labelAdded.text = Constants.Label.collected + "\(player.smoothiesCollected)"
        }
        if(currentSmoothie == 0) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie0)}
        if(currentSmoothie == 1) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie1)}
        if(currentSmoothie == 2) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie2)}
        if(currentSmoothie == 3) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie3)}
        if(currentSmoothie == 4) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie4)}
        if(currentSmoothie == 5) {target.texture = SKTexture(imageNamed: Constants.Image.Smoothie5)}
    }
    
    func playerDied(){
        //print("player died")
        
        player.resetPlayer(true)
        let actionDied = SKAction.moveTo(startPos, duration: 0.01)
        player.runAction(actionDied)
        
        if player.isDead {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, score: player.smoothiesCollected)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        labelLives.text = Constants.Label.lives + "\(player.lives) / \(player.MAX_LIVES)"
        updateFuelLabel()
    }
    
    // MARK: - Methods - Touches -
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.locationInNode(self)
        
        touched = true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touched = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touched = false
    }

    
    // MARK: - Methods - Collision -
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        //print("Hit Monster")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        player.killedMonster()
        updateFuelLabel()
        labelKilled.text = Constants.Label.killed + "\(player.monstersDestroyed)"
    }
    
    func monsterDidCollideWithPlayer(player:SKSpriteNode, monster:SKSpriteNode) {
        //print("Hit Player")
        playerDied()
    }

    func playerDidCollideWithTarget(player:Player) {
        //print("Hit Target")
        
        player.resetPlayer(false)
        let actionBlended = SKAction.moveTo(startPos, duration: 0.01)
        player.runAction(actionBlended)
        
        currentSmoothie++
        changeSmoothie()
        
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
                playerDidCollideWithTarget(firstBody.node as! Player)
        }
        
        //Collision between edge and player?
        else if((firstBody.categoryBitMask & PhysicsCategory.Border != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                //print("BORDER WORKS")
        }
    }
}
