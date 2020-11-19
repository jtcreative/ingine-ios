//
//  UserProfileViewController.swift
//  ingine
//
//  Created by James Timberlake on 10/4/20.
//  Copyright © 2020 ingine. All rights reserved.
//

//
//  ProfileViewController.swift
//  ingine
//
//  Created by McNels on 6/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import FirebaseAuth
import FirebaseFirestore


protocol UserProfileFollowingUpdateDelegate:class {
    func didUpdateUserFollowing()
}



class UserProfileViewHeaderCell : UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addProfileView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addProfileView()
    }
    
    
    private func addProfileView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProfileHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        //view.frame = bounds
        //view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
    }
    
}


class UserProfileViewController: UIViewController {
    public var userId : String?
    var itemsArray : [IngineeredItem] = [IngineeredItem]()
 
    @IBOutlet weak var ingineeredItemsTableView: UITableView!
    
    @IBOutlet weak var profileHeaderView: ProfileViewHeader!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var header: UIView!
    var userImage = ""
     var firebaseSnapshotId = ""
    weak var delegate:UserProfileFollowingUpdateDelegate?
    
    var currentUser:DocumentSnapshot?
    var selectedUser:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        // init firebase manager
        self.view.backgroundColor = .white
        ingineeredItemsTableView.backgroundColor = .white
        
        guard let currentUserId = userId else {
            return
        }
        
        ingineeredItemsTableView.register(ProfileViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: "ProfileViewHeaderCell")
        ingineeredItemsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Set delegate and data source
        ingineeredItemsTableView.delegate = self
        ingineeredItemsTableView.dataSource = self
        
        // Configure table view
        configureTableView()
     
        
        // retrieve ingineered items
        retrieveItems()
        setupProfileHeader()
        // ingineeredItemsTableView.separatorStyle = .none

    }
    
    
    
    
    // setup profile header view
    private func setupProfileHeader(){
        profileHeaderView.profileView.setRadius(profileHeaderView.profileView.frame.height / 2)
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        profileHeaderView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        profileHeaderView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        profileHeaderView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        profileHeaderView.followButton.addTarget(self, action: #selector(followAction(_:)), for: .touchUpInside)
        profileHeaderView.settingButton.isHidden = true
        profileHeaderView.followerAndFollowingLabel.isHidden = true
        profileHeaderView.followButton.isHidden = false
        profileHeaderView.followButton.layer.cornerRadius = profileHeaderView.followButton.frame.height / 2
    }
    
   
    
    // Configure table view height
    func configureTableView() {
        ingineeredItemsTableView.rowHeight = UITableView.automaticDimension
        ingineeredItemsTableView.estimatedRowHeight = 120
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUser()
    }
    
    @objc func followAction(_ sender:UIButton){
   
        if let user = selectedUser{
            if sender.titleLabel?.text == "Following"{
                
                self.profileHeaderView.followButton.setTitle("Follow", for: .normal)
              
                self.profileHeaderView.followButton.setTitleColor(.black, for: .normal)
                self.profileHeaderView.followButton.backgroundColor = .white
                unfollowUser(user)
            }else{
                self.profileHeaderView.followButton.setTitle("Following", for: .normal)
                self.profileHeaderView.followButton.setTitleColor(.white, for: .normal)
                self.profileHeaderView.followButton.backgroundColor = .black
               
            
                followingUser(user)
            }
        }
        
    }
    
   
    func followingUser(_ selectedUser:User)
    {
         let id = Auth.auth().currentUser?.email ?? ""
         let profileImage = selectedUser.profileImage
        
         let name = selectedUser.fullName
        let dictNew = ["following": FieldValue.arrayUnion([["id":selectedUser.id,"fullName":name, "profileImage":profileImage, "assetCount":selectedUser.assetCount ]])]
            
            FirebaseARService.shared.updateData("users", document: id, data: dictNew).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { (_) in
                self.profileHeaderView.followButton.setTitle("Following", for: .normal)
                self.profileHeaderView.followButton.setTitleColor(.white, for: .normal)
                self.profileHeaderView.followButton.backgroundColor = .black
                self.delegate?.didUpdateUserFollowing()
                self.addMeAsFollower(selectedUser)
            }).store(in: &FirebaseARService.shared.cancelBag)


      
    }
    
    func unfollowUser(_ selectedUser:User){
        let id = Auth.auth().currentUser?.email ?? ""
        let profileImage = selectedUser.profileImage
       
        let name = selectedUser.fullName
           let dictNew = ["following": FieldValue.arrayRemove([["id":selectedUser.id,"fullName":name, "profileImage":profileImage,"assetCount":selectedUser.assetCount ]])]
           
        
        FirebaseARService.shared.updateData("users", document: id, data: dictNew).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { (_) in
            self.profileHeaderView.followButton.setTitle("Follow", for: .normal)
          
            self.profileHeaderView.followButton.setTitleColor(.black, for: .normal)
            self.profileHeaderView.followButton.backgroundColor = .white

            self.delegate?.didUpdateUserFollowing()
            self.removeMeAsFollower(selectedUser)
        }).store(in: &FirebaseARService.shared.cancelBag)

       
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
        FirebaseARService.shared.updateData("users", document: selectedUser.id, data: dictNew).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { (_) in
        }).store(in: &FirebaseARService.shared.cancelBag)
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
//
        
        FirebaseARService.shared.updateData("users", document: selectedUser.id, data: dictNew).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { (_) in
        }).store(in: &FirebaseARService.shared.cancelBag)
        
    }
    
    
    @objc func openProfileSetting(){
         //performSegue(withIdentifier: "profileSettings", sender: nil)
    }
    
   
    @IBAction func goBackHome() {
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
            mainViewController.backPage()
     }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSettings" {
            if let controller = segue.destination as? ProfileSettingsViewController{
//                controller.userImageStr = userImage
            }
        }
    }
    
    

    // handle swipe gestures from home screen
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        /*if (sender.direction == .right) {
            print("Swipe Right")
            // go back home
            goBackHome()
        }*/
    }

    
}

extension UserProfileViewController : UITableViewDelegate, UITableViewDataSource {
    // Set cells data in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "igItemCell", for: indexPath) as! IngineeredItemViewCell

        // set cell fields info from firebase
        cell.id = itemsArray[indexPath.row].id
        let imageUrl = URL(string: itemsArray[indexPath.row].refImage)!
        
        DispatchQueue.global().async {
            if let imageData:NSData = NSData(contentsOf: imageUrl) { //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.refImage.image = UIImage(data: imageData as Data)
                }
            }
        }
        print("itemname: \(itemsArray[indexPath.row].itemName)")
        print("itemname: \(itemsArray[indexPath.row].itemURL)")
        cell.itemName.text = itemsArray[indexPath.row].itemName
        cell.itemURL.text = itemsArray[indexPath.row].itemURL
        if itemsArray[indexPath.row].visStatus {
           // cell.visibilityStatus.text = "Public"
        } else {
           // cell.visibilityStatus.text = "Private"
        }

        return cell
    }
    
    // Set number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    // show url on cell clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected: \(indexPath.row)")
        guard let url = URL(string: itemsArray[indexPath.row].itemURL) else {
            //Show an invalid URL error alert
            return
        }
        

        // Show the associated link in the in-app browser
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
        
    }
}

extension UserProfileViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

extension UserProfileViewController {
    
    
    func getCurrentUser(){
        // remove pervious values

        let currentUser = Auth.auth().currentUser?.email ?? ""
        let selectedUser = userId ?? ""
        FirebaseARService.shared.getDocument("users", document: selectedUser).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { [unowned self](snapshot) in
            
            if snapshot.exists {
             
               User().dictToUser(dict: snapshot.data()!, id: snapshot.documentID, {
                    user in
                    self.selectedUser = user
                    self.profileHeaderView.userName.text = user.fullName
                    
                    for followUser in user.followers{
                        if followUser.id == currentUser{
                            self.profileHeaderView.followButton.setTitle("Following", for: .normal)
                            self.profileHeaderView.followButton.setTitleColor(.white, for: .normal)
                            self.profileHeaderView.followButton.backgroundColor = .black
                            
                        }else{
                            self.profileHeaderView.followButton.setTitle("Follow", for: .normal)
                            self.profileHeaderView.followButton.setTitleColor(.black, for: .normal)
                            self.profileHeaderView.followButton.backgroundColor = .white
                        }
                    }
                
                })
               
                
            } else {
                print("user does not exist")
                self.currentUser = nil
                
            }
        }.store(in: &FirebaseARService.shared.cancelBag)
       
    }
    
    // Retrieve ingineered item infro from firebase
       func retrieveItems() {
           print("retrieving data from firebase...")
        guard let profileUserId = userId else {
            return
        }
           
        FirebaseARService.shared.getUser("users", document: profileUserId).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { (snapShot) in
            guard snapShot.data() != nil else {
                print("Document data was empty.")
                return
            }
                          
                          
            if snapShot.exists {
                for k in snapShot.data()!.keys {
                    if k != "fullName" {
                        FirebaseARService.shared.getAssetList("pairs", document: k).sink(receiveCompletion: { (completion) in
                            switch completion
                            {
                            case .finished : print("finish")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }) { (shot) in
                           
                            var item = IngineeredItem()
                                item.id = k
                            item.itemName = shot.name ?? ""
                            item.refImage = shot.refImage ?? ""
                            item.itemURL = shot.matchURL ?? ""
                            item.visStatus = shot.public ?? false
                            self.itemsArray.append(item)
                           
                            self.itemsArray = self.itemsArray.unique{$0.id}
                            
                            self.itemsArray =  self.itemsArray.filter {$0.visStatus }
                            print(self.itemsArray)
                            self.profileHeaderView.arPostCount.text = "\(self.itemsArray.count)"
                            self.configureTableView()
                            DispatchQueue.main.async {
                                self.ingineeredItemsTableView.reloadData()
                            }
                            
                        }.store(in: &FirebaseARService.shared.cancelBag)
                        
                        
                    }else {
                        print("k is fullName")
                    }
                    
                }
            }
        }.store(in: &FirebaseARService.shared.cancelBag)

           
       }
}

