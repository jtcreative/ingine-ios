//
//  SignUpViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class SignUpViewController: BaseViewController {
    
    //MARK: Outlets
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var conditionTermsTextView: UITextView!
    @IBOutlet weak var markTermsButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var arImageView: UIView!
    @IBOutlet weak var arImage: UIImageView!
    
    @IBOutlet weak var userProfile: UIImageView!
    //MARK: Properties
    
    let termsAndConditionsURL = "https://ingine.io/terms-conditions.html";
    let privacyURL            = "https://ingine.io/privacy-policy.html";
    var db = Firestore.firestore()
    var sendArData:SendARData?
    let pickerController = UIImagePickerController()
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    // setup the UI
    private func setupUI(){
        //give radius to buttons
        createAccountButton.setRadius(8)
        cancelButton.setRadius(8)
        profileView.setRadius(profileView.frame.height / 2)
        arImageView.setRadius(12)
        firstTextField.backgroundColor = .white
        emailTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
        confirmPasswordTextField.backgroundColor = .white
        
        // align textfield placeholder
        emailTextField.attributedPlaceholder = "Email".toArributedString(alignment: .center)
        passwordTextField.attributedPlaceholder = "Password".toArributedString(alignment: .center)
        firstTextField.attributedPlaceholder = "Fullname".toArributedString(alignment: .center)
        confirmPasswordTextField.attributedPlaceholder = "Confirm Password".toArributedString(alignment: .center)
        
        // set gradient
        view.setGradientBackground()
        
        // set hyperlink
        let str = conditionTermsTextView.text ?? ""
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)];
               
        let attributedString = NSMutableAttributedString(string: str, attributes: attributedStringColor)
        var foundRange = attributedString.mutableString.range(of: "Terms of Service") //mention the parts of the attributed text you want to tap and get an custom action
        attributedString.addAttribute(NSAttributedString.Key.link, value: termsAndConditionsURL, range: foundRange)
        foundRange = attributedString.mutableString.range(of: "Privacy Policy")
        attributedString.addAttribute(NSAttributedString.Key.link, value: privacyURL, range: foundRange)
    
        
        pickerController.delegate = self
        
        conditionTermsTextView.attributedText = attributedString
        
        // congifure data
        if let main = self.parent as? MainViewController{
            if let value = main.data as? SendARData{
                self.sendArData = value
                arImage.image = value.image
            }
        }
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
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)

        }

        func gallery()
        {
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)

        }
    
    // check vaildation

    private func formValidation() -> Validation{
        
        // check if details are not empty
        guard let email = emailTextField.text,
              let username = firstTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            
            return .invaild("Form is not valid!")
        }
        
        if email.isEmpty, password.isEmpty, username.isEmpty  {
            return .invaild("Please fill in all fields!")
        }
        // check if password doesn't match
        if password != confirmPassword{
            return .invaild("Password doesn't match")
        }
        
        
        return .vaild
    }

    
    func handleRegister() {
        
        switch formValidation() {
        case .vaild:
            // Register new user
            signUp(emailTextField.text!, password: passwordTextField.text!)
        case .invaild(let error):
        self.displayAlert(title: "Invalid Form", message: error)
        }
    }
    
   
    
    // move to main page
    func openMainViewController() {
           DispatchQueue.main.async {
               // log user in, and show home screen
               // Go back to homescreen
               let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
               let vc = st.instantiateInitialViewController()
               (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
           }
       }
    //MARK:Actions
    @IBAction func createAccount(_ sender: UIButton) {
        
        // check if user check the terms and conditions
        
        if !markTermsButton.isSelected{
            displayAlert(title: "Alert", message: "Please accept the terms and conditions.")
        }
        
        handleRegister()
    }
    
    @IBAction func chooseProfileImage(_ sender: UIButton) {
        showActionSheet()
    }
    
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {

            mainViewController.backPage()
     }
    }
    
    @IBAction func markTerms(_ sender: UIButton) {
        markTermsButton.isSelected.toggle()
    }
}





//MARK: Text View Delegate Methods
extension SignUpViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
           UIApplication.shared.open(URL)
           return false
       }
}

//MARK: Text Field Delegate Methods

extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if emailTextField.text == "" || passwordTextField.text == "" || firstTextField.text == "" || confirmPasswordTextField.text == ""{
            // if all fields are empty
            createAccountButton.isEnabled = false
            createAccountButton.alpha = 0.4
        }else{
            // if all fields are filled
            createAccountButton.isEnabled = true
            createAccountButton.alpha = 1
        }
        return true
    }
    
}


extension SignUpViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        userProfile.image = image
        dismiss(animated: true, completion: nil)
    }
}
