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

class UserViewController: UIViewController {
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var followersSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    private var db = Firestore.firestore()
    var users = [QueryDocumentSnapshot]()
    var usersSearch = [QueryDocumentSnapshot]()
    var selectedUser : QueryDocumentSnapshot?
    var isUserSearching = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        // selected option color
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        searchContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        searchContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        tableView.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(searchByText(_:)), for: .editingChanged)
        
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        //self.refreshControl?.beginRefreshing()
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
            sender.isSelected = false
            sender.setTitleColor(.black, for: .selected)
            sender.backgroundColor = .white
        }else{
            sender.isSelected = true
            sender.backgroundColor = .black
            sender.setTitleColor(.white, for: .normal)
        }
    }
    
    
    @objc func searchByText(_ textField:UITextField){
        
   
        // check if text is empty or not
        if textField.text != "" {
            // check if user exists in user list
            let filterArr = self.users.filter({($0.get("fullName") as! String).lowercased().contains(textField.text ?? "") || ($0.get("fullName") as! String).uppercased().contains(textField.text ?? "")})
            isUserSearching = true
            self.usersSearch = filterArr
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }else{
            // check if text is empty show all users
            isUserSearching = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
 
    }

    
}


//MARK:

extension UserViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUserSearching ? usersSearch.count : users.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = isUserSearching ? usersSearch[indexPath.row] : users[indexPath.row]
       
        let fullName = user.get("fullName") as? String
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.userName.text = fullName
        cell.followButton.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        // fetch total pairs of each user
        var totalArr = [String]()
        for k in user.data().keys {
            if k != "fullName" {
                totalArr.append(k)
            }
        }
            
        cell.assetCount.text = "\(totalArr.count) AR Assets"
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        
        //NotificationCenter.default.post(Notification.selectedUserProfileNotification(userId: selectedUser!.documentID))
        //self.presentingViewController?.dismiss(animated: true, completion: nil)

            let userProfileVc = self.storyboard?.instantiateViewController(identifier: "UserProfileViewController") as! UserProfileViewController
            userProfileVc.userId = selectedUser?.documentID
            show(userProfileVc, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
}


extension UserViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
