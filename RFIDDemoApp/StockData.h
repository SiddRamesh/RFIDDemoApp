//
//  StockData.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockData : NSObject

// Magnitude of the earthquake on the Richter scale.
//@property (nonatomic) float magnitude;

@property (nonatomic, strong) NSString *serial;
@property (nonatomic, strong) NSString *iec;
@property (nonatomic, strong) NSString *bill;
@property (nonatomic, strong) NSString *truck;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *eseal;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *entryby;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *datee;

@property (nonatomic, strong) NSString *location;
// Date and time at which the earthquake occurred.
@property (nonatomic, strong) NSDate *date;
// Latitude and longitude of the earthquake.
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@end
