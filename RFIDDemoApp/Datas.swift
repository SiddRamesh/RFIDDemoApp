//
//  Datas.swift
//  StockAxiz
//
//  Created by Ramesh Siddanavar on 10/28/17.
//  Copyright © 2017 Ramesh Siddanavar. All rights reserved.
//

import UIKit

//class Datas: Codable {
//    let data: [Dataz]
//
//    init(data: [Dataz]) {
//        self.data = data
//    }
//}

/*
 class Dataz: Codable {
 
 var IEC_CODE: String!
 var S_BILL_NO: String!
 var E_SEAL_NO: String!
 var SERIAL_CODE: String!
 var SEALING_DATE: String!
 var SEALING_TIME: String!
 var DESTINATION_PORT: String!
 var CONTAINER_NO: String!
 var VEHICLE_NO: String!
 var SHIPPING_DATE: String!
 
 var TID_NO: String!
 var LATITUDE : String!
 var LONGITUDE : String!
 var AREA : String!
 var VERIFIED : String!
 }
 
*/
class ReportData: NSObject {
    
    var S1: String!
    var S2: String!
    var S3: String!
    var S4: String!
    var S5: String!
    var S6: String!
    var S7: String!
    var S8: String!
    var S9: String!
    var S10: String!
    var S11: String!
    var S12 : String!
    var S13 : String!
    
    enum CodingKeys: String, CodingKey {
        case S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13
    }
    
}
