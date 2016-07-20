//
//  Accident.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 20/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

class Accident {
    
    var driver : Driver!
    var image : UIImage
    var address : String!
    var id : String!
    
    init(driver : Driver, image: UIImage, address: String, id : String) {
        self.driver = driver
        self.image = image
        self.address = address
        self.id = id
    }
    
    func saveToFireBase() {
        
        //Database reference
        let reference : FIRDatabaseReference = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        let path : String = "\(Const.DRIVER)/\((user?.uid)!)/\(Const.ACCIDENTS)/\(self.id)"
        let accidentReference = reference.child(path as String)
        
        let accident : NSDictionary = ["address" : self.address]
        accidentReference.setValue(accident)
        
        let driverpath : String = "\(Const.DRIVER)"
        let driverReference = accidentReference.child(driverpath as String)
		
		let driver : NSDictionary = [
            "firstName": self.driver.firstName,
            "secondName": self.driver.secondName,
            "idNumber": self.driver.idNumber,
            "address": self.driver.address,
            "phoneNumber" : self.driver.phoneNumber]
		
		driverReference.setValue(driver)
        self.driver.vehicle.saveToFireBase(driverReference)
        
    }
}