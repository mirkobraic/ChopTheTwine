//
//  CGPoint.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 06/01/2021.
//

import UIKit

extension CGPoint {
    func distance(toPoint point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}
