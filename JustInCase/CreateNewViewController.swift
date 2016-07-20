//
//  CreateNewViewController.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateNewViewController : UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var UserNameTextField: UITextField!
    @IBOutlet weak var UserIDTextField: UITextField!
    
    @IBOutlet weak var CheckDriverButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    
    var driver : Driver? = nil
    //Database reference
    let reference : FIRDatabaseReference = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkDriverInformations(sender: UIButton) {
        
        self.CheckDriverButton.enabled = false
        self.CheckDriverButton.hidden = true
        
        self.Indicator.hidden = false
        self.Indicator.startAnimating()
        
        let userName = UserNameTextField.text
        let userID = UserIDTextField.text
        
        if(!(userName?.isEmpty)! && !(userID?.isEmpty)!) {
            
            let path : String = "\(Const.DRIVER)/\((userID)!)"
            let driverReference = reference.child(path as String)
            
            driverReference.observeEventType(.Value, withBlock: { (snapshot) in
                // Get driver values
                let retrievedUserName = snapshot.value!["userName"] as! String
                if ((userName?.compare(retrievedUserName)) != nil) {
                    
                    guard let firstName = snapshot.value?["firstName"] as? String,
                        let secondName = snapshot.value?["secondName"] as? String,
                        let idNumber = snapshot.value?["idNumber"] as? String,
                        let address = snapshot.value?["address"] as? String,
                        let phoneNumber = snapshot.value?["phoneNumber"] as? String else { return }
                    
                    driverReference.child(Const.VEHICLE).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        // Get vehicle values
                        guard let registrationNumber = snapshot.value?["registrationNumber"] as? String,
                        let insuranceCompany = snapshot.value?["insuranceCompany"] as? String,
                            let insuranceNumber = snapshot.value?["insuranceNumber"] as? String else {return}
                        let vehicle = Vehicle.init(registrationNumber: registrationNumber, insuranceCompany: insuranceCompany, insuranceNumber: insuranceNumber)
                        self.driver = Driver.init(firstName: firstName, secondName: secondName, idNumber: idNumber, address: address, phoneNumber: phoneNumber, vehicle: vehicle)
                        
                        self.CheckDriverButton.enabled = false
                        self.CheckDriverButton.hidden = true
                        
                        self.Indicator.stopAnimating()
                        
                        self.NextButton.hidden = false
                        self.NextButton.enabled = true
                        
                        
                    }) { (error) in
                        self.showErrorAlert(error.localizedDescription)
                    }
                }
                    
                else {
                    self.showErrorAlert("The username and the user id doesn't match")
                }
                
            }) { (error) in
                self.showErrorAlert(error.localizedDescription)
                
            }
        }
            
        else {
            self.showErrorAlert("One or more of the text fields are empty")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowCameraAndLocationViewController"{
                        let nextViewController = segue.destinationViewController as! CameraAndLocationViewController
            nextViewController.driver = self.driver
        }
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
