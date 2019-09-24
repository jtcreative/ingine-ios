//
//  UIView+globalCoordinates.swift
//  ARKitImageRecognition
//
//  Created by Armen Nikoghosyan on 4/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension UIView {
    var globalPoint :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }
    var globalFrame :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
}
