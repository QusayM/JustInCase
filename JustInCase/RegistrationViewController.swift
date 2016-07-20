//
//  RegistrationViewController.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistrationViewController : UIViewController ,UITextFieldDelegate{
    
    //Profile
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerificationTextField: UITextField!
    
    //Driver
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var SecondNameTextField: UITextField!
    @IBOutlet weak var IDNumberTextField: UITextField!
    @IBOutlet weak var AddressTextField: UITextField!
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    
    //Vehicle
    @IBOutlet weak var RegistrationNumberTextField: UITextField!
    @IBOutlet weak var InsuranceCompanyTextField: UITextField!
    @IBOutlet weak var InsuranceNumberTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Database reference
    let reference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activityIndicator.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    @IBAction func registration(sender: UIButton) {
        
        let userName = userNameTextField.text
        let password = passwordTextField.text
        let passwordVerification = passwordVerificationTextField.text
        let firstName = FirstNameTextField.text
        let secondName = SecondNameTextField.text
        let idNumber = IDNumberTextField.text
        let address = AddressTextField.text
        let phoneNumber = PhoneNumberTextField.text
        let registrationNumber = RegistrationNumberTextField.text
        let insuranceCompany = InsuranceCompanyTextField.text
        let insuranceNumber = InsuranceNumberTextField.text
        
        
        if(!(userName!.isEmpty) && !(password!.isEmpty) && !(passwordVerification!.isEmpty) && !(firstName!.isEmpty) && !(secondName!.isEmpty) && !(idNumber!.isEmpty)
            && !(address!.isEmpty) && !(phoneNumber!.isEmpty) && !(registrationNumber!.isEmpty) && !(insuranceCompany!.isEmpty) && !(insuranceNumber!.isEmpty)) {
            
            if(password == passwordVerification) {
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
            
                FIRAuth.auth()?.createUserWithEmail(userName!, password: password!) { (user, error) in
                
                    //Check if registration has succeeded
                    if(error != nil) {
                        self.showErrorAlert((error?.localizedDescription)!)
                    }
                    else {
                    
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        let vehicle = Vehicle.init(registrationNumber: registrationNumber!, insuranceCompany: insuranceCompany!, insuranceNumber: insuranceNumber!)
                        let driver = Driver.init(firstName: firstName!, secondName: secondName!, idNumber: idNumber!, address: address!, phoneNumber: phoneNumber!, vehicle: vehicle)
                        
                        let driverpath : String = "\(Const.DRIVER)/\((user?.uid)!)"
                        let driverReference = self.reference.child(driverpath as String)
                        driver.saveToFireBase(driverReference)
                        self.moveToMainScreen()
                    }
                    
                }
            }
            else {
                showErrorAlert("Please check password verification")
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

    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}