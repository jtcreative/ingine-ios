//
//  ImageViewController.swift
//  ingine
//
//  Created by McNels on 4/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ImageViewController: PortraitViewController, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    var image : UIImage?
    var db = Firestore.firestore()
    var storageURL : String = ""
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
      
        imageView.image = image
       
        
        self.urlBox.delegate = self
        
        // Observers to hide keyboard once return key pressed
        NotificatonBinding.shared.registerPublisher(name: .sendArData, type: SendARData.self)
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
  
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {

        // check if user already login or not
        if Auth.auth().currentUser?.uid != nil {
            // if user login then upload A//////////////R image asset
            guard let imageData = image!.jpegData(compressionQuality: 0.8) else { return }
            uploadArImage(imageData)
        }else{
            
            // if user not login then send to user home vc
           
            let arData = SendARData(image: image, url: urlBox.text, name: nameBox.text, visibilty: visibilitySwitch.isOn)
            guard let homeVc = storyboard?.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
                return
            }
            homeVc.modalTransitionStyle = .coverVertical
            homeVc.modalPresentationStyle = .overFullScreen
            homeVc.arData = arData
            present(homeVc, animated: true, completion: nil)


            
        }
       
       

    }
}
