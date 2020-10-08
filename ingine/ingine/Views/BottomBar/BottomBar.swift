//
//  BottomBar.swift
//  ingine
//
//  Created by Manish Dadwal on 28/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit

class BottomBar: UIView {

    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    override init(frame: CGRect) {
           super.init(frame: frame)

           //call function

           loadNib()

       }

       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)

           loadNib()

           //fatalError("init(coder:) has not been implemented")
       }

       func loadNib() {
        let bundle = Bundle(for: type(of: self))
           let nib = UINib(nibName: "BottomBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
           view.frame = bounds
           view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
           self.addSubview(view);
        
       
       }

}
