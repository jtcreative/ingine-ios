//
//  Loader.swift
//  247FamilLaw
//
//  Created by Geek Tech on 17/03/20.
//  Copyright © 2020 Geek Tech. All rights reserved.
//

import UIKit


class Loader:NSObject{
    
    static var spinner: UIActivityIndicatorView?
    static var baseBackColor = UIColor(white: 0, alpha: 0.6)
    static var baseColor = UIColor.white
   
    
   
    static func start(backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        if spinner == nil, let window = UIApplication.shared.windows.first {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            if #available(iOS 13.0, *) {
                spinner!.style = .large
            }else{
                spinner!.style = .whiteLarge
            }
          
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
}
