//
//  UserViewController.swift
//  ingine
//
//  Created by James Timberlake on 6/7/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class UserViewController: UITableViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var followersSegment: UISegmentedControl!
    
    
    private var db = Firestore.firestore()
    var users = [QueryDocumentSnapshot]()
    var selectedUser : QueryDocumentSnapshot?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        // selected option color
        
        tableView.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        tableView.tableFooterView = UIView()
        
        
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        self.refreshControl?.beginRefreshing()
        reloadUsers()
        
        // setup ui
        setupUI()
    }
    
    
    
    private func setupUI(){
        // add search icon in text field
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        imageView.image = #imageLiteral(resourceName: "search-dark")
        imageView.center = view.center
        view.addSubview(imageView)
        searchTextField.rightView = view
        searchTextField.rightViewMode = .always
        
    }
    
    //MARK: Actions
    @objc func followAction(_ sender:UIButton){
        if sender.isSelected{
            sender.backgroundColor = .black
        }else{
            sender.backgroundColor = .white
        }
    }
}

extension UserViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let fullName = user.get("fullName") as? String
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.userName.text = fullName
        cell.followButton.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
     //   cell.followButton.backgroundColor = cell.followButton.isSelected ? .black : .white
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "UsersCell")
//        cell.textLabel?.text = fullName ?? ""
//        cell.detailTextLabel?.text = user.documentID
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        NotificationCenter.default.post(Notification.selectedUserProfileNotification(userId: selectedUser!.documentID))
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
}


