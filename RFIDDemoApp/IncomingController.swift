//
//  ViewController.swift
//  StockAxiz
//
//  Created by Ramesh Siddanavar on 10/28/17.
//  Copyright © 2017 Ramesh Siddanavar. All rights reserved.
//

import UIKit


class IncomingController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    final let url = URL(string: "http://atm-india.in/RFIDDemoservice.asmx")
    private var datas = [ReportData]()      //[Dataz]()
    @IBOutlet var tableView: UITableView!
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        downloadJson()
    }
    
    //MARK:- XML Handler
    func downloadJson() {
      //  guard let downloadURL = url else { return }
        let theRequest = NSMutableURLRequest(url: self.url!)
        URLSession.shared.dataTask(with: theRequest as URLRequest) { data, urlResponse, error in
              guard let data = data, error == nil, urlResponse != nil else {
                print("Error while Fetching data...")
                return
            }
            print("Fetchin Data... Done!")
            do {
                print("Deserializing XML...")
                let bill = "All"
                let iec =  "All"
                let port = "INNSA1"
                
                let soapMessage = """
                <?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetVerifyContainerAll xmlns='http://tempuri.org/'>
                <billno>\(bill)</billno>
                <iec>\(iec)</iec>                                                                                                                                                                                                                          <port>\(port)</port>                                                                                                                                                                                                                                     </GetVerifyContainerAll>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>
                """
    
                let msgLength = soapMessage.count
                
                theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
                theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
                theRequest.httpMethod = "POST"
                theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)

            } //catch {
               // print("Error Deserializing XML: \(error)")
           // }
            do
            {
                let downloadedData = try XMLDecoder().decode(ReportData.self, from: data)
                print(downloadedData.S1)
              //  self.datas = downloadedData.data
                if((error) != nil) { // Check Error..
                    print(error!.localizedDescription)
                }else {
                    let str = NSString(data: data, encoding:String.Encoding.utf8.rawValue)
                    print("String is ->",str as Any)
                }//else Error Print
                DispatchQueue.main.async { // print("The following Stocks are available:") for product in self.datas { print("IEC is" + " :" ,product.IEC_CODE)  }
                    print("Decoding Data... Done")
                    self.tableView.reloadData()
                }// Dispatch..
            } catch {
                print("Error Decoding.... :(")
            }
        }.resume()
    }
    
    
    //MARK:- Table View Delegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let curr = dateFormatter.string(from: now as Date)
        return "Last Updated... " + curr
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") else { return UITableViewCell() }
        
        cell.textLabel?.text =       "Bill No. : " + datas[indexPath.row].S1
        cell.detailTextLabel?.text = "IEC Code : " + datas[indexPath.row].S2
       
        return cell
    }
}

