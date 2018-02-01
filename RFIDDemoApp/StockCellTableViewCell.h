//
//  StockCellTableViewCell.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StockData;

@interface StockCellTableViewCell : UITableViewCell

- (void)configureWithStockData:(StockData *)stockdata;

@end
