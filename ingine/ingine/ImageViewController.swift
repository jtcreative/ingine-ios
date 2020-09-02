//
//  ImageViewController.swift
//  ingine
//
//  Created by McNels on 4/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: PortraitViewController, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    var image : UIImage?
    lazy var storage = Storage.storage()
    var storageURL : String = ""
    var firebaseManager: FirebaseManager?
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        firebaseManager = FirebaseManager(nil, databaseDelegate: self, storageDelegate: self)
        imageView.image = image
        db = Firestore.firestore()
        
        self.urlBox.delegate = self
        
        // Observers to hide keyboard once return key pressed
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

       
        guard let imageData = image!.jpegData(compressionQuality: 0.8) else { return }
        firebaseManager?.uploadImage(imageData, type: .image)

    }
}
