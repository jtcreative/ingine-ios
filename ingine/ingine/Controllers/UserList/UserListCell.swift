//
//  UserListCell.swift
//  ingine
//
//  Created by Manish Dadwal on 29/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var assetCount: UILabel!
    @IBOutlet weak var followButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        // setup ui
        containerView.layer.cornerRadius = containerView.frame.height / 2
        userImage.layer.cornerRadius = userImage.frame.height / 2        
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        followButton.layer.cornerRadius = 8
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
