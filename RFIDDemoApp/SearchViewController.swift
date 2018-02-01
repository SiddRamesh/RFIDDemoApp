//
//  SearchViewController.swift
//  StockAxiz
//
//  Created by Ramesh Siddanavar on 1/19/18.
//  Copyright © 2018 Ramesh Siddanavar. All rights reserved.
//

import Foundation
import UIKit

class DataCell: UITableViewCell {
    
    @IBOutlet var IEC: UILabel!
    @IBOutlet var SHIPPING_BILL_NO: UILabel!
    @IBOutlet var SHIPPING_BILL_DATE: UILabel!
    @IBOutlet var E_SEAL_NO: UILabel!
    @IBOutlet var SEALING_DATE: UILabel!
    @IBOutlet var SEALINT_TIME: UILabel!
    @IBOutlet var EXPORT: UILabel!
    @IBOutlet var CONTAINER_NO: UILabel!
    @IBOutlet var TRUCK_NO: UILabel!
    @IBOutlet var LATITUDE: UILabel!
    @IBOutlet var LONGITUDE: UILabel!
    @IBOutlet var IMEI: UILabel!
    @IBOutlet var SCANNED_DATA: UILabel!
}

class SearchViewController: UIViewController,UITableViewDataSource, UITextFieldDelegate, NSURLConnectionDelegate,NSURLConnectionDataDelegate,XMLParserDelegate {

    @IBOutlet weak var tableView: UITableViewCell!
    
    @IBOutlet weak var serialLbl: UILabel!
    @IBOutlet weak var iecLbl: UILabel!
    @IBOutlet weak var billLbl: UILabel!
    @IBOutlet weak var truckLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var esealLbl: UILabel!
    @IBOutlet weak var portLbl: UILabel!
    @IBOutlet weak var enterByLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lbl_download: UILabel!
    
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var portTxt: UITextField!
    
    @IBOutlet weak var taskProgress:UIProgressView!
    var progressValue = 0.0
    
    @IBOutlet weak var searchBtn: UIButton!
    var activity_indicator_count:Int = 0
    
    final let urlString = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    
    var mutableData:NSMutableData  = NSMutableData()
    var response:URLResponse = URLResponse()
    var currentElementName:String = ""
    var ele1:String = ""
    
    @IBAction func SearchData(_ sender: Any) {

        showNetworkActivity()
        lbl_download.isHidden = false
        taskProgress.isHidden = false
        
        let tag =   searchTxt.text //  " ?? E200637C90D1D6B16611275A" // ilq7-lous-m0cy
        let port =  portTxt.text // "INNSA1" //
        
        let soapMessage = "<?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetAssignTag1 xmlns='http://tempuri.org/'>                                                                                                                                                                                                  <Tag>\(tag!)</Tag>                                                                                                                                                                                                                            <port>\(port!)</port>                                                                                                                                                                                                                                     </GetAssignTag1>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>"
        
        let theRequest = NSMutableURLRequest(url: self.urlString!)
        let msgLength = soapMessage.count
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let connection = NSURLConnection(request: theRequest as URLRequest, delegate: self, startImmediately: true)
 
        let dataTask = URLSession.shared.dataTask(with: theRequest as URLRequest) { data, response, error in
            if((error) != nil) {
                print(error!.localizedDescription)
            }else {
                let str = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                print("String is ->",str as Any)
        
                DispatchQueue.main.async {
                    print("The following Stocks are available:")
                    self.taskProgress.setProgress(0.1, animated: true)
                    
                    print("______________________________________")
                    print("Decoding Data... Done")
                    self.hideNetworkActivity()
                }
            }
        }
        dataTask.resume()
        connection!.start()
        print("Searching Data...",theRequest)
    }
    
    func sshowAlertMessage(messageTitle: NSString, withMessage: NSString) ->Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
 
    //MARK: - NSXMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElementName = elementName
        
        print("Element -> ",elementName)
        ele1 = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
      if currentElementName == "ReportData" {
       self.sshowAlertMessage(messageTitle: "Fetching Data", withMessage: "Failed!")
        
        } else  {
        
        if self.ele1 == "S1" { self.serialLbl.text = "Serial No: " + string }
        if self.ele1 == "S2" {  self.iecLbl.text = "IEC Code: " + string }
        if self.ele1 == "S3" {  self.billLbl.text = "Bill No: " + string }
        if self.ele1 == "S4" {  self.truckLbl.text = "Truck No: " + string }
        if self.ele1 == "S5" {  self.codeLbl.text = "Code No: " + string }
        if self.ele1 == "S6" {  self.portLbl.text = "Port: " + string }
        if self.ele1 == "S7" {  self.dateLbl.text = "Date: " + string }
        if self.ele1 == "S8" {  self.timeLbl.text = "Time: " + string }
        if self.ele1 == "S9" {  self.enterByLbl.text = "Enter On: " + string }
        if self.ele1 == "S10" {  self.esealLbl.text = "e-Seal: " + string }
        
        self.sshowAlertMessage(messageTitle: "Fetching Data", withMessage: "Success :)")
        }
        print("PData ->: ",string)
    }
    
    //MARK: - NSURLConnectionDelegate
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Connection Error = \(error)")
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        mutableData = NSMutableData()
        self.response = response;
        print("Mutable Data..",mutableData)
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.mutableData.append(data)
        print("Connection Data..",data)
        
        self.taskProgress.progress = Float((Int(100/self.response.expectedContentLength) * (self.mutableData.length))/100);
        
        let per = (Int(100/self.response.expectedContentLength) * (self.mutableData.length));
        self.lbl_download.text = String(per)  //  [String stringWithFormat:@"%0.f%%", per];
        
        if (self.taskProgress.progress == 1) {
            self.taskProgress.isHidden = true
            self.searchBtn.isEnabled = true
        } else {
            self.taskProgress.isHidden = false
        }
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
        self.taskProgress.isHidden = true
        self.lbl_download.isHidden = true
        self.lbl_download.text = "Task Complete";
        
        print("XML Parse..",xmlParser)
    }
    
    func showNetworkActivity(){
        activity_indicator_count += 1
        if (activity_indicator_count > 0) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func hideNetworkActivity(){
        activity_indicator_count -= 1;
        if(activity_indicator_count < 1){
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.lbl_download.isHidden = true
        self.taskProgress.isHidden = true
        self.taskProgress.setProgress(0.0, animated: false)
    }
    
    // Keyboard Hiding...
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.taskProgress = nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let curr = dateFormatter.string(from: now as Date)
        return "Last Updated... " + curr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  0 //datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell")  as? DataCell else { return UITableViewCell() }
        
   //     cell.IEC.text = "IEC: " + datas[indexPath.row].id.description
        
        cell.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

}

