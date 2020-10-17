//
//  ProfileSettingsViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 17/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileSettingsViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var appGuide: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editUserName: UIButton!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var signOut: UIButton!
    
    //MARK: Properties
    var userImageStr = ""
    var imagePicker = UIImagePickerController()
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    private func setupUI(){
        imagePicker.delegate = self
        
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        emailView.layer.cornerRadius = 8
        notificationView.layer.cornerRadius = 8
        appGuide.layer.cornerRadius = 8
        saveButton.layer.cornerRadius = 8
        signOut.layer.cornerRadius = 8
        
        // fetch user
        fetchUser()
        
        
    }
    
    
    @IBAction func editUsername(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Update Name", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Full Name"
            }
            let saveAction = UIAlertAction(title: "Update", style: .default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                guard let name = firstTextField.text else { return }
                self.updateUserName(name)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in })
    
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(_ sender:UIButton){
        showActionSheet()
    }
    
    
    func updateUserName(_ name:String){
        let dict = ["fullName":name]
        let email = Auth.auth().currentUser?.email ?? ""
        IFirebaseDatabase.shared.updateData("users", document: email, data: dict).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { [unowned self](_) in
            self.fetchUser()
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    
    private func fetchUser(){
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
                self.userName.text = snapshot.data()?["fullName"] as? String
                self.email.text = id
                if let userImageUrl = snapshot.data()?["profileImage"] as? String{
                    let imageUrl = URL(string: userImageUrl)!
                    let imageData:NSData = NSData(contentsOf: imageUrl)!
                    self.userImage.image = UIImage(data: imageData as Data)
                }
                
            } else {
                print("user does not exist")
            }
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    //MARK:- Camera and Gallery
    
    func showActionSheet(){
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: NSLocalizedString("Upload Image", comment: ""), message: nil, preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor.black
        let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default)
        { action -> Void in
            self.camera()
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose From Gallery", comment: ""), style: .default)
        { action -> Void in
            self.gallery()
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func camera()
    {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func gallery()
    {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func save(_ sender:UIButton){
        
        guard let imageData = userImage!.image?.jpegData(compressionQuality: 0.8) else {
            
            dismiss(animated: true, completion: nil)
            return }
        IFirebaseStorage.shared.uploadImage(imageData).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { (url) in
            let dict = ["profileImage":url]
            let email = Auth.auth().currentUser?.email ?? ""
            IFirebaseDatabase.shared.updateData("users", document: email, data: dict).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { (_) in
                print("image uploaded and save in users")
            }.store(in: &IFirebaseDatabase.shared.cancelBag)
            
        }).store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        IFirebase.shared.signOut().sink(receiveCompletion: { (completion) in
            switch completion{
            case .finished: print("fnished")
            case .failure(let error) : print(error.localizedDescription)
            }
        }) { (_) in
            print("Sign out pressed")

            DispatchQueue.main.async {
                // Go back to homescreen
                let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vc = st.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
            }
            
            
        }.store(in: &IFirebase.shared.cancelBag)
    }
    
}


extension ProfileSettingsViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        userImage.image = image
        dismiss(animated: true, completion: nil)
    }
}
extension ProfileSettingsViewController{
    
    
    
}
