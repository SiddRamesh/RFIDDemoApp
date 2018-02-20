//
//  VerifyController.swift
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/12/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

import UIKit

class VerifyController: UIViewController {

     @IBOutlet weak var collectionView: UICollectionView!
     let contentCellIdentifier = "ContentCellIdentifier"
 //   @IBOutlet var tableView: UITableView!
    
    var activityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    var billBox:UITextField = UITextField()
    var iecBox:UITextField = UITextField()
    var porttBox:UITextField = UITextField()
    var dropDown:UIPickerView = UIPickerView()
    
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
    var abortParsing = true
    
     var list = ["string", "string"]
    
//    final let urlString = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    final let urlString = URL(string: "http://atm-india.in/EnopeckService.asmx")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        
        let barButton = UIBarButtonItem.init(title: "Filter", style: .plain, target: self, action:#selector(showFilter))
        self.navigationItem.rightBarButtonItem = barButton
        
        self.search("All", "All","INNSA1")
      //   self.defaul()
         showActivityView(view)
    }

    func search(_ bill: String, _ iec: String, _ port: String ) {
        
        let dat = "02/12/2018"
        
        let soapMessage = """
        <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetIncomingInformation xmlns='http://tempuri.org/'>
        <billno>\(bill)</billno>
        <iec>\(iec)</iec>
        <date>\(dat)</date>                                                                                                                                                                                                                         <port>\(port)</port>                                                                                                                                                                                                                                     </GetIncomingInformation>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
        """

        
//        let soapMessage = """
//                            <?xml version="1.0" encoding="utf-8"?>
//<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//  <soap12:Body>
//    <\(webService) xmlns="http://tempuri.org/">
//      <Tag>\(tag)</Tag>
//      <port>\(port)</port>
//    </\(webService)>
//  </soap12:Body>
//</soap12:Envelope>
//
//"""
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        theRequest = NSMutableURLRequest.init(url: self.urlString!, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60)
     //   theRequest.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
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
                        
//                        if (response != nil) {
//                            if response?.mimeType == "application/soap+xml" {
//                                self.parser = XMLParser(data: data!)
//                                self.parser.delegate = self
//                                self.parser.parse()
//                                self.tableView.reloadData()
//                                print("SOAP 1.2 Called...")
//                            }
//                        } else {

                        self.parser = XMLParser(data: data!)
                        self.parser.delegate = self
                        self.parser.parse()
                     //   if self.reportDatas.isEmpty { self.parser.abortParsing(); self.showPopupWithStyle(CNPPopupStyle.centered, "cancel", found:"No Data Found") }
                        self.collectionView.reloadData();
                     //   self.defaul()
                        print("______________________________________")
                        print("Decoding Data... Done")
                  //     }//else
                    }
                }
            }
        }
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Searching Data...",theRequest)
     //   showActivityView(view)
       // self.collectionView.reloadData()
    }
    
    func defaul()  {
        self.showPopupWithStyle(CNPPopupStyle.centered, "complete", found:"Reloading")
     //   showActivityView(view)
        self.search("All", "All","INNSA1")
        self.collectionView.reloadData()
     //   sleep(1)
    //    hideActivityView()
    }
    
    func showActivityView(_ view: UIView) {
        
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor.clear
        
        loadingView.frame = CGRect.init(x:0, y:0, width:80.0, height:80.0)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(white:0.0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.frame = CGRect.init(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 80.0, height: 80.0)
        activityIndicatorView.center = self.view.center
        
        loadingView.addSubview(activityIndicatorView)
        container.addSubview(loadingView)
        view.addSubview(container)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.bringSubview(toFront: view)
        activityIndicatorView.startAnimating()
    }
    
    open func hideActivityView(){
        activityIndicatorView.stopAnimating()
        container.removeFromSuperview()
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
        popupController.theme.customMaskColor = UIColor.init(white: 0.7, alpha: 1.0)
        popupController.theme.blurEffectAlpha = 1.0
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
    func showFilter() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        let title = NSAttributedString(string: "Filters", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 24), NSParagraphStyleAttributeName: paragraphStyle])
        
        //Bill
        let billTextField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        billTextField.borderStyle = UITextBorderStyle.roundedRect
        billTextField.placeholder = "Bill"
        
        //Date
        let dateTextField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        dateTextField.borderStyle = UITextBorderStyle.roundedRect
        dateTextField.placeholder = "Date"
        
        //IEC
        let iecTextField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        iecTextField.borderStyle = UITextBorderStyle.roundedRect
        iecTextField.placeholder = "IEC"
        
        //Port
        let portTextField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        portTextField.borderStyle = UITextBorderStyle.roundedRect
        portTextField.placeholder = "Port"
        
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Search", for: UIControlState())
        
        button.backgroundColor = UIColor.init(red: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            //  print("Block for button: \(button.titleLabel?.text)")
            self.search(billTextField.text!, iecTextField.text!, portTextField.text!)
        }

     //   showActivityView(view)
        let popupController = CNPPopupController(contents:[titleLabel, billTextField, iecTextField, portTextField, button])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = .centered
        // LFL added settings for custom color and blur
        popupController.theme.maskType = .custom
        popupController.theme.customMaskColor = UIColor.blue
        popupController.theme.blurEffectAlpha = 1.0
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.collectionView.collectionViewLayout.invalidateLayout()
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
        
        if flag { captureString += string } else { parser.abortParsing() } //flag!
        // print("Found ->: ",string)
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
        
        hideActivityView()
      //  parser.abortParsing()
              if ( reportDatas.isEmpty ) {
                    print("Error, No Data Found");
                self.showPopupWithStyle(CNPPopupStyle.centered, "cancel", found: "Data Not Found!")
                parser.abortParsing()
                dataTask.cancel()
                } else {
                    print(reportDatas.count)
                //    let scan = ScanVC()
                 //   scan.showPopup(withTagStatus: "complete", found: "Updated Data")
                self.showPopupWithStyle(CNPPopupStyle.centered, "complete", found: "Data Updated")
                }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        if reportDatas.isEmpty { print("Error !"); self.showPopupWithStyle(CNPPopupStyle.centered, "cancel", found: "Data Not Found!"); parser.abortParsing() }
    }
}


// MARK: - UICollectionViewDataSource
extension VerifyController: UICollectionViewDataSource {
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
    
    //    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //
    //        //    reportDatas[sourceIndexPath.section]
    //
    //       // reportDatas[sourceIndexPath.section] = reportDatas[destinationIndexPath.section]
    //    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
     //   return reportDatas.count
        let count = reportDatas.count
        
        // if there's no data yet, return enough rows to fill the screen
        if (count == 0)
        {
            return 2
        }
        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 13 //No. of coloumns //Also change in main file...
    }
    
//    func collectionView(collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        return "Section name"
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast

        var cell:ContentCollectionViewCell
        
        let nodeCount = reportDatas.count
        
        if (nodeCount == 1 && indexPath.row == 1)
        {
            cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "Hold", for: indexPath) as! ContentCollectionViewCell)
            
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
            
            if (nodeCount > 1)
            {
        
     //   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
        
        if reportDatas[indexPath.section].S12 == "Yes" {
            cell.backgroundColor = UIColor.init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.8)
        } else {
            cell.backgroundColor = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8)
        }
        
        //    let fon:UIFont = .boldSystemFont(ofSize: 20)
        let para:NSMutableParagraphStyle = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        para.alignment = .center
        
        if indexPath.section == 0 {
         //   self.Serial.layer.borderWidth = 2.0; self.Serial.layer.cornerRadius = 5; self.Serial.layer.masksToBounds = true;
            cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
     //    cell.layer.borderWidth = 2.0; //cell.contentLabel.layer.masksToBounds = true
            switch indexPath.row {
            case 0:
                cell.contentLabel.text = " IEC Code  "
            case 1:
                cell.contentLabel.text = " Bill No. "
            case 2:
                cell.contentLabel.text = " Bill Date "
            case 3:
                cell.contentLabel.text = " e-Seal No. "
            case 4:
                cell.contentLabel.text = " Sealing Date "
            case 5:
                cell.contentLabel.text = " Sealing Time "
            case 6:
                cell.contentLabel.text = " Dest. Port "
            case 7:
                cell.contentLabel.text = " Container No. "
            case 8:
                cell.contentLabel.text = " Truck No. "
            case 9:
                cell.contentLabel.text = " Latitude "
            case 10:
                cell.contentLabel.text = " Longitude "
            case 11:
                cell.contentLabel.text = " Verified "
            default:
                cell.contentLabel.text = " Count "
            }
            //END.....Mian
        } else {
            
            switch indexPath.row {
                
            case 0:
                cell.contentLabel.text = reportDatas[indexPath.section].S1
            case 1:
                cell.contentLabel.text = reportDatas[indexPath.section].S2
            case 2:
                cell.contentLabel.text = reportDatas[indexPath.section].S3
            case 3:
                cell.contentLabel.text = reportDatas[indexPath.section].S4
            case 4:
                cell.contentLabel.text = reportDatas[indexPath.section].S5
            case 5:
                cell.contentLabel.text = reportDatas[indexPath.section].S6
            case 6:
                cell.contentLabel.text = reportDatas[indexPath.section].S7
            case 7:
                cell.contentLabel.text = reportDatas[indexPath.section].S8
            case 8:
                cell.contentLabel.text = reportDatas[indexPath.section].S9
            case 9:
                cell.contentLabel.text = reportDatas[indexPath.section].S10
            case 10:
                cell.contentLabel.text = reportDatas[indexPath.section].S11
            case 11:
                cell.contentLabel.text = reportDatas[indexPath.section].S12
            default:
                cell.contentLabel.text = reportDatas[indexPath.section].S13
            }
        }
                } //node
            }// else
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension VerifyController : UICollectionViewDelegate {
    
}

// MARK: - UIPickerViewViewDelegate
extension VerifyController : UIPickerViewDataSource {
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return list.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return list[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.billBox.text = self.list[row]
        self.dropDown.isHidden = true
        
    }
    
}

extension VerifyController: UIPickerViewDelegate {
    
    
}

extension VerifyController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.billBox {
            self.dropDown.isHidden = false
            //if you dont want the users to se the keyboard type:
            
            textField.endEditing(true)
        }
        
    }
}



/*
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
*/
