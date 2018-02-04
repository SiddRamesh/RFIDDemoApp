//
//  GenerateMasterViewController.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/3/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GenerateMasterViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate> {
    
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
