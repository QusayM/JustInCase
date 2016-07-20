//
//  Driver.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Driver {
    
    var firstName, secondName, idNumber, address, phoneNumber : String!
    var vehicle : Vehicle!
    
    init(firstName : String, secondName : String, idNumber : String, address : String, phoneNumber : String, vehicle : Vehicle) {
        self.firstName = firstName
        self.secondName = secondName
        self.idNumber = idNumber
        self.address = address
        self.phoneNumber = phoneNumber
        self.vehicle = vehicle;
    }
    
    func saveToFireBase(driverReference : FIRDatabaseReference) {
        
        let user = FIRAuth.auth()?.currentUser
        
        let driver : NSDictionary = [
            "userName" : (user?.email!)!,
            "firstName": self.firstName,
            "secondName": self.secondName,
            "idNumber": self.idNumber,
            "address": self.address,
            "phoneNumber" : self.phoneNumber]
        
        driverReference.setValue(driver)
        self.vehicle.saveToFireBase(driverReference)
    }
}