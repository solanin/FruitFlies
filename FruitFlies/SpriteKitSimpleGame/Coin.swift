//
//  Coin.swift
//  FruitFlies
//
//  Created by igmstudent on 3/15/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit

class MyDiamond:SKShapeNode{
    // MARK: - ivars -
    var hit:Bool = false
    
    // MARK: - Initialization -
    init(size:CGSize) {
        super.init()
        let halfHeight = size.height/2.0
        let halfWidth = size.width/2.0
        
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0, halfHeight)
        CGPathAddLineToPoint(pathToDraw, nil, halfWidth , 0)
        CGPathAddLineToPoint(pathToDraw, nil, 0, -halfHeight)
        CGPathAddLineToPoint(pathToDraw, nil, -halfWidth, 0)
        CGPathCloseSubpath(pathToDraw)
        path = pathToDraw
        strokeColor = UIColor.yellowColor()
        lineWidth = 5
        fillColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
}