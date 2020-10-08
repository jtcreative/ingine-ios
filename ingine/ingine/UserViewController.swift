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
    var currentUser:DocumentSnapshot?
    var followingArr:[Following] = [Following]()
    
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
        
        searchTextField.addTarget(self, action: #selector(searchByText(_:)), for: .editingChanged)
        
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)

        // color of other options
        followersSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        //self.refreshControl?.beginRefreshing()
        reloadUsers()
        
        // setup ui
        setupUI()
//        getCurrentUser()
       
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
    @objc func followAction(_ sender:UIButton){
        let user = isUserSearching ? usersSearch[sender.tag] : users[sender.tag]
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
    
   
    func followingUser(_ selectedUser:QueryDocumentSnapshot)
    {
         let id = Auth.auth().currentUser?.email ?? ""
         let profileImage = selectedUser.get("profileImage") as? String
        
        if let name = selectedUser.get("fullName") as? String{
            let dictNew = ["following": FieldValue.arrayUnion([["id":selectedUser.documentID,"fullName":name, "profileImage":profileImage ?? "" ]])]
            
            
            
            IFirebaseDatabase.shared.updateData("users", document: id, data: dictNew).sink { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { (_) in
                let following = Following(fullName: name, id: selectedUser.documentID, profileImage: profileImage ?? "")
                
                self.followingArr.append(following)
                self.addMeAsFollower(selectedUser)
            }.store(in: &IFirebaseDatabase.shared.cancelBag)

            

        }
      
    }
    
    func unfollowUser(_ selectedUser:QueryDocumentSnapshot){
        let id = Auth.auth().currentUser?.email ?? ""
        let profileImage = selectedUser.get("profileImage") as? String
       
       if let name = selectedUser.get("fullName") as? String{
           let dictNew = ["following": FieldValue.arrayRemove([["id":selectedUser.documentID,"fullName":name, "profileImage":profileImage ?? "" ]])]
           
        
        IFirebaseDatabase.shared.updateData("users", document: id, data: dictNew).sink { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { (_) in
            for i in 0..<self.followingArr.count{
                if self.followingArr[i].id == selectedUser.documentID{
                    self.followingArr.remove(at: i)
                    break
                }
            }
            
            self.removeMeAsFollower(selectedUser)
        }.store(in: &IFirebaseDatabase.shared.cancelBag)

       }
    }
    
    func removeMeAsFollower(_ selectedUser:QueryDocumentSnapshot){
        
        let userName = currentUser?.data()?["fullName"] as? String
        
        let userImageUrl = currentUser?.data()?["profileImage"] as? String
        let dictNew = ["follower": FieldValue.arrayRemove([["id":currentUser?.documentID,"fullName":userName, "profileImage":userImageUrl ?? "" ]])]
//        let dict = ["follower":]
        IFirebaseDatabase.shared.updateData("users", document: selectedUser.documentID, data: dictNew).sink { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { (_) in
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    
    func addMeAsFollower(_ selectedUser:QueryDocumentSnapshot){
        
       
        
        let userName = currentUser?.data()?["fullName"] as? String
        
        let userImageUrl = currentUser?.data()?["profileImage"] as? String
        let dictNew = ["follower": FieldValue.arrayUnion([["id":currentUser?.documentID,"fullName":userName, "profileImage":userImageUrl ?? "" ]])]
//        let dict = ["follower":]
//
        
        IFirebaseDatabase.shared.updateData("users", document: selectedUser.documentID, data: dictNew).sink { (completion) in
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

                let followingObjectArray = snapshot.get("following") as? [Any]
                //  add all following of current user
                for i in (followingObjectArray ?? []){
                    let value = i as? [String:Any]
                    let fullName = value?["fullName"] as? String
                    let id = value?["id"] as? String
                    let profileImage = value?["profileImage"] as? String
                    
                    let following = Following(fullName: fullName ?? "", id: id ?? "", profileImage: profileImage ?? "")
                    
                    self.followingArr.append(following)
                    
                    
                    
                }
                
            } else {
                print("user does not exist")
                self.currentUser = nil
                
            }
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
       
    }
    
    
    @objc func searchByText(_ textField:UITextField){
        
   
        // check if text is empty or not
        if textField.text != "" {
            // check if user exists in user list
            let filterArr = self.users.filter({($0.get("fullName") as? String ?? "").lowercased().contains(textField.text ?? "") || ($0.get("fullName") as? String ?? "").uppercased().contains(textField.text ?? "")})
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

    
    // when user tap on user image
    @objc func userTabbed(_ gesture: UITapGestureRecognizer){
        guard let view = gesture.view else { return }
        let index = view.tag
        let user = isUserSearching ? usersSearch[index] : users[index]
        
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
            let profileVc = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
            mainViewController.selectedUserID = user.documentID
            mainViewController.isOtherUser = true
            mainViewController.goToController(profileVc)
        }
        
    }

    
}



//MARK: Table View delegate

extension UserViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isUserSearching ? usersSearch.count : users.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = isUserSearching ? usersSearch[indexPath.row] : users[indexPath.row]
       
        let fullName = user.get("fullName") as? String
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.userName.text = fullName
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        cell.userImage.isUserInteractionEnabled = true
        cell.userImage.tag = indexPath.row
        cell.userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userTabbed(_:))))
        // check if user already followers or not
        let followingUser = followingArr.filter({$0.id == user.documentID})
        if followingUser.count > 0 {
            cell.followButton.isSelected = true
            cell.followButton.backgroundColor = .black
            cell.followButton.setTitleColor(.white, for: .normal)
            
        }else{
            cell.followButton.isSelected = false
            cell.followButton.backgroundColor = .white
            cell.followButton.setTitleColor(.black, for: .normal)
        }
        
        // fetch total pairs of each user
        var totalArr = [String]()
        for k in user.data().keys {
            if k != "fullName" &&  k != "profileImage" && k != "follower" && k != "following"{
                totalArr.append(k)
            }
        }
            
        cell.assetCount.text = "\(totalArr.count) AR Assets"
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        NotificationCenter.default.post(Notification.selectedUserProfileNotification(userId: selectedUser!.documentID))
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
