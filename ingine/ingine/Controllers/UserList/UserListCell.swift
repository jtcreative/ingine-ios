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
    var user:User!{
        didSet{
            updateUser(user)
        }
    }
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
    private func updateUser(_ user:User){
        let fullName = user.fullName
        
        userName.text = fullName
        print("user.profileImage", user.profileImage)
        if  let imageUrl = URL(string: user.profileImage){
            DispatchQueue.global().async {
                if let imageData:NSData = NSData(contentsOf: imageUrl){
                    DispatchQueue.main.async {
                        self.userImage.image = UIImage(data: imageData as Data)
                    }
                } //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
               
            }
            
        }else{
            self.userImage.image = #imageLiteral(resourceName: "logo")
            self.userImage.backgroundColor = .black
        }
        
        assetCount.text = "\(user.assetCount) AR Assets"
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
