//
//  CGPoint+geometry.swift
//  ARKitImageRecognition
//
//  Created by Armen Nikoghosyan on 4/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension CGPoint {
    func cartesian(for size: CGSize) -> CGPoint {
        return CGPoint(x: x, y: size.height - y)
    }
    static func cross(a: CGPoint, b: CGPoint) -> CGFloat {
        return a.x * b.y - a.y * b.x
    }
    func normalized(size: CGSize) -> CGPoint {
        return CGPoint(x: max(min(x, size.width), 0), y: max(min(y, size.height), 0))
    }
}
