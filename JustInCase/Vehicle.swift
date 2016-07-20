//
//  Vehicle.swift
//  JustInCase
//
//  Created by Qusay Muzaffar on 02/06/2016.
//  Copyright © 2016 Qusay Muzaffar. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Vehicle {
    
    var registrationNumber, insuranceCompany, insuranceNumber: String
    
    init(registrationNumber: String, insuranceCompany: String, insuranceNumber: String) {
        self.registrationNumber = registrationNumber
        self.insuranceCompany = insuranceCompany
        self.insuranceNumber  = insuranceNumber
    }
    
    func saveToFireBase(driverReference : FIRDatabaseReference) {
        
        let vehicle : NSDictionary = [
            "registrationNumber": self.registrationNumber,
            "insuranceCompany": self.insuranceCompany,
            "insuranceNumber": self.insuranceNumber]
        
        let vehicleReference = driverReference.child(Const.VEHICLE)
        vehicleReference.setValue(vehicle)
        
    }
    
}