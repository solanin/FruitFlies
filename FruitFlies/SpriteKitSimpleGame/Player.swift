//
//  Player.swift
//  FruitFlies
//
//  Created by igmstudent on 3/17/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

class Player : SKSpriteNode {
    
    // MARK: - ivars -
    
    // Screen Calc
    let BORDER:CGFloat = 50
    let UI_BORDER:CGFloat = 80
    var startPos:CGPoint
    var screen:CGRect
    
    // Player Data
    let MAX_LIVES = 5
    var lives:Int
    let MAX_FUEL:CGFloat = 75
    var fuel:CGFloat
    
    // Score
    var monstersDestroyed:Int
    var smoothiesCollected:Int
    
    var isOutOfFuel:Bool {
        return fuel <= 0
    }
    
    var isDead:Bool {
        return lives <= 0
    }
    
    var isOutOfBounds:Bool {
        return ((super.position.x <= 0) || (super.position.x > screen.width) || (super.position.y > screen.height-UI_BORDER))
    }
    
    // MARK: - Initialization -
    
    init (imageNamed :String) {
        let texture = SKTexture(imageNamed: imageNamed)
        lives = MAX_LIVES
        fuel = MAX_FUEL
        monstersDestroyed = 0
        smoothiesCollected = 0
        startPos = CGPoint(x: 0.0, y: 0.0)
        screen = CGRect(x: 1, y: 1, width: 1, height: 1)
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods -
    
    func setup(startPos:CGPoint, screen:CGRect) {
        self.startPos = startPos
        self.screen = screen
        super.position = startPos
        super.physicsBody = SKPhysicsBody(rectangleOfSize: super.size)
        super.physicsBody?.dynamic = true // 2
        super.physicsBody?.categoryBitMask = PhysicsCategory.Player
        super.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        super.physicsBody?.collisionBitMask = PhysicsCategory.None
        super.physicsBody?.allowsRotation = false
    }
    
    func useFuel () {
        fuel = fuel - 1
    }
    
    func killedMonster () {
        monstersDestroyed++
        fuel = fuel + 10;
    }
    
    func madeSmoothie () {
        smoothiesCollected++
    }
    
    func resetPlayer(dueToDeath: Bool) {
        if dueToDeath { lives = lives - 1 }
        fuel = MAX_FUEL
        super.physicsBody?.velocity = CGVectorMake(0, 0)
        super.physicsBody?.angularVelocity = 0
    }
    
    func bounce () -> CGPoint {
       
        var destination:CGPoint = super.position
        
        if(super.position.x <= 0){
            destination = CGPointMake(BORDER, super.position.y)
        }
        
        if(super.position.x > screen.width){
            //fixing edge collision to bounce off
            destination = CGPointMake(screen.width-BORDER, super.position.y)
        }
    
        if(super.position.y > screen.height-UI_BORDER){
            //fixing edge collision to bounce off
            destination = CGPointMake(super.position.x, screen.height-UI_BORDER-BORDER)
        }
        
        return destination

    }
}