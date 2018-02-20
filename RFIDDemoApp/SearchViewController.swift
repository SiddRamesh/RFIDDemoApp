//
//  SearchViewController.swift
//  StockAxiz
//
//  Created by Ramesh Siddanavar on 1/19/18.
//  Copyright © 2018 Ramesh Siddanavar. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
   @IBOutlet weak var collectionView: UICollectionView!
    
    var activityIndicatorView = UIActivityIndicatorView()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    
    var popupController:CNPPopupController?
    let scan:ScanVC = ScanVC()
    
    let que:OperationQueue = OperationQueue()
    var dataTask:URLSessionDataTask = URLSessionDataTask()
    var theRequest:NSMutableURLRequest = NSMutableURLRequest()
    var xmlParser:XMLParser = XMLParser()
    var captureString:String = String()
    var captureDouble:Double = Double()
    var reportDatas:[ReportData] = [ReportData]()
    var reportdat:ReportData = ReportData()
    var flag:Bool = false
    var dat:String = ""
    
    let contentCellIdentifier = "ContentCellIdentifier"
    
    final let urlString = URL(string: "http://atm-india.in/EnopeckService.asmx")
    
    //No Data When search..
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        showActivityView(view)
        
        let datee = NSDate.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dat = dateFormatter.string(from: datee as Date)
        
        //   UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanDataWithTag:nPort:)];
        //    self.navigationItem.rightBarButtonItem = barButtonScan;
        
        let barButton = UIBarButtonItem.init(title: "Filter", style: .plain, target: self, action:#selector(showFilter))
        self.navigationItem.rightBarButtonItem = barButton
        self.search("All","All","INNSA1",dat)
    }
    
    func search(_ bill: String, _ iec: String,_ port: String,_ datee:String ) {
        
        let webService = "GetIncomingInformation" // "GetVerifyContainerAll"
        
        let soapMessage = """
        <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <\(webService) xmlns='http://tempuri.org/'>
        <billno>\(bill)</billno>
        <iec>\(iec)</iec>
        <date>\(datee)</date>
        <port>\(port)</port>                                                                                                                                                                                                                                     </\(webService)>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
        """
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        theRequest = NSMutableURLRequest.init(url: self.urlString!, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60)
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(soapMessage.count), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        dataTask = URLSession.shared.dataTask(with: theRequest as URLRequest) { data, response, error in
            if((error) != nil) {
                self.que.addOperation {
                    self.parser(self.xmlParser, parseErrorOccurred: error!)
                }
                print(error!.localizedDescription)
            }else { // For Debuging...
                //   let str = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                //     print("String is ->",str as Any)
                DispatchQueue.main.async {
                    print("The following Stocks are available:")
                    OperationQueue.main.addOperation {
                        self.xmlParser = XMLParser(data: data!)
                        self.xmlParser.delegate = self
                        self.xmlParser.parse()
                        self.collectionView.reloadData()
                        print("______________________________________")
                        print("Decoding Data... Done")
                        self.hideActivityView()
                    }
                }
            }
        }
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Searching Data...",theRequest)
       // showActivityView(view)
    }
    
    //MARK: - Filters
    
    

    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        reportDatas.removeAll()
    }
    
    //MARK: - Activity View
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
        dateTextField.placeholder = dat
        dateTextField.text = dat
        
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
            self.search(billTextField.text!, iecTextField.text!, portTextField.text!, dateTextField.text!)
        }
        
        //   showActivityView(view)
        let popupController = CNPPopupController(contents:[titleLabel, billTextField, iecTextField, portTextField, dateTextField, button])
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
   
}

extension SearchViewController : CNPPopupControllerDelegate {
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        print("Popup controller will be dismissed")
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}


extension SearchViewController : XMLParserDelegate {
    
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
            
        else if elementName == "ReportData" { reportDatas.append(reportdat) } //else { parser.abortParsing() }
        
        //print("End -> ",elementName)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        hideActivityView()
        if reportDatas.isEmpty { print("Error, No Data Found")
          //  self.showPopupWithStyle(CNPPopupStyle.centered, "cancel", found: "Data Not Found!")
            scan.showPopup(withTagStatus: "cancel", found: "Data Not Found!")
            parser.abortParsing()
            dataTask.cancel()
            
        } else {
            print(reportDatas.count)
         //   hideActivityView()
            scan.showPopup(withTagStatus: "complete", found: "Updated")
            //   print("Data is", reportDatas[2].S5)
            //   print("S1 ->", reportdat.S1)
            //   print("S2 -> ", reportdat.S2)
        }
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        if reportDatas.isEmpty { print("Error !")
            scan.showPopup(withTagStatus: "cancel", found: "Data Not Found")
            parser.abortParsing()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      //  return reportDatas.count
        
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
        
        //        if indexPath.section == 0 {
        //            cell.backgroundColor = UIColor.gray
        //        }
        
        if indexPath.section % 2 != 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.gray
        }
        
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
             cell.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.8)
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
            
        } else  {
            
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
                cell.contentLabel.text = reportDatas[indexPath.section].S10  ?? "N/A"  //lat
            case 10:
                cell.contentLabel.text = reportDatas[indexPath.section].S11  ?? "N/A" //Long
            case 11:
                cell.contentLabel.text = reportDatas[indexPath.section].S12
            default:
                cell.contentLabel.text = reportDatas[indexPath.section].S13
            }
            
            //END.....Mian
        }
                } //node
            } //else
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension SearchViewController : UICollectionViewDelegate {
    
}



