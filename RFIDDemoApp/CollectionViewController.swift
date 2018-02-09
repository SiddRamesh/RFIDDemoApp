
//
//  VerifiedVC.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/6/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//


import UIKit

class CollectionViewController: UIViewController ,NSURLConnectionDelegate,NSURLConnectionDataDelegate,XMLParserDelegate {

    let contentCellIdentifier = "ContentCellIdentifier"

    @IBOutlet weak var collectionView: UICollectionView!
   
    @IBOutlet weak var iecLbl: UILabel!
    @IBOutlet weak var serialLbl: UILabel!
    @IBOutlet weak var billLbl: UILabel!
    @IBOutlet weak var billdateLbl: UILabel!
    @IBOutlet weak var esealLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var portLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var truckLbl: UILabel!
    @IBOutlet weak var enterByLbl: UILabel!
   
    @IBOutlet weak var latLbl: UILabel!
    @IBOutlet weak var longLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var verifiedLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
     var activity_indicator_count:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        
        self.search()
    }
    
    
     //MARK: - SOAP Handler
 //    final let urlString = URL(string: "http://www.designindya.ind.in/wellstick.asmx")
    final let urlString = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    var mutableData:NSMutableData  = NSMutableData()
    var response:URLResponse = URLResponse()
    var currentElementName:String = ""
    
 //   @IBAction func SearchData(_ sender: Any) {
        
        func search() {
        
        showNetworkActivity()
           //  <date>\(datee)</date>
            let bill = "All"  // from serach
            let iec = "All"   // from serach
         //   let datee = "02/06/2018"
            let port = "INNSA1"

            let soapMessage = """
            <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetIncomingInformationAll xmlns='http://tempuri.org/'>
            <billno>\(bill)</billno>
            <iec>\(iec)</iec>
            <port>\(port)</port>                                                                                                                                                                                                                                     </GetIncomingInformationAll>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
            """
            
            
//            let im = "359473076624481"
//
//            let soapMessage = """
//            <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <Rfidimei1 xmlns='http://tempuri.org/'>
//            <IMEI>\(im)</IMEI>
//            </Rfidimei1>                                                                                                                                                                                                                            </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
//            """
        
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
    
    //MAR: - NSXMLParserDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElementName = elementName
        print("Element -> ",elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
     //   if currentElementName == "ReportData" {
            
      //      self.sshowAlertMessage(messageTitle: "Fetching Data", withMessage: "Failed!")
    //    } else  {
            if self.currentElementName == "S1" { self.serialLbl.text = "Serial No: " + string }
            if self.currentElementName == "S2" {  self.iecLbl.text = "IEC Code: " + string }
            if self.currentElementName == "S3" {  self.billLbl.text = "Bill No: " + string }
            if self.currentElementName == "S4" {  self.truckLbl.text = "Truck No: " + string }
            if self.currentElementName == "S5" {  self.codeLbl.text = "Code No: " + string }
            if self.currentElementName == "S6" {  self.portLbl.text = "Port: " + string }
            if self.currentElementName == "S7" {  self.dateLbl.text = "Date: " + string }
            if self.currentElementName == "S8" {  self.timeLbl.text = "Time: " + string }
            if self.currentElementName == "S9" {  self.enterByLbl.text = "Enter On: " + string }
            if self.currentElementName == "S10" {  self.esealLbl.text = "e-Seal: " + string }
            if self.currentElementName == "S11" {  self.esealLbl.text = "Lat: " + string }
            if self.currentElementName == "S12" {  self.esealLbl.text = "Long " + string }
            if self.currentElementName == "S13" {  self.esealLbl.text = "Verified: " + string }
            
            self.sshowAlertMessage(messageTitle: "Verified", withMessage: "Success :)")
     //   }
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
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
        
        print("XML Parse..",xmlParser)
    }
    
    //MARK: - Activity...
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
    //E.O.L
    

}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 14 //No. of coloumns //Also change in main file...
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell

//        if indexPath.section == 0 {
//            cell.backgroundColor = UIColor.gray
//        }
        
        if indexPath.section % 2 != 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.gray
        }
        
    //    let fon:UIFont = .boldSystemFont(ofSize: 20)
        let para:NSMutableParagraphStyle = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        para.alignment = .center
        
        
        
        if indexPath.section == 0 {

            //For Header...
//            if indexPath.row == 0 {
//                cell.contentLabel.text = "IEC Code"
//            } else {
//                cell.contentLabel.text = "Section"
//            }
            //  cell.layer.borderWidth = 1.0
            // cell.contentLabel.font = fon
            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " IEC Code  "
            case 1:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Bill No. "
            case 2:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Bill Date "
            case 3:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " e-Seal No. "
            case 4:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Sealing Date "
            case 5:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Sealing Time "
            case 6:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Dest. Port "
            case 7:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Container No. "
            case 8:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Truck No. "
            case 9:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Latitude "
            case 10:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Longitude "
            case 11:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Area "
            case 12:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Verified "
            default:
                cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
                cell.contentLabel.text = " Count "
            }

            //For Content....
            
        } else {
//            if indexPath.row == 0 {
//                cell.contentLabel.text = String(indexPath.section)
//            } else {
//                cell.contentLabel.text = "Content"
//            }
            
            switch indexPath.row {
            case 0:
               // cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
              //  cell.layer.borderWidth = 2.0
             //   cell.contentLabel.font = fon
                cell.contentLabel.text = " "// self.iecLbl.text! //+ String(indexPath.section)
            case 1:
                cell.contentLabel.text = " "//self.billLbl.text! //+ String(indexPath.section)
            case 2:
                cell.contentLabel.text = " "//self.billdateLbl.text! //+ String(indexPath.section)
            case 3:
                cell.contentLabel.text = " "//self.esealLbl.text! //+ String(indexPath.section)
            case 4:
                cell.contentLabel.text = " "//self.dateLbl.text! //+ String(indexPath.section)
            case 5:
                cell.contentLabel.text = " "//self.timeLbl.text! //+ String(indexPath.section)
            case 6:
                cell.contentLabel.text = " "//self.portLbl.text! //+ String(indexPath.section)
            case 7:
                cell.contentLabel.text = " "//self.codeLbl.text! //+ String(indexPath.section)
            case 8:
                cell.contentLabel.text = " "//self.truckLbl.text! //+ String(indexPath.section)
            case 9:
                cell.contentLabel.text = " "//self.latLbl.text!
            case 10:
                cell.contentLabel.text = " "//self.longLbl.text!
            case 11:
                cell.contentLabel.text = " "//self.areaLbl.text!
            case 12:
                cell.contentLabel.text = " "//self.verifiedLbl.text!
            default:
                cell.contentLabel.text = " "//self.countLbl.text! //+ String(indexPath.section)
            }
            
            //END.....Mian
        }

        return cell
    }

}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {

}


