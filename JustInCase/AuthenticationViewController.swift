//
//  AuthenticationViewController.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthenticationViewController : UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        if (FIRAuth.auth()?.currentUser) != nil {
            // User is signed in.
            self.moveToMainScreen()
        }

    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.CGRectValue()
        let keyboardSize = keyboardFrame.size
        
        UIView.animateWithDuration(0.5) {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.5) {
            self.view.frame.origin.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        
        let username = userNameTextField.text
        let password = passwordTextField.text
        
        if(!(username!.isEmpty) && !(password!.isEmpty)) {
        
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        
            
            FIRAuth.auth()?.signInWithEmail(username!, password: password!) { (user, error) in
               
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                 // check if login succeeded
                if(error != nil) {
                    self.showErrorAlert((error?.localizedDescription)!)
                    
                }
                else {
                    self.moveToMainScreen()

                }
            
            }
        }
        
        else {
            self.showErrorAlert("One or more of the text fields are empty")
        }
    }
    
    private func moveToMainScreen() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("MainScreenViewController") as! UITabBarController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    private func showErrorAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        return true
    }
    
}