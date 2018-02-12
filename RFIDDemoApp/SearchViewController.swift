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
    
    let contentCellIdentifier = "ContentCellIdentifier"
    
    final let urlString = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)

        self.search("GetVerifyContainerAll", "All","All","INNSA1")
    }
    
    func search(_ webService: String, _ bill: String, _ iec: String,_ port: String ) {
        
        let soapMessage = """
        <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <\(webService) xmlns='http://tempuri.org/'>
        <billno>\(bill)</billno>
        <iec>\(iec)</iec>                                                                                                                                                                                                                          <port>\(port)</port>                                                                                                                                                                                                                                     </\(webService)>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
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
                    }
                }
            }
        }
        dataTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("Searching Data...",theRequest)
    }
    
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        reportDatas.removeAll()
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
            
        else if elementName == "ReportData" { reportDatas.append(reportdat) }
        
        //print("End -> ",elementName)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        if reportDatas.isEmpty { print("Error, No Data Found") } else {
            print(reportDatas.count)
            scan.showPopup(withTagStatus: "complete", found: "Updated")
            //   print("Data is", reportDatas[2].S5)
            //   print("S1 ->", reportdat.S1)
            //   print("S2 -> ", reportdat.S2)
        }
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        if reportDatas.isEmpty { print("Error !")
            scan.showPopup(withTagStatus: "cancel", found: "Data Not Found")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return reportDatas.count
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
        
        if reportDatas[indexPath.section].S12 == "Yes" {
            cell.backgroundColor = UIColor.green
        } else {
            cell.backgroundColor = UIColor.red
        }
        
        //    let fon:UIFont = .boldSystemFont(ofSize: 20)
        let para:NSMutableParagraphStyle = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        para.alignment = .center
        
        
        if indexPath.section == 0 {
            
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
                cell.contentLabel.text = reportDatas[indexPath.section].S10
            case 10:
                cell.contentLabel.text = reportDatas[indexPath.section].S11
            case 11:
                cell.contentLabel.text = "Mumbai, IN"
            case 12:
                cell.contentLabel.text = reportDatas[indexPath.section].S12
            default:
                cell.contentLabel.text = reportDatas[indexPath.section].S13
            }
            
            //END.....Mian
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension SearchViewController : UICollectionViewDelegate {
    
}



