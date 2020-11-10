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

class ProfileViewHeaderCell : UITableViewHeaderFooterView {
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

class IngineeredItemViewCell: UITableViewCell {

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
    
}




class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        
        ingineeredItemsTableView.register(ProfileViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: "ProfileViewHeaderCell")
        ingineeredItemsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        //let profileHeader = ProfileViewHeader(frame: profileHeaderView.frame)
        
        //ingineeredItemsTableView.tableHeaderView = profileHeader
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Set delegate and data source
        ingineeredItemsTableView.delegate = self
        ingineeredItemsTableView.dataSource = self
        
        // Configure table view
        configureTableView()
       

        setupProfileHeader()
    }
    
    
    
    // setup profile header view
    private func setupProfileHeader(){
        profileHeaderView.profileView.setRadius(profileHeaderView.profileView.frame.height / 2)
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        profileHeaderView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        profileHeaderView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        profileHeaderView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        profileHeaderView.settingButton.addTarget(self, action: #selector(openProfileSetting), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if user logged in by email
        isLoggedIn()
        
        // retrieve ingineered items
        retrieveItems()
    }
    
   
    
    // Configure table view height
    func configureTableView() {
        ingineeredItemsTableView.rowHeight = UITableView.automaticDimension
        ingineeredItemsTableView.estimatedRowHeight = 120
    }
    
    // Set cells data in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "igItemCell", for: indexPath) as! IngineeredItemViewCell

        // set cell fields info from firebase
        cell.id = itemsArray[indexPath.row].id
        let imageUrl = URL(string: itemsArray[indexPath.row].refImage)!
        cell.optionsLauncher.delegate = self
        
        DispatchQueue.global().async {
            guard let imageData = NSData(contentsOf: imageUrl) else {
                return
            }
            
            //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
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
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeaderCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileViewHeaderCell") as? ProfileViewHeaderCell
        return viewHeaderCell
    }*/
    
    
    
    @objc func openProfileSetting(){
         performSegue(withIdentifier: "profileSettings", sender: nil)
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
            DispatchQueue.main.async {
                if let controller = segue.destination as? ProfileSettingsViewController{
    //                controller.userImageStr = userImage
                    controller.delegate = self
                }
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
    
    
    @IBAction func signOut(_ sender: Any) {
       
//        firebaseManager?.signOut()
        FirebaseUserService.shared.signOut().sink(receiveCompletion: { (completion) in
            switch completion{
            case .finished: print("fnished")
            case .failure(let error) : print(error.localizedDescription)
            }
        }) { (_) in
            print("Sign out pressed")
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        }.store(in: &FirebaseUserService.shared.cancelBag)
    
        
    }

    
}

extension ProfileViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

extension ProfileViewController:UserProfileUpdateDelegate{
    func didUpdateUser() {
        isLoggedIn()
    }
}

extension ProfileViewController:UpdateARItemLauncherDelegate{
    func delete(itemId: String) {
        // get index of deleted item
        let indexToRemove = itemsArray.firstIndex { $0.id == itemId}
        // remove item from main array
        itemsArray.remove(at: indexToRemove ?? 0)
        // delete row from tableview
        ingineeredItemsTableView.deleteRows(at: [IndexPath(row: indexToRemove ?? 0, section: 0)], with: .automatic)
        
    }
}
