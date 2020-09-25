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
    @IBOutlet weak var userImage:UIImageView!
    
    var userImageStr = ""
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if !userImageStr.isEmpty{
            let imageUrl = URL(string: userImageStr)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            userImage.image = UIImage(data: imageData as Data)
        }
        
    }
    
    @IBAction func choosePhoto(_ sender:UIButton){
        showActionSheet()
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
        
        guard let imageData = userImage!.image?.jpegData(compressionQuality: 0.8) else { return }
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
            let home = HomeViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = home
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
