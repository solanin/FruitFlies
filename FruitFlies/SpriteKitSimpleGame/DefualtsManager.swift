//
//  DefualtsManager.swift
//  FruitFlies
//
//  Created by igmstudent on 3/15/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
class DefaultsManager{
    
    //SAVES and LOADS data for the game
    
    // MARK: - ivars -
    static let sharedDefaultsManager = DefaultsManager() // single instance
    let HIGH_SCORE_KEY = "highScoreKey"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - Initialization -
    // This prevents others from using the default initializer for this class.
    private init() {}
    
    // MARK: - Methods -
    
    // Gets amt of flies swatted
    func getHighScore()->Int{
        if let highScore:Int? = defaults.integerForKey(HIGH_SCORE_KEY){
            print("value for highScoreKey found = \(highScore)")
            return highScore!
        }else{
            print("no value for highScoreKey found")
            return 0
        }
    }
    
    // Saves amt of flies swatted
    func setHighScore(score:Int){
        defaults.setInteger(score, forKey: HIGH_SCORE_KEY)
        defaults.synchronize() // write to disk
        print("setting value for highScoreKey = \(score)")
    }
}