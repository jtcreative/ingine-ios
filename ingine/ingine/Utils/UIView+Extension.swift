//
//  UIView+Extension.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit
extension UIView{
    
    func setRadius(_ value:CGFloat){
        self.layer.cornerRadius = value
        self.clipsToBounds = true
    }
    
    
    func setGradientBackground() {
        let colorTop =  UIColor(named: "backgroundGray")!.cgColor
        let colorBottom = UIColor.black.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
                
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    func setCustomGradient(_ colors:[CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
                
        self.layer.insertSublayer(gradientLayer, at:0)
    }
}
