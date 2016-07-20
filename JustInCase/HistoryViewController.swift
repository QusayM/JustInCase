//
//  HistoryViewController.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HistoryViewController : UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var accidentsArray = [Accident]()
    
    //Database reference
    let reference : FIRDatabaseReference = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.showErrorAlert("This feature is not available yet!")
    }
    
    private func loadDataFromFireBase() {
        
        //Database reference
        let user = FIRAuth.auth()?.currentUser
        let path : String = "\(Const.DRIVER)/\((user?.uid)!)/\(Const.ACCIDENTS)"
        let accidentReference = reference.child(path)
        
        accidentReference.ref.observeEventType(.Value, withBlock: { (snapshot) in
            
            let enumerator = snapshot.children
            while let child: AnyObject = enumerator.nextObject() {
                let id : String = child.key
                let address = child.value["address"] as! String
                print(address)
                
                let path : String = "\(Const.DRIVER)"
                let driverReference = accidentReference.child(path)
                
                driverReference.ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    // Get driver values
                    guard let firstName = snapshot.value?["firstName"] as? String,
                        let secondName = snapshot.value?["secondName"] as? String,
                        let idNumber = snapshot.value?["idNumber"] as? String,
                        let address = snapshot.value?["address"] as? String,
                        let phoneNumber = snapshot.value?["phoneNumber"] as? String else { return }
                    print(snapshot.value)
                    
                    driverReference.child(Const.VEHICLE).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        // Get vehicle values
                        let registrationNumber = snapshot.value!["registrationNumber"] as! String
                        let insuranceCompany = snapshot.value!["insuranceCompany"] as! String
                        let insuranceNumber = snapshot.value!["insuranceNumber"] as! String
                        
                        let vehicle = Vehicle.init(registrationNumber: registrationNumber, insuranceCompany: insuranceCompany, insuranceNumber: insuranceNumber)
                        let driver = Driver.init(firstName: firstName, secondName: secondName, idNumber: idNumber, address: address, phoneNumber: phoneNumber, vehicle: vehicle)
                        let accident = Accident.init(driver: driver, image: UIImage(named: "Crash.png")!, address: address, id: id)
                        self.accidentsArray.append(accident)
                        
                    }) { (error) in
                        self.showErrorAlert(error.localizedDescription)
                    }
                    
                    // ...
                }) { (error) in
                    self.showErrorAlert(error.localizedDescription)
                    
                }
                
                
            }
            self.indicator.stopAnimating()
            })
        { (error) in
            self.showErrorAlert(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accidentsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath)
        let index = indexPath.row
        let accident = self.accidentsArray[index];
        let name : String = "\(accident.driver.firstName) \(accident.driver.secondName)"
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = accident.address
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let accident = self.accidentsArray[index]
        self.downloadImageToStorage(accident)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func showProgressView() {
        self.progressView.hidden = false
    }
    
    private func hideProgressView() {
        self.progressView.hidden = true
    }
    
    private func updateProgressView(value : Float) {
        self.progressView.progress = value
    }
    
    private func createPDF() -> String{
        var pages:Array<UIView> = []
        
        // Load Views with NibName
        let pageOneView = NSBundle.mainBundle().loadNibNamed("PageOneView", owner: self, options: nil).last as! PageOneView
        
        pageOneView.setupViewContent()
        
        // Generate PDF from pages Array
        pages.appendContentsOf([pageOneView])
        let tempFilePath = SwiftPDFGenerator.generatePDFWithPages(pages)
        
        return tempFilePath
    }
    
    private func createPDF(accident : Accident) -> String{
        var pages:Array<UIView> = []
        
        // Load Views with NibName
        let pageOneView = NSBundle.mainBundle().loadNibNamed("PageOneView", owner: self, options: nil).last as! PageOneView
        
        pageOneView.accidentObj = accident
        pageOneView.setupViewContent()
        
        // Generate PDF from pages Array
        pages.appendContentsOf([pageOneView])
        let tempFilePath = SwiftPDFGenerator.generatePDFWithPages(pages)
        
        return tempFilePath
    }
    
    private func showPDF(tempFilePath : String) {
        // present PDF
        let newEventController = self.storyboard!.instantiateViewControllerWithIdentifier("PDFNavigationController") as! UINavigationController
        newEventController.modalPresentationStyle = .PageSheet
        let pdfLoc = NSURL(fileURLWithPath: tempFilePath)
        (newEventController.childViewControllers[0] as! DisplayController).url = pdfLoc
        self.presentViewController(newEventController, animated: true, completion: nil)
    }

    
    private func downloadImageToStorage(accident : Accident!) {
        
        // Get a reference to current user
        let user = FIRAuth.auth()?.currentUser
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageReference = storage.referenceForURL("\(Const.storagePath)/\(Const.IMAGES)/\(user?.uid)/\(accident.id).jpg")
        // Create local filesystem URL
        let localURL: NSURL! = NSURL(string: "file:///local/images/\(accident.id).jpg")
        
        // Start the download (in this case writing to a file)
        let downloadTask = storageReference.writeToFile(localURL)
        
        // Observe changes in status
        downloadTask.observeStatus(.Resume) { (snapshot) -> Void in
            // Download resumed, also fires when the download starts
        }
        
        downloadTask.observeStatus(.Pause) { (snapshot) -> Void in
            // Download paused
        }
        
        downloadTask.observeStatus(.Progress) { (snapshot) -> Void in
            // Download reported progress
            if let progress = snapshot.progress {
                let percentComplete = Float(100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                self.updateProgressView(percentComplete)
            }
        }
        
        downloadTask.observeStatus(.Success) { (snapshot) -> Void in
            // Download completed successfully
            
            //Retreiving the image from LocalURL
            if let data = NSData(contentsOfURL: localURL) {
                accident.image = UIImage(data: data)!
            }
            
            //Generating the show the report
            let path = self.createPDF(accident)
            self.showPDF(path)
            
        }
        
        // Errors only occur in the "Failure" case
        downloadTask.observeStatus(.Failure) { (snapshot) -> Void in
            guard let storageError = snapshot.error else { return }
            guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
            switch errorCode {
                case .ObjectNotFound: break
                // File doesn't exist
                
                case .Unauthorized: break
                // User doesn't have permission to access file
                
                case .Cancelled: break
                // User canceled the upload
                
                
                case .Unknown: break
                // Unknown error occurred, inspect the server response
                
                default: break
            }
        }
    }
    
    private func showErrorAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
