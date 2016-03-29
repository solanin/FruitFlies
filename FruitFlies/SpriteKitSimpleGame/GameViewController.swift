import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // MARK: - ivars -
    var gameScene: GameScene?
    var skView:SKView!
    let showDebugData = true
    let screenSize = CGSize(width: 1080, height: 1920)
    let scaleMode = SKSceneScaleMode.ResizeFill
    
    // MARK: - Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        self.becomeFirstResponder()
        
        loadHomeScene()

    }    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Loading for various scenes
    
    func loadHomeScene(){
        let scene = StartScene(size:screenSize, scaleMode:scaleMode)
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameScene(){
        gameScene = GameScene(size:screenSize)
        if showDebugData{
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        
        //let reveal = SKTransition.flipHorizontalWithDuration(1.0)
        let reveal = SKTransition.doorsOpenHorizontalWithDuration(1)
        // let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(gameScene!, transition: reveal)
        
    }
    
    func loadEndScene(score:Int){
        let scene = GameOverScene(size:screenSize, score:score)
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene, transition: reveal)
        
    }
}