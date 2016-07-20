//
//  CameraAndLocationViewController.swift
//  JustInCase
//
//  Created by admin on 6/3/16.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseStorage
import FirebaseAuth

class CameraAndLocationViewController : UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var driver : Driver? = nil
    var address : String? = "Unknown"
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    let locationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
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
    
    private func hideViewElements() {
        
        self.cameraButton.enabled = false
        self.cameraButton.hidden = true
        
        self.locationButton.enabled = false
        self.locationButton.hidden = true
        
        self.mapView.hidden = true
        self.photoImageView.hidden = true
    }
    
    private func showViewElements() {
        
        self.cameraButton.enabled = true
        self.cameraButton.hidden = false
        
        self.locationButton.enabled = true
        self.locationButton.hidden = false
        
        self.mapView.hidden = false
        self.photoImageView.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--- Find Address of Current Location ---//
    @IBAction func findMyLocation(sender: AnyObject)
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        /*let location = self.locationManager.location
        
        let latitude: Double = location!.coordinate.latitude
        let longitude: Double = location!.coordinate.longitude
        
        print("current latitude :: \(latitude)")
        print("current longitude :: \(longitude)")
        */
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil)
            {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0
            {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            }
            else
            {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //--- CLGeocode to get address of current location ---//
            CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
                
                if (error != nil)
                {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0
                {
                    let pm = placemarks![0] as CLPlacemark
                    self.displayLocationInfo(pm)
                }
                else
                {
                    print("Problem with the data received from geocoder")
                }
            })
    }
    
    
    func displayLocationInfo(placemarks: CLPlacemark?)
    {
        if let placeMark = placemarks
        {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let geoCoder = CLGeocoder()
            let location = placeMark.location
            
            geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) -> Void in
                
                if(error != nil) {
                    self.showErrorAlert((error?.localizedDescription)!)
                }
                else {
                    
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    // Address dictionary
                    print(placeMark.addressDictionary)
                    
                    // Location name
                    let locationName = placeMark.addressDictionary?["Name"] as? NSString
                
                    // Street address
                    let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
                    
                    // City
                    let city = placeMark.addressDictionary?["City"] as? NSString
                
                    // Zip code
                    let zip = placeMark.addressDictionary?["ZIP"] as? NSString
                    
                    // Country
                    let country = placeMark.addressDictionary?["Country"] as? NSString
                    
                    self.address = "\(locationName), \(street), \(city), \(country), \(zip)"
                
                    //Show the location on the map
                
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: (location?.coordinate)!, span: span)
                    self.mapView.setRegion(region, animated: true)
                
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = (location?.coordinate)!
                    annotation.title = "Accident Location"
                    annotation.subtitle = "\(locationName), \(street), \(city), \(zip), \(country)"
                    self.mapView.addAnnotation(annotation)
                }
                
            }
            
        }
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        
        self.pickFromCamera()
    }
    
    private func pickFromCamera() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    private func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
            animated: true,
            completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        self.photoImageView.image = image
        
    }
    
    
    @IBAction func createReport(sender: UIBarButtonItem) {
        
        if(address == nil) {
            self.showErrorAlert("The address of the accident is needed!")
        }
        
        else {
            let id = getCurrentTimeAndDate()
            hideViewElements()
            showProgressView()
            saveImageToStorage(id)
        }
    }
    
    private func showErrorAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func getCurrentTimeAndDate() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Day , .Month , .Year], fromDate: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        
        return "\(year)\(month)\(day)\(hour)"
    }
    
    private func saveImageToStorage(id : String) {
        
        // Get a reference to current user
        let userId : String = (FIRAuth.auth()?.currentUser?.uid)!
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageReference = storage.referenceForURL("\(Const.storagePath)/\(Const.IMAGES)/\(userId)/\(id).jpg")
        
        // Data in memory
        let data: NSData = NSData(data : UIImageJPEGRepresentation((self.photoImageView?.image)!, 1.0)!)
        // Create the file metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        let uploadTask = storageReference.putData(data, metadata: metadata);
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observeStatus(.Pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observeStatus(.Resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observeStatus(.Progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete = Float(100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount))
                self.updateProgressView(percentComplete)
            }
        }
        
        uploadTask.observeStatus(.Success) { snapshot in
            // Upload completed successfully
            
            let accident = Accident.init(driver: self.driver!, image: self.photoImageView.image!, address: self.address!, id: id)
            accident.saveToFireBase()
            
            let path = self.createPDF(accident)
            self.showPDF(path)
            self.goBackToMainMenu()
            
        }
        
        // Errors only occur in the "Failure" case
        uploadTask.observeStatus(.Failure) { snapshot in
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
                default:
                self.showProgressView()
                self.showErrorAlert("Error occured while uploading")
                break
            }
        }
    }
    
    private func goBackToMainMenu() {
        self.navigationController?.popToRootViewControllerAnimated(true)
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

}