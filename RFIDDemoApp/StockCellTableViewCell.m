//
//  StockCellTableViewCell.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "StockCellTableViewCell.h"
#import "StockData.h"

@interface StockCellTableViewCell ()

// References to the subviews which display the earthquake data.
@property (nonatomic, retain) IBOutlet UILabel *serialLabel;
@property (nonatomic, retain) IBOutlet UILabel *iecLabel;
@property (nonatomic, retain) IBOutlet UILabel *billLabel;
@property (nonatomic, retain) IBOutlet UILabel *truckLabel;
@property (nonatomic, retain) IBOutlet UILabel *codeLabel;
@property (nonatomic, retain) IBOutlet UILabel *esealLabel;
@property (nonatomic, retain) IBOutlet UILabel *portLabel;
@property (nonatomic, retain) IBOutlet UILabel *entrybyLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateeLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
//@property (nonatomic, weak) IBOutlet UIImageView *magnitudeImage;

@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end

@implementation StockCellTableViewCell

// @synthesize serialLabel;

-(void)configureWithStockData:(StockData *)stockdata {
    
     self.iecLabel.text = stockdata.serial;
     self.iecLabel.text = stockdata.iec;
     self.billLabel.text = stockdata.bill;
     self.truckLabel.text = stockdata.truck;
     self.codeLabel.text = stockdata.code;
     self.esealLabel.text = stockdata.eseal;
     self.portLabel.text = stockdata.port;
     self.entrybyLabel.text = stockdata.entryby;
     self.dateeLabel.text = stockdata.datee;
     self.timeLabel.text = stockdata.time;
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:stockdata.date]];
  //  self.magnitudeLabel.text = [NSString stringWithFormat:@"%.1f", earthquake.magnitude];
   // self.magnitudeImage.image = [self imageForMagnitude:earthquake.magnitude];
    
}


// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter {
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    }
    return dateFormatter;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
