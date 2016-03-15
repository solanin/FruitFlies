import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool, score:Int) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = Constants.Color.MenuColor
        
        // 2
        let message = won ? "You Won!" : "You Lose"
        
        // 3
        let label = SKLabelNode(fontNamed: Constants.Font.MainFont)
        label.text = message
        label.fontSize = 40
        label.fontColor = Constants.Color.MenuFontColor
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = StartScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
        // Save Score
        let highScore = DefaultsManager.sharedDefaultsManager.getHighScore()
        if score > highScore{
            
            DefaultsManager.sharedDefaultsManager.setHighScore(score)
        }
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}