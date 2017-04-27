//
//  ManagerAPI.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 24.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import UIKit
import SwiftValidator
import RealmSwift

let feedVideosStoryboardIdentifier = "FeedVideos"

class LoginViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    
    let validator = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard)))
        
        if VideoDataService.isUserLoggedIn() {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: feedVideosStoryboardIdentifier)
            self.navigationController?.pushViewController(nextViewController!, animated: false)
        }
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.darkGray.cgColor
                textField.layer.borderWidth = 0
                
            }
            }, error:{ (validationError) -> Void in
                print(validationError.errorMessage)
                validationError.errorLabel?.isHidden = false
                validationError.errorLabel?.text = validationError.errorMessage
                if let textField = validationError.field as? UITextField {
                    textField.layer.borderColor = UIColor.blue.cgColor
                    textField.layer.borderWidth = 1.0
                }
        })

        validator.registerField(usernameTextField, errorLabel: usernameErrorLabel, rules: [RequiredRule(), MinLengthRule(length: 3), MaxLengthRule(length: 32)])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(), PasswordRule()])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        usernameTextField.text = ""
        passwordTextField.text = ""
        navigationController?.toolbar.isHidden = false
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        validator.validate(self)
    }
    
    //MARK: ValidationDelegate methods
    
    func validationSuccessful() {
        
        VideoDataService.loginUser(with: usernameTextField.text!, password: passwordTextField.text!) { (error, user) in
            if user != nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: feedVideosStoryboardIdentifier, sender: self)
                }
            } else {
                let alert = UIAlertController.init(title: "LogIn Error!!!", message: "Try Again Please!!!", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        print("Failed!!!")
    }
    
    //MARK: UITextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateSeparateTextField(textField, performLogin: true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validateSeparateTextField(textField, performLogin: false)
    }
    
    func validateSeparateTextField(_ textField: UITextField, performLogin: Bool) {
        if textField == usernameTextField {
            validator.validateField(textField){ error in
                if error == nil {
                    passwordTextField.becomeFirstResponder()
                }
            }
        } else {
            validator.validateField(textField){ error in
                if error == nil {
                    if performLogin {
                        loginPressed(self)
                    } else {
                        textField.resignFirstResponder()
                    }
                }
            }
            
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}
