//
//  StartScene.swift
//  FruitFlies
//
//  Created by igmstudent on 3/15/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

class StartScene: SKScene {
    // MARK: - ivars -
    let button:SKLabelNode = SKLabelNode(fontNamed: Constants.Font.MainFont)
    
    // MARK: - Initialization -
    convenience override init(size: CGSize) {
        self.init(size: size, scaleMode: SKSceneScaleMode.ResizeFill)
    }
    
    init(size: CGSize, scaleMode: SKSceneScaleMode) {
        super.init(size: size)
        self.scaleMode = scaleMode
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
    
    override func didMoveToView(view: SKView) {
        backgroundColor = Constants.Color.MenuColor
        
        let label = SKLabelNode(fontNamed: Constants.Font.MainFont)
        label.fontColor = Constants.Color.MenuFontColor
        label.text = "Fruit Flies"
        label.fontSize = 50
        label.position = CGPointMake(size.width/2, size.height/2+100)
        label.zPosition = 1
        addChild(label)
        
        let control = TWButton(size: CGSize(width: 200, height: 75),normalColor: Constants.Color.MenuButton, highlightedColor: Constants.Color.MenuButtonClicked)
        control.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        control.setNormalStateLabelText("Start Game")
        control.setNormalStateLabelFontColor(Constants.Color.MenuButtonFont)
        control.setAllStatesLabelFontName(Constants.Font.MainFont)
        control.setAllStatesLabelFontSize(30.0)
        control.addClosure(.TouchUpInside, target: self, closure: { (scene, sender) -> () in
            (self.view!.window!.rootViewController as! GameViewController).loadGameScene()
        })
        addChild(control)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // FIXME: We need to fix how we call back to the GameViewController
        // (self.view!.window!.rootViewController as! GameViewController).loadGameScene(startLevel: 1)
    }
}
