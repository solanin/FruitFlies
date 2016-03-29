//
//  Constants.swift
//  FruitFlies
//
//  Created by igmstudent on 3/15/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

// This file contains constant variables that can be accessed thoughout the game files

struct Constants{
    struct Font {
        static let Title = "Noteworthy-Light"
        static let Main = "MarkerFelt-Thin"
        static let text = "Noteworthy-Bold"
    }
    
    struct HUD{
        static let FontSize = CGFloat(50.0)
        static let Margin = CGFloat(10.0)
    }
    
    struct Image{
        static let BG = "background"
        static let Player = "player"
        static let Target = "target"
        static let Monster = "monster"
        static let Projectile = "projectile"
        static let Particle = "MyParticle"
        static let Smoothie0 = "smoothie0"
        static let Smoothie1 = "smoothie1"
        static let Smoothie2 = "smoothie2"
        static let Smoothie3 = "smoothie3"
        static let Smoothie4 = "smoothie4"
        static let Smoothie5 = "smoothie5"
    }
    
    struct Label{
        static let title = "Fruit Flies"
        static let startBtn = "Play"
        static let collected = "Smoothies: "
        static let highScore = "High Score: "
        static let killed = "Swatted: "
        static let fuel = "Fuel: "
        static let smoothie = "Progress: "
        static let lives = "Lives: "
        static let loseMessage = "You Lose"
        static let hsMessage = "Your Score: "
        static let hsMessageAnnounce = "HIGH SCORE!"
    }
    
    struct Sound{
        static let shooting = "pew-pew-lei.caf"
        static let background = "background-music-aac.caf"
    }
    
    struct Color {
        static let BackgroundColor = SKColor(red: 0.51, green: 0.86, blue: 1.0, alpha: 0.0)
        static let HUDFontColor = SKColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
        static let MenuColor = SKColor(red: 0.51, green: 0.86, blue: 1.0, alpha: 0.0)
        static let MenuFontColor = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        static let MenuButton = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        static let MenuButtonClicked = SKColor(red: 0.1, green: 0.0, blue: 0.1, alpha: 1.0)
        static let MenuButtonFont = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let Bar = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        static let Fuel = SKColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        static let Smoothie = SKColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        
    }
}