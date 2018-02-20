//
//  GenerateController.swift
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/16/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

import UIKit
import CoreLocation

class GenerateController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var shippingBillNotxt: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var destinationtxt: UITextField!
    @IBOutlet weak var containerNotxt: UITextField!
    @IBOutlet weak var truckNotxt: UITextField!
    @IBOutlet weak var entryByTxt: UITextField!
    
     var latit: String = " "
     var longit: String = " "
     var locat: String = " "
     var eSeal: String = " "
     var timestamp:String = " "
     var area:String = " "
     var dat:String = ""
    
    @IBOutlet weak var saveBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.initDatePicker()
        
        let datee = NSDate.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dat = dateFormatter.string(from: datee as Date)
        
        DispatchQueue.main.async {
            self.locationSet()
        }
        timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .medium)
        
    //    dateTextField.text = timestamp // "Plz Select Date.."//NSDate().description //resignFirstResponder()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Keyboard Hiding...
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GenerateController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
//    // Date Picker....
//    func initDatePicker()  {
//        let datePickerView:UIDatePicker = UIDatePicker()
//        datePickerView.datePickerMode = UIDatePickerMode.date
//        dateTextField.inputView = datePickerView
//        datePickerView.addTarget(self, action: #selector(GenerateController.datePickerValueChanged), for: UIControlEvents.valueChanged)
//    }
//
//    @objc func datePickerValueChanged(sender:UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        //   dateFormatter.dateStyle = .medium
//        //   dateFormatter.timeStyle = .medium
//        dateFormatter.locale = Locale(identifier: "en_IN")
//        dateTextField.text = dateFormatter.string(from: sender.date)
//    }
}

extension GenerateController : UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        
//        return 3
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
//        switch (section) {
//        case 0:
//            return 3
//            break
//        case 1:
//            return 4
//            break
//        default:
//            return 4
//            break
//        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//    }
    
    func makeTextFeild(_ text:String,_ placeholder:String ) -> UITextField {
        
        let tf:UITextField = UITextField.init(frame: CGRect.init(x: 110, y: 10, width: 185, height: 30))
        tf.placeholder = placeholder
        tf.text = text
        tf.returnKeyType = .next
        tf.delegate = self as? UITextFieldDelegate
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.adjustsFontSizeToFitWidth = true
        tf.textColor =  UIColor.init(red: 0.56, green: 0.84, blue: 1.35, alpha: 1.0)
        tf.addTarget(self, action: #selector(textFeildFinished(_:)), for:.editingDidEndOnExit)
        return tf
    }
    
//    func textFieldDidEndEditing() -> UITextField {
//
//    }
    
    func dissmiss() {
        self.view.endEditing(true)
    }
    
     @IBAction func textFeildFinished(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = (tableView .dequeueReusableCell(withIdentifier: "AttributeCellID"))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .value2, reuseIdentifier: "AttributeCellID")
            cell?.selectionStyle = .none
        }
        
        if (indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = NSLocalizedString("Entry By :",  comment: "S")
                cell?.detailTextLabel?.text = entryByTxt.text
                break;
            case 1:
                cell?.textLabel?.text = NSLocalizedString("Bill No :",  comment: "I")
                cell?.detailTextLabel?.text = shippingBillNotxt.text
                break;
            default:
                cell?.textLabel?.text = NSLocalizedString("e-Seal No :",  comment: "B")
                cell?.detailTextLabel?.text = "QWERTY987654312345678"
                break;
            }
        } else if (indexPath.section == 1) {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = NSLocalizedString("Dest. Port :",  comment: " ")
                cell?.detailTextLabel?.text = truckNotxt.text
                break;
            case 1:
                cell?.textLabel?.text = NSLocalizedString("Container No. :", comment: ".")
                cell?.detailTextLabel?.text = containerNotxt.text
                break;
            case 2:
                cell?.textLabel?.text = NSLocalizedString("Truck No. :", comment: ".")
                cell?.detailTextLabel?.text = destinationtxt.text
                break;
            default:
                cell?.textLabel?.text = NSLocalizedString("Date :", comment: "e")
                cell?.detailTextLabel?.text = dateTextField.text
                break;
            }
        } else {
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = NSLocalizedString("Time :", comment: "D")
                cell?.detailTextLabel?.text = timestamp
                break;
            case 1:
                cell?.textLabel?.text = NSLocalizedString("Latitude :", comment: "T")
                cell?.detailTextLabel?.text = latit
                break;
            case 2:
                cell?.textLabel?.text = NSLocalizedString("Longitude :", comment: "T")
                cell?.detailTextLabel?.text = longit
                break;
            default:
                cell?.textLabel?.text = NSLocalizedString("Area :", comment: "E.")
                cell?.detailTextLabel?.text = area
                break;
            }
        }
        return cell!
    }

}

extension GenerateController : UITableViewDelegate {
    
    
}

extension GenerateController : CLLocationManagerDelegate {
    
    func locationSet()  {
         self.showAlertMessage(messageTitle: "Please Wait", withMessage: "Accessing Location...")
        
        locationManager.allowsBackgroundLocationUpdates = false /// for continues update
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Here you can check whether you have allowed the permission or not.
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorized.")
                let latitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
                let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
                let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
                latit = latitude.description
                longit = longitude.description
                // print("Lat : %f  Long : %f",latitude as Any,longitude as Any)
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        return
                    }else if let country = placemarks?.first?.country,
                        let city = placemarks?.first?.locality,
                        let pot = placemarks?.first?.postalCode {
                        print(pot + ",", city + ",",country)
                        self.locat = pot + ", " + city + ", " + country
                   //     self.activityIndicatorView.stopAnimating()
                    //    self.activityIndicatorView.hidesWhenStopped = true
                    }
                    else {
                    }
                })
                break
                
            case .notDetermined:
                print("Not determined.")
                self.showAlertMessage(messageTitle: "Alert !", withMessage: "Location service is disabled!!")
                break
                
            case .restricted:
                print("Restricted.")
                self.showAlertMessage(messageTitle: "Alert !", withMessage: "Location service is disabled!!")
                break
                
            case .denied:
                print("Denied.")
            }
        }
    }
    
    //TODO: - For Location Setting...
    func showAlertMessage(messageTitle: NSString, withMessage: NSString) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction!) in
            if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/com.company.AppName") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
}
