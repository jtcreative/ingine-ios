//
//  TutorialImageView.swift
//  ingine
//
//  Created by James Timberlake on 6/17/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit

class TutorialImageViewController : UIViewController {
    var imageName:String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(imageName:String) {
        super.init(nibName: nil, bundle: nil)
        self.imageName = imageName
    }
    
    override func loadView() {
        super.loadView()
        
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: imageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension TutorialImageViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
