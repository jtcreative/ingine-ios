//
//  ProfileViewHeader.swift
//  ingine
//
//  Created by Manish Dadwal on 17/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit

class ProfileViewHeader: UIView {
    
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followerAndFollowingLabel: UILabel!
    @IBOutlet weak var arPostCount: UILabel!
    
    @IBOutlet weak var profileView: UIView!
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
           let nib = UINib(nibName: "ProfileViewHeader", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
           view.frame = bounds
           view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           self.addSubview(view);
       }

}
