import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    // MARK: - Initialization -
    
    init(size: CGSize, score:Int) {
        
        super.init(size: size)
        
        // BG
        backgroundColor = Constants.Color.MenuColor
        
        // Your Score & Loose Anoucement
        let label = SKLabelNode(fontNamed: Constants.Font.Main)
        label.text = Constants.Label.loseMessage
        label.fontSize = 60
        label.fontColor = Constants.Color.MenuFontColor
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let hs = SKLabelNode(fontNamed: Constants.Font.Main)
        hs.text = Constants.Label.hsMessage + "\(score)"
        hs.fontSize = 40
        hs.fontColor = Constants.Color.MenuFontColor
        hs.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
        addChild(hs)
        
        // Go Back to Start
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = StartScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
        // Save Score
        let highScore = DefaultsManager.sharedDefaultsManager.getHighScore()
        if score > highScore{
            
            // High Score
            DefaultsManager.sharedDefaultsManager.setHighScore(score)
            
            let hsAnounce = SKLabelNode(fontNamed: Constants.Font.Main)
            hsAnounce.text = Constants.Label.hsMessageAnnounce
            hsAnounce.fontSize = 40
            hsAnounce.fontColor = Constants.Color.MenuFontColor
            hsAnounce.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
            addChild(hsAnounce)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}