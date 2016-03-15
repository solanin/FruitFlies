//
//  MyUtilities.swift
//  FruitFlies
//
//  Created by igmstudent on 3/15/16.
//  Copyright © 2016 igmstudent. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - Methods -
func getScreenAspectRatioPortrait()->CGFloat{
    return UIScreen.mainScreen().bounds.width / UIScreen.mainScreen().bounds.height
}

func getScreenAspectRatioLandscape()->CGFloat{
    return UIScreen.mainScreen().bounds.height / UIScreen.mainScreen().bounds.width
}

func randomCGPointInRect(rect:CGRect,margin:CGFloat)->CGPoint{
    let x = CGFloat.random(min: rect.minX + margin, max: rect.maxX - margin)
    let y = CGFloat.random(min: rect.minY + margin, max: rect.maxY - margin)
    return CGPointMake(x,y)
}
/*

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
*/

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

// MARK: - Extention -

extension CGPoint{
    public static func randomUnitVector()->CGPoint{
        let vector = CGPointMake(CGFloat.random(min:-1.0,max:1.0),CGFloat.random(min:-1.0,max:1.0))
        return vector.normalized()
    }
    /*
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    */
}