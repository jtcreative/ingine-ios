//
//  DemoAccountViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 03/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth
class DemoAccountViewController: UIViewController {
    
    
    @IBOutlet weak var userImage:UIImageView!
    

    var imagePicker:UIImagePickerController?
    var firebaseManager:FirebaseManager?
    var userImageStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        firebaseManager = FirebaseManager(nil, databaseDelegate: self, storageDelegate: self)

        
        let imageUrl = URL(string: userImageStr)!
               let imageData:NSData = NSData(contentsOf: imageUrl)!
               userImage.image = UIImage(data: imageData as Data)
       
    }
    
    @IBAction func choosePhoto(_ sender:UIButton){
        imagePicker?.allowsEditing = true
        imagePicker?.sourceType = .photoLibrary
        present(imagePicker!, animated: true, completion: nil)
        guard let imageData = userImage!.image?.jpegData(compressionQuality: 0.8) else { return }
        firebaseManager?.uploadImage(imageData, type: .image)
    }
    
    
    @IBAction func upload(_ sender:UIButton){
   
           guard let imageData = userImage!.image?.jpegData(compressionQuality: 0.8) else { return }
           firebaseManager?.uploadImage(imageData, type: .image)
       }
       

   

}
extension DemoAccountViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        userImage.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension DemoAccountViewController:FirebaseStorageDelegate{
    func media(_ url: String?, isSuccess: Bool, type: FirebaseStorageType) {
        if isSuccess{
            let dict = ["profileImage":url]
            let email = Auth.auth().currentUser?.email ?? ""
            firebaseManager?.updateData(dict: dict as [String : Any], collectionName: "users", documentName: email)
        }
        
    }
    
}
extension DemoAccountViewController:FirebaseDatabaseDelegate{
    func databaseUpdate(_ isSuccess: Bool) {
        if isSuccess{
            dismiss(animated: true, completion: nil)
        }
    }
}
