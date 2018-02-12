//
//  VerifyController.swift
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/12/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

import UIKit

class VerifyController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var popupController:CNPPopupController?
    var scan:ScanVC?
    
    let que:OperationQueue = OperationQueue()
    var dataTask:URLSessionDataTask = URLSessionDataTask()
    var theRequest:NSMutableURLRequest = NSMutableURLRequest()
    var parser:XMLParser = XMLParser()
    var captureString:String = String()
    var captureDouble:Double = Double()
    var reportDatas:[ReportData] = [ReportData]()
    var reportdat:ReportData = ReportData()
    var flag:Bool = false
    
    
    final let urlString = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
      
         self.search("GetAssignTag1", "862425120607AAA000000021","INNSA1")
        activity()
    }

    func search(_ webService: String, _ tag: String,_ port: String ) {
        
        let soapMessage = """
        <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <\(webService) xmlns='http://tempuri.org/'>
        <Tag>\(tag)</Tag>                                                                                                                                                                                                                          <port>\(port)</port>                                                                                                                                                                                                                                     </\(webService)>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
        """
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        theRequest = NSMutableURLRequest.init(url: self.urlString!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        dataTask = URLSession.shared.dataTask(with: theRequest as URLRequest) { data, response, error in
            if((error) != nil) {
                self.que.addOperation {
                    self.parser(self.parser, parseErrorOccurred: error!)
                }
                print(error!.localizedDescription)
            }else { // For Debuging...
                //   let str = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                //     print("String is ->",str as Any)
                DispatchQueue.main.async {
                    print("The following Stocks are available:")
                    OperationQueue.main.addOperation {
                        self.parser = XMLParser(data: data!)
                        self.parser.delegate = self
                        self.parser.parse()
                        self.tableView.reloadData()
                        print("______________________________________")
                        print("Decoding Data... Done")
                    }
                }
            }
        }
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Searching Data...",theRequest)
    }
    
    func activity(){
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.frame = CGRect.init(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 80.0, height: 80.0)
        activityIndicatorView.center = self.view.center

        self.view.addSubview(activityIndicatorView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - PopUp
    func showPopupWithStyle(_ popupStyle: CNPPopupStyle,_ statusImg:String, found:String) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        let title = NSAttributedString(string: found, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 24), NSParagraphStyleAttributeName: paragraphStyle])
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let imageView = UIImageView.init(image: UIImage.init(named: statusImg))
        
        let popupController = CNPPopupController(contents:[titleLabel, imageView])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = popupStyle
        // LFL added settings for custom color and blur
        popupController.theme.maskType = .custom
        popupController.theme.customMaskColor = UIColor.red
        popupController.theme.blurEffectAlpha = 1.0
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
}

extension VerifyController : CNPPopupControllerDelegate {
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        print("Popup controller will be dismissed")
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}


extension VerifyController : XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
        flag = false
        captureString = ""
        reportDatas = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        flag = false
        captureString = ""
        if elementName == "ReportData" { reportdat = ReportData() }
        else if elementName == "S1" || elementName == "S2" || elementName == "S3" || elementName == "S4" || elementName == "S5"
            || elementName == "S6" || elementName == "S7" || elementName == "S8" || elementName == "S9" || elementName == "S10"
            || elementName == "S11" || elementName == "S12" || elementName == "S13" { flag = true; }
        //   print("Start ->", elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if flag { captureString += string } //flag!
        //    print("Found ->: ",string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        flag = false
        if elementName == "S1" { reportdat.S1 = captureString }
        else if elementName == "S2" { reportdat.S2 = captureString }
        else if elementName == "S3" { reportdat.S3 = captureString }
        else if elementName == "S4" { reportdat.S4 = captureString }
        else if elementName == "S5" { reportdat.S5 = captureString }
        else if elementName == "S6" { reportdat.S6 = captureString }
        else if elementName == "S7" { reportdat.S7 = captureString }
        else if elementName == "S8" { reportdat.S8 = captureString }
        else if elementName == "S9" { reportdat.S9 = captureString }
        else if elementName == "S10" { reportdat.S10 = captureString  }
        else if elementName == "S11" { reportdat.S11 = captureString  }
        else if elementName == "S12" { reportdat.S12 = captureString }
        else if elementName == "S13" { reportdat.S13 = captureString }
            
        else if elementName == "ReportData" { reportDatas.append(reportdat) }
        
        //print("End -> ",elementName)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if reportDatas.isEmpty { print("Error, No Data Found") } else {
            print(reportDatas.count)
            let scan = ScanVC()
            scan.showPopup(withTagStatus: "complete", found: "Updated Data")
            //   print("Data is", reportDatas[2].S5)
            //   print("S1 ->", reportdat.S1)
            //   print("S2 -> ", reportdat.S2)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        if reportDatas.isEmpty { print("Error !"); self.showPopupWithStyle(CNPPopupStyle.centered, "cancel", found: "Data Not Found!") }
    }
}

extension VerifyController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = reportDatas.count
        
        // if there's no data yet, return enough rows to fill the screen
        if (count == 0)
        {
            return 3
        }
        return count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        activityIndicatorView.startAnimating()
        let nodeCount = reportDatas.count
        
        if (nodeCount == 0 && indexPath.row == 0)
        {
            cell = (tableView.dequeueReusableCell(withIdentifier: "Hold", for: indexPath))
            
        }
        else {
            cell = (tableView.dequeueReusableCell(withIdentifier: "Lazy", for: indexPath))
            
            if (nodeCount > 0)
            {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidesWhenStopped = true
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S1
                case 1:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S2
                case 2:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S3
                case 3:
                   cell.textLabel?.text =  reportDatas[indexPath.row].S4
                case 4:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S5
                case 5:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S6
                case 6:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S7
                case 7:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S8
                default:
                    cell.textLabel?.text =  reportDatas[indexPath.row].S9
                }
                
             //   cell.textLabel?.text =  reportDatas[indexPath.row].S4
           //     cell.detailTextLabel?.text =  reportDatas[indexPath.row].S9
                
                //    let la = reportDatas[indexPath.row].S10 //for lat
                //    let lo = reportDatas[indexPath.row].S11 // for long
                //   setLocation(la!, lo!)
                //      print(la as Any,lo as Any)
            } //Node..
        }//else
        return cell
    }
}
