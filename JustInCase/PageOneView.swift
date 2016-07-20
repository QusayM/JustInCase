/*
* The MIT License (MIT)
*
* Copyright (c) 2016 cr0ss
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation
import UIKit

class PageOneView: UIView {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var idNumberLabel: UILabel!
    @IBOutlet weak var livingAddressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var registrationNumberLabel: UILabel!
    @IBOutlet weak var insuranceCompanyLabel: UILabel!
    @IBOutlet weak var insuranceNumberLabel: UILabel!
    
    @IBOutlet weak var accidentAddressLabel: UILabel!
    @IBOutlet weak var accidentPictureImageView: UIImageView!
    
    var accidentObj : Accident? = nil
    
    internal func setupViewContent() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let fullName : String = "\(accidentObj!.driver.firstName) \(accidentObj!.driver.secondName)"
        
        fullNameLabel.text = fullName 
        idNumberLabel.text = accidentObj?.driver.idNumber
        livingAddressLabel.text = accidentObj?.driver.address
        phoneNumberLabel.text = accidentObj?.driver.phoneNumber
        
        registrationNumberLabel.text = accidentObj?.driver.vehicle.registrationNumber
        insuranceCompanyLabel.text = accidentObj?.driver.vehicle.insuranceCompany
        insuranceNumberLabel.text = accidentObj?.driver.vehicle.insuranceNumber
        
        accidentAddressLabel.text = accidentObj!.address
        accidentPictureImageView.image = accidentObj!.image
    }
}