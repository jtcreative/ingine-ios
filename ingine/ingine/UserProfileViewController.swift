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

/*class IngineeredItemViewCell: UITableViewCell {

    @IBOutlet weak var refImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemURL: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var visibilityStatus: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var linkView: UIView!
    var id : String = ""
   
    let optionsLauncher = OptionsLauncher()
    @IBAction func showOptions(_ sender: UIButton) {
        optionsLauncher.showOptions(identification: id)

    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        // setup ui
        contentView.subviews[0].layer.cornerRadius = 16
        linkView.layer.cornerRadius = linkView.frame.height / 2
        itemName.text = ""
        itemURL.text = ""
        viewsLabel.text = ""
        timeStamp.text = ""
    }
    
}*/



class UserProfileViewController: UIViewController {
    public var userId : String?
    var itemsArray : [IngineeredItem] = [IngineeredItem]()
 
    @IBOutlet weak var ingineeredItemsTableView: UITableView!
    
    @IBOutlet weak var profileHeaderView: ProfileViewHeader!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var header: UIView!
    var userImage = ""
     var firebaseSnapshotId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init firebase manager
        self.view.backgroundColor = .white
        ingineeredItemsTableView.backgroundColor = .white
        
        guard let currentUserId = userId else {
            return
        }
        
        ingineeredItemsTableView.register(ProfileViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: "ProfileViewHeaderCell")
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Set delegate and data source
        ingineeredItemsTableView.delegate = self
        ingineeredItemsTableView.dataSource = self
        
        // Configure table view
        configureTableView()
        //addFollowers()
        // Check if user logged in by email
        //isLoggedIn()
        
        // retrieve ingineered items
        retrieveItems()
        setupProfileHeader()
        // ingineeredItemsTableView.separatorStyle = .none
        
        
        
    }
    
    
    func followUser()
    {
         let id = Auth.auth().currentUser?.email ?? ""
        
        let dict = ["follower":[["userId":"userid1234","username":"Mike"],["userId":"userid89ds","username":"John"]]]
        Firestore.firestore().collection("users").document(id).updateData(dict) { (error) in
            if let error = error{
                 print("Document error:\(error)")
            }else{
                print("Document is written successfully")
            }
        }
    }
    
    func unfolloeUser()
    {
        
    }
    
    // setup profile header view
    private func setupProfileHeader(){
        profileHeaderView.profileView.setRadius(profileHeaderView.profileView.frame.height / 2)
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        profileHeaderView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        profileHeaderView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        profileHeaderView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        profileHeaderView.settingButton.isHidden = true
    }
    
   
    
    // Configure table view height
    func configureTableView() {
        ingineeredItemsTableView.rowHeight = UITableView.automaticDimension
        ingineeredItemsTableView.estimatedRowHeight = 120
    }
    

    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileViewHeaderCell") as? ProfileViewHeaderCell
        return viewHeaderCell
    }*/
    
    
    
    @objc func openProfileSetting(){
         //performSegue(withIdentifier: "profileSettings", sender: nil)
    }
    
   
    @IBAction func goBackHome() {
        //performSegue(withIdentifier: "toHome", sender: nil)
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
            //performSegue(withIdentifier: "toProfile", sender: nil)
            mainViewController.backPage()
     }
        //
        
        
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSettings" {
            if let controller = segue.destination as? ProfileSettingsViewController{
//                controller.userImageStr = userImage
            }
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    
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
            let imageData:NSData = NSData(contentsOf: imageUrl)! //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.refImage.image = UIImage(data: imageData as Data)
            }
        }
        
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
    
    /*func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }*/
    
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
    // Retrieve ingineered item infro from firebase
       func retrieveItems() {
           print("retrieving data from firebase...")
        guard let profileUserId = userId else {
            return
        }
           
           // Populate cell elements with data from firebase
            //let id = Auth.auth().currentUser?.email ?? ""
           
        //   firebaseManager?.getDocuments("users", documentName: id, type: .multipleItem)
        IFirebaseDatabase.shared.getUser("users", document: profileUserId).sink(receiveCompletion: { (completion) in
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
                        IFirebaseDatabase.shared.getAssetList("pairs", document: k).sink(receiveCompletion: { (completion) in
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
                            print(self.itemsArray)
                            self.profileHeaderView.arPostCount.text = "\(self.itemsArray.count)"
                            self.configureTableView()
                            DispatchQueue.main.async {
                                self.ingineeredItemsTableView.reloadData()
                            }
                            
                        }.store(in: &IFirebaseDatabase.shared.cancelBag)
                        
                        
                    }else {
                        print("k is fullName")
                    }
                    
                }
            }
        }.store(in: &IFirebaseDatabase.shared.cancelBag)

           
       }
}

