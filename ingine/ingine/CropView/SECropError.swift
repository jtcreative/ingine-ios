//
//  SECropError.swift
//  ARKitImageRecognition
//
//  Created by Armen Nikoghosyan on 4/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

public enum SECropError: Error {
    case missingSuperview
    case missingImageOnImageView
    case invalidNumberOfCorners
    case nonConvexRect
    case missingImageWhileCropping
    case unknown
}
