# FruitFlies

Made by Jacob Westerback and Luke Zetterlund

##Project Requirements
The name of our game is “Fruit Flies” (https://github.com/solanin/FruitFlies). We made a 2D shooter using SpriteKit, targeted at tablets. We supported landscape orientation and had a total of 3 screens; An intro, a game scene, and a results screen. This app functions on all tablets and has icons of all required sizes. There is a launch screen with the title and credits on it. 

You play as a rocket equipped strawberry. You tap to shoot your rocket which moves you in the opposite direction. Your goal is to get to the blender on the other side of a screen and make as many smoothies as you can, while not hitting the floor or any bugs. It takes six strawberries to make one smoothie. These controls are simple and easy to learn and do not require an instructions screen. The game does not take very long to play as you only have 5 lives. We have both shooting sound effects and background music files in our game. The game provides challenge but it is not unusably hard. If you run out of fuel for the rocket you die but you also gain fuel by shooting bugs. Since bug come at you from the smoothie side of the screen this also gets you further away from your goal. This conflicting decision point adds some depth to the game. 

We used three SKScene subclasses and we have one SKSpriteNode class for the player. We used an SKEmitterNode to create the rocket effect. We used SKActions throughout the code to make things run. We chose the font “Noteworthy” as our primary font, since we thought it matched the look of our game well. We also found cool art online to communicate the theme of our game. More than separating out the Player into its own class we also separated the utilities, data management, as well as the constants. Our code is organized using //MARK as well as groups and comments while maintaining the appropriate style.  

##Credits
Strawberry: http://www.clipartlord.com/wp-content/uploads/2015/02/strawberry11.png
Background: http://cache1.asset-cache.net/xc/477438964.jpg?v=2&c=IWSAsset&k=2&d=FhKcfFb3z9WcbRxgHTz6FkGei6d2Sa6BE9vOdwxmOQEuPRSujXb1I9VTuJzaU0Oo0
Fly: http://savedelete.com/wp-content/uploads/2011/09/cartoonbug_fly.jpg
Blender: https://s-media-cache-ak0.pinimg.com/236x/67/0f/ff/670fffbd7b8e11243f0f41800210077d.jpg http://sweetclipart.com/multisite/sweetclipart/files/blender_and_fruit_smoothie.png
Music & SFX: SpriteKit Tutorial - SpriteKitSimpleGame (https://www.raywenderlich.com/42699/spritekit-tutorial-for-beginners)
Tutorial: https://www.raywenderlich.com/42699/spritekit-tutorial-for-beginners
TWControls: https://github.com/txaidw/TWControls/
SKTUtils: https://github.com/raywenderlich/SKTUtils

##Struggles
One major struggle we had was the sound. We have sound files and sound code in our game. However that sound does not play. Yet nothing actually seems to be wrong with it. When starter files we downloaded from myCourses in an attempt to troubleshoot this issue, although they were supposed to have working sound, the sound on those files also did not work. The only error we were getting had to do with loading the sound file, but when our files were placed in other projects this bug disappeared and when other sound was tried with our project the bug persisted. Even so, this was only with the SFX and the background music gave no errors at all.

Another issue we ran into was the launch screen. In Xcode the launch screen had a nice custom made background. However this would not upload to the device for whatever reason.
