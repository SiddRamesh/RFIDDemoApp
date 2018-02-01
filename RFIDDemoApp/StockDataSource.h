//
//  StockDataSource.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockDataSource : NSObject

@property (readonly) NSMutableArray *stockdatas;
@property (readonly) NSError *error;

- (void)startStockdataLookup;

@end
