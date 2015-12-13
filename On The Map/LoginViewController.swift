//
//  ViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 11/29/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }


    @IBAction func loginButtonTapped(sender: UIButton) {
        if emailTextField.text!.isEmpty {
            Alert(self, title: "Alert", message: "Email cannot be empty!")
        } else if passwordTextField.text!.isEmpty {
            Alert(self, title: "Alert", message: "Password cannot be empty!")
        } else {
            OTMClient.sharedInstance().loginUdacity(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let errorString = errorString {
                            Alert(self, title: "Alert", message: errorString)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }

    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func configureUI() {
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.99, green: 0.592, blue: 0.164, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.988, green: 0.458, blue: 0.133, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        self.loginTextLabel.textColor = UIColor.whiteColor()
        
        self.loginButton.backgroundColor = UIColor(red: 0.945, green: 0.337, blue: 0.113, alpha: 1.0)
        
        self.emailTextField.backgroundColor = UIColor(red: 0.996, green: 0.776, blue: 0.592, alpha: 1.0)
        self.emailTextField.placeholder = "Email"
        
        self.passwordTextField.backgroundColor = UIColor(red: 0.996, green: 0.776, blue: 0.592, alpha: 1.0)
        self.passwordTextField.placeholder = "Password"
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        configureUI()
    }

}

extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.emailTextField.isFirstResponder() || self.passwordTextField.isFirstResponder()
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}

