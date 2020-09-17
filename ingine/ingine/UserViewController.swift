//
//  UserViewController.swift
//  ingine
//
//  Created by James Timberlake on 6/7/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserViewController: UITableViewController {
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
      
        
        self.refreshControl?.beginRefreshing()
        reloadUsers()
    }
}

extension UserViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let fullName = user.get("fullName") as? String
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "UsersCell")
        cell.textLabel?.text = fullName ?? ""
        cell.detailTextLabel?.text = user.documentID
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        NotificationCenter.default.post(Notification.selectedUserProfileNotification(userId: selectedUser!.documentID))
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}


