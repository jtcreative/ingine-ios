//
//  LoginViewController.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class LoginViewController: BaseViewController {

    //MARK: Outlets
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var arImageView: UIView!
    @IBOutlet weak var arImage: UIImageView!
    
    //MARK: Properties
    var arData:SendARData?
    var db = Firestore.firestore()
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           isLoggedIn()
       }
    
    // setup the UI
    private func setupUI(){
        // give radius to buttons
        loginButton.setRadius(8)
        cancelButton.setRadius(8)
        arImageView.setRadius(12)
        // align textfield placeholder
        emailTextField.attributedPlaceholder = "Email".toArributedString(alignment: .center)
        passwordTextField.attributedPlaceholder = "Password".toArributedString(alignment: .center)
        
        emailTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
        
        
        // set gradient
        view.setGradientBackground()
        
        
        if let value = arData{
            arImage.image = value.image
        }
    }
    
    // Check if user is logged in
    func isLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            self.openMainViewController()
        }
    }
   
    
   
    
    // handle Login
    func handleLogin() {
        guard let email = emailTextField.text?.lowercased(), let password = passwordTextField.text else {
            print("Form is not valid!")
            return
        }
        if email.isEmpty || password.isEmpty {
            return
        }
        // Sign in with firebase
        
        login(email, password:password)
    }
    
  
    func openMainViewController() {
         DispatchQueue.main.async {
             // log user in, and show home screen
             // Go back to homescreen
             let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
             let vc = st.instantiateViewController(identifier: "MainViewController")
             (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
         }
     }
    
    //MARK: Actions
    
    @IBAction func loginButton(_ sender: UIButton) {
        handleLogin()
    }
    @IBAction func cancel(_ sender: UIButton) {
     dismiss(animated: true, completion: nil)
    }
    
}


//MARK: Text Field Delegate Methods

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            // if email and password are empty
            loginButton.isEnabled = false
            loginButton.alpha = 0.4
        }else{
            // if email and password are filled
            loginButton.isEnabled = true
            loginButton.alpha = 1
        }
        return true
    }
    
}



