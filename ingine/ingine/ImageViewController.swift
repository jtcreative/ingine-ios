//
//  ImageViewController.swift
//  ARKitImageRecognition
//
//  Created by Armen Nikoghosyan on 4/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlBox: UITextField!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    var image : UIImage?
    lazy var storage = Storage.storage()
    var storageURL : String = ""
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        // Upload image
//        let imageData = UIImageJPEGRepresentation(image!, 0.8)
        let imageData = image!.jpegData(compressionQuality: 0.8)
        
//        let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let imagePath = "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //Upload and save content to appropriate user
        if Auth.auth().currentUser?.uid != nil {
            // User is logged in
            let storageRef = self.storage.reference(withPath: imagePath)
            storageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
                print("no error")
                // Get download url from firestore storage
                storageRef.downloadURL { (url, error) in
                    self.storageURL = (url?.absoluteString)!
                    print(self.storageURL)
                    var matchURL = ""
                    let email = Auth.auth().currentUser?.email ?? ""
                    if self.urlBox.text?.hasPrefix("https://") ?? false || self.urlBox.text?.hasPrefix("http://") ?? false {
                        matchURL = self.urlBox.text ?? ""
                    }else {
                        matchURL = "http://\(self.urlBox.text ?? "")"
                    }
                    
                    // Save ingineered item in firebase pairs folder
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("pairs").addDocument(data: [
                        "name": "\(Int(Date.timeIntervalSinceReferenceDate * 1000))",
                        "refImage": self.storageURL,
                        "matchURL": matchURL,
                        "user": email,
                        "public": self.visibilitySwitch.isOn
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID!")
                        }
                    }
                    
                    // Save a reference in users folder
                    let documentRefString = self.db.collection("pairs").document(ref?.documentID ?? "")
                    let userRefKey = ref?.documentID

                    self.db.collection("users").document(email).updateData([
                        userRefKey ?? "" : self.db.document(documentRefString.path)
                    ]) { err in
                        if let err = err {
                            print("Error getting reference to document: \(err)")
                        } else {
                            print("Reference successfully written!")
                        }
                    }

                }
                
            }
            
            
        } else {
            // User is not logged in // This point should never be reached at runtime // alert user
            print("not logged in at matching screen")

        }
       
        let vc = st.instantiateInitialViewController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
    }
}
