//
//  RFIDDeviceCellViewTableViewCell.h
//  RFIDDemoApp
//
//  Created by SST on 11/03/15.
//  Copyright (c) 2015 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RfidReaderInfo.h"

@interface zt_RFIDDeviceCellView : UITableViewCell
- (void)setDataWithReaderInfo:(srfidReaderInfo *)info widthIndex:(int)idx;
- (void)setActiveWithModel:(NSString *)model withSerial:(NSString *)serial withBTAddress:(NSString*)bt_address;
- (void)setUnactive;
- (void)setActiveWithNoValues;
@end
