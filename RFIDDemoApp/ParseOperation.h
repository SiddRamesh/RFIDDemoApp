//
//  ParseOperation.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

@property (copy, readonly) NSData *stockData;

- (instancetype)initWithData:(NSData *)parseData NS_DESIGNATED_INITIALIZER;

+ (NSString *)AddStockdatasNotificationName;
+ (NSString *)StockdatasResultsKey;

+ (NSString *)StockdatasErrorNotificationName;
+ (NSString *)StockdatasMessageErrorKey;           



@end
