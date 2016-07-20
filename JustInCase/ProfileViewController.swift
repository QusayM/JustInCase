//
//  ProfileViewController.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController : UIViewController ,UITextFieldDelegate{
    
    //Driver
    
    @IBOutlet weak var UserIDTextField: UITextField!
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
    
    var user = FIRAuth.auth()?.currentUser
    
    //Database reference
    let reference : FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        let path : String = "\(Const.DRIVER)/\((user?.uid)!)"
        let driverReference = reference.child(path as String)
        
        driverReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get driver values
            guard let firstName = snapshot.value?["firstName"] as? String,
                let secondName = snapshot.value?["secondName"] as? String,
                let idNumber = snapshot.value?["idNumber"] as? String,
                let address = snapshot.value?["address"] as? String,
                let phoneNumber = snapshot.value?["phoneNumber"] as? String else { return }
            print(snapshot.value)
            
            driverReference.child(Const.VEHICLE).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                // Get vehicle values
                guard let registrationNumber = snapshot.value?["registrationNumber"] as? String,
                    let insuranceCompany = snapshot.value?["insuranceCompany"] as? String,
                    let insuranceNumber = snapshot.value?["insuranceNumber"] as? String else {return}
                
                self.UserIDTextField.text = self.user?.uid
                self.FirstNameTextField.text = firstName
                self.SecondNameTextField.text = secondName
                self.IDNumberTextField.text = idNumber
                self.AddressTextField.text = address
                self.PhoneNumberTextField.text = phoneNumber
                self.RegistrationNumberTextField.text = registrationNumber
                self.InsuranceCompanyTextField.text = insuranceCompany
                self.InsuranceNumberTextField.text = insuranceNumber
                
            }) { (error) in
                self.showErrorAlert(error.localizedDescription)
            }
            
            // ...
        }) { (error) in
            self.showErrorAlert(error.localizedDescription)
            
        }
        
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
    
    @IBAction func saveChanges(sender: AnyObject) {
        
        let firstName = FirstNameTextField.text
        let secondName = SecondNameTextField.text
        let idNumber = IDNumberTextField.text
        let address = AddressTextField.text
        let phoneNumber = PhoneNumberTextField.text
        let registrationNumber = RegistrationNumberTextField.text
        let insuranceCompany = InsuranceCompanyTextField.text
        let insuranceNumber = InsuranceNumberTextField.text
        
        if(!(firstName!.isEmpty) && !(secondName!.isEmpty) && !(idNumber!.isEmpty)
            && !(address!.isEmpty) && !(phoneNumber!.isEmpty) && !(registrationNumber!.isEmpty) && !(insuranceCompany!.isEmpty) && !(insuranceNumber!.isEmpty)) {
            
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            
            let vehicle = Vehicle.init(registrationNumber: registrationNumber!, insuranceCompany: insuranceCompany!, insuranceNumber: insuranceNumber!)
            let driver = Driver.init(firstName: firstName!, secondName: secondName!, idNumber: idNumber!, address: address!, phoneNumber: phoneNumber!, vehicle: vehicle)
            
            let driverpath : String = "\(Const.DRIVER)/\((user?.uid)!)"
            let driverReference = self.reference.child(driverpath as String)
            driver.saveToFireBase(driverReference)
            
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
            
        }
    }

    
    @IBAction func signOut(sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
            self.moveToAuthenticationScreen()
        }
        catch let error as NSError {
            showErrorAlert(error.localizedDescription)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func moveToAuthenticationScreen() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("AuthenticationViewController") as UIViewController
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