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
import FirebaseAuth

class UserViewController: UIViewController {
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var followButtons: [UIButton]!
    
    var noResultsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.text = "Search user..."
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    
    private var db = Firestore.firestore()
    
    var selectedUser : User?
    var isUserSearching = false
    var currentUser:DocumentSnapshot?
    var isUserSeeFollowing = false
    
    var users = [User]()
    var usersSearch = [User]()
    var followingArr:[User] = [User]()
    var followersArr:[User] = [User]()
    var finalArr :[User] = [User]()
    
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
        searchContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        searchContainerView.backgroundColor = .black
        tableView.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        /// setup label
        view.addSubview(noResultsLabel)
        noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        
        searchTextField.addTarget(self, action: #selector(searchByText(_:)), for: .editingChanged)
        
    
        
        //self.refreshControl?.beginRefreshing()
        reloadUsers()
        setupFollowingButtons()
        // setup ui
        setupUI()
//        getCurrentUser()
       
    }
    
    private func setupFollowingButtons(){
        
        followButtons.forEach { btn in
            btn.layer.cornerRadius = 6
            btn.layer.borderWidth = 0.5
            btn.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUser()
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
    
    @IBAction func followingAction(_ sender: UIButton) {
        finalArr = followingArr
        followButtons.forEach { btn in
            if btn.tag == sender.tag{
                btn.backgroundColor = .black
                btn.setTitleColor(.white, for: .normal)
            }else{
                btn.backgroundColor = .white
                btn.setTitleColor(.black, for: .normal)
            }
        }
        // show no results if value is 0
        
        if finalArr.count > 0{
            noResultsLabel.isHidden = true
        }else{
            noResultsLabel.isHidden = false
            noResultsLabel.text = "You didn't follow anyone yet."
        }
        
        isUserSeeFollowing = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    @IBAction func followersAction(_ sender: UIButton) {
        finalArr = followersArr
        followButtons.forEach { btn in
            if btn.tag == sender.tag{
                btn.backgroundColor = .black
                btn.setTitleColor(.white, for: .normal)
            }else{
                btn.backgroundColor = .white
                btn.setTitleColor(.black, for: .normal)
            }
        }
        
        
        // show no results if value is 0
        
        if finalArr.count > 0{
            noResultsLabel.isHidden = true
        }else{
            noResultsLabel.isHidden = false
            noResultsLabel.text = "You have no followers."
        }
        
        
        isUserSeeFollowing = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @objc func followAction(_ sender:UIButton){
        
        var user:User!
        if isUserSeeFollowing{
            user = finalArr[sender.tag]
        }else{
            user = isUserSearching ? usersSearch[sender.tag] : users[sender.tag]
        }
        
       
        if sender.isSelected{
            sender.isSelected = false
            sender.setTitleColor(.black, for: .normal)
            sender.backgroundColor = .white
           
            unfollowUser(user)
        }else{
            sender.isSelected = true
            sender.backgroundColor = .black
            sender.setTitleColor(.white, for: .normal)
        
            followingUser(user)
        }
    }
    
   
    func followingUser(_ selectedUser:User)
    {
         let id = Auth.auth().currentUser?.email ?? ""
         let profileImage = selectedUser.profileImage
        
         let name = selectedUser.fullName
        let dictNew = ["following": FieldValue.arrayUnion([["id":selectedUser.id,"fullName":name, "profileImage":profileImage, "assetCount":selectedUser.assetCount ]])]
            
            
            IFirebaseDatabase.shared.updateData("users", document: id, data: dictNew).sink { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { (_) in
                let user = User(fullName: name, id: selectedUser.id, profileImage: profileImage, assetCount: selectedUser.assetCount, isFollowing:true)
                
                self.followingArr.append(user)
                self.addMeAsFollower(selectedUser)
            }.store(in: &IFirebaseDatabase.shared.cancelBag)

            

        
      
    }
    
    func unfollowUser(_ selectedUser:User){
        let id = Auth.auth().currentUser?.email ?? ""
        let profileImage = selectedUser.profileImage
       
        let name = selectedUser.fullName
           let dictNew = ["following": FieldValue.arrayRemove([["id":selectedUser.id,"fullName":name, "profileImage":profileImage,"assetCount":selectedUser.assetCount ]])]
           
        
        IFirebaseDatabase.shared.updateData("users", document: id, data: dictNew).sink { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { (_) in
            for i in 0..<self.followingArr.count{
                if self.followingArr[i].id == selectedUser.id{
                    
                    self.followingArr.remove(at: i)
                    let indexToRemove = self.finalArr.firstIndex(where: {$0.id == selectedUser.id}) ?? 0
                    self.finalArr.remove(at: indexToRemove)
                    self.tableView.deleteRows(at: [IndexPath(row: indexToRemove, section: 0)], with: .left)
                    
                    break
                }
            }
            
            self.removeMeAsFollower(selectedUser)
        }.store(in: &IFirebaseDatabase.shared.cancelBag)

       
    }
    
    func removeMeAsFollower(_ selectedUser:User){
        
        let userName = currentUser?.data()?["fullName"] as? String
        
        let userImageUrl = currentUser?.data()?["profileImage"] as? String
        
        
        let keys = currentUser?.data()?.keys
        var assests = [String]()
        for k in keys!{
            if k != "fullName" &&  k != "profileImage" && k != "follower" && k != "following"{
                assests.append(k)
            }
           
        }
        
        
        
        let dictNew = ["follower": FieldValue.arrayRemove([["id":currentUser?.documentID ?? "","fullName":userName ?? "", "profileImage":userImageUrl ?? "", "assetCount":assests.count ]])]
//        let dict = ["follower":]
        IFirebaseDatabase.shared.updateData("users", document: selectedUser.id, data: dictNew).sink { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { (_) in
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    
    func addMeAsFollower(_ selectedUser:User){
        
       
        
        let userName = currentUser?.data()?["fullName"] as? String
        
        let userImageUrl = currentUser?.data()?["profileImage"] as? String
        
        let keys = currentUser?.data()?.keys
        var assests = [String]()
        for k in keys!{
            if k != "fullName" &&  k != "profileImage" && k != "follower" && k != "following"{
                assests.append(k)
            }
           
        }
        
        let dictNew = ["follower": FieldValue.arrayUnion([["id":currentUser?.documentID ?? "","fullName":userName ?? "", "profileImage":userImageUrl ?? "", "assetCount":assests.count ]])]
//        let dict = ["follower":]
//
        
        IFirebaseDatabase.shared.updateData("users", document: selectedUser.id, data: dictNew).sink { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { (_) in
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
        
    }
    
    
    func getCurrentUser(){
        // remove pervious values
        followingArr.removeAll()
        followersArr.removeAll()
        
        
        let id = Auth.auth().currentUser?.email ?? ""
        IFirebaseDatabase.shared.getDocument("users", document: id).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { (snapshot) in
            
            if snapshot.exists {
                self.currentUser = snapshot
                //get following
                let followingObjectArray = snapshot.get("following") as? [Any]
                //  add all following of current user
                for i in (followingObjectArray ?? []){
                    let value = i as? [String:Any]
                    let fullName = value?["fullName"] as? String
                    let id = value?["id"] as? String
                    let profileImage = value?["profileImage"] as? String
                    let assetCount = value?["assetCount"] as? Int ?? 0
                    let user = User(fullName: fullName ?? "", id: id ?? "", profileImage: profileImage ?? "", assetCount: assetCount, isFollowing:true)
                    
                    self.followingArr.append(user)
                }
                
                //get followers
                let followerObjectArray = snapshot.get("follower") as? [Any]
                //  add all follower of current user
                for i in (followerObjectArray ?? []){
                    let value = i as? [String:Any]
                    let fullName = value?["fullName"] as? String
                    let id = value?["id"] as? String
                    let profileImage = value?["profileImage"] as? String
                    let assetCount = value?["assetCount"] as? Int ?? 0
                    let user = User(fullName: fullName ?? "", id: id ?? "", profileImage: profileImage ?? "", assetCount: assetCount, isFollowing:false)
        
                    self.followersArr.append(user)
                }
            } else {
                print("user does not exist")
                self.currentUser = nil
                
            }
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
       
    }
    
    
    @objc func searchByText(_ textField:UITextField){
        
        // set to default followers button
        if isUserSeeFollowing{
            isUserSeeFollowing = false
            followButtons.forEach { btn in
                btn.backgroundColor = .white
                btn.setTitleColor(.black, for: .normal)
               
            }
        }
       
        // check if text is empty or not
        if textField.text != "" {
            // check if user exists in user list
            
            let filterArr = self.users.filter {$0.fullName.lowercased().contains(textField.text ?? "") || $0.fullName.uppercased().contains(textField.text ?? "")}
            isUserSearching = true
            
            print("searched list of filterArr", filterArr.count)
            self.usersSearch = filterArr
            print("searched list of row", users.count)
            if self.usersSearch.count == 0 {
                noResultsLabel.isHidden = false
                noResultsLabel.text = "No user found..."
            }else{
                noResultsLabel.isHidden = true
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            
        }else{
            noResultsLabel.text = "Search user..."
            // check if text is empty show all users
//            isUserSearching = false
            self.usersSearch.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
 
    }

    
    // when user tap on user image
    @objc func userTabbed(_ gesture: UITapGestureRecognizer){
        guard let view = gesture.view else { return }
        let index = view.tag
        var selectedID:Any?
        if isUserSeeFollowing{
            let user = isUserSearching ? usersSearch[index] : users[index]
            selectedID = user.id
        }else{
           let user = finalArr[index]
            selectedID = user.id
        }
       
        
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
            let profileVc = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
            mainViewController.selectedUserID = selectedID
            mainViewController.isOtherUser = true
            mainViewController.goToController(profileVc)
        }
        
    }

    
}



//MARK: Table View delegate

extension UserViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // check if user tabbed following or followers tab
        if isUserSeeFollowing{
            return finalArr.count
        }
        // if user searching user
        return isUserSearching ? usersSearch.count : users.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        var user:User!
        if isUserSeeFollowing{
            user = finalArr[indexPath.row]
        }else{
            user = isUserSearching ? usersSearch[indexPath.row] : users[indexPath.row]
        }
        
        
        cell.user = user
        cell.followButton.isHidden = user.id == currentUser?.documentID ? true : false
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        cell.userImage.isUserInteractionEnabled = true
        cell.userImage.tag = indexPath.row
        cell.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTabbed(_:))))
        // check if user already followers or not
        let followingUser = followingArr.filter({$0.id == user.id})
        if user.isFollowing || followingUser.count > 0{
            cell.followButton.isSelected = true
            cell.followButton.backgroundColor = .black
            cell.followButton.setTitleColor(.white, for: .normal)
        }else{
            cell.followButton.isSelected = false
            cell.followButton.backgroundColor = .white
            cell.followButton.setTitleColor(.black, for: .normal)
        }
        

  
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        NotificationCenter.default.post(Notification.selectedUserProfileNotification(userId: selectedUser!.id))
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
