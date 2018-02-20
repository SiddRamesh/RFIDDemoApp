//
//  GenerateMasterViewController.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/3/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GenerateMasterViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;


@property (nonatomic,copy) NSString* bill;
@property (nonatomic,copy) NSString* date;
@property (nonatomic,copy) NSString* timee;
@property (nonatomic,copy) NSString* container;
@property (nonatomic,copy) NSString* truck;
@property (nonatomic,assign) NSString* lat;
@property (nonatomic,assign) NSString* longi;
@property (nonatomic,assign) NSString* placemark;
@property (nonatomic,copy) NSString* entryBy;
@property (nonatomic,copy) NSString* port;
@property (nonatomic,copy) NSString* eseal;

@property (nonatomic,assign) UITextField *dateTf;
@property (nonatomic,assign) UITextField *entryTf;
@property (nonatomic,assign) UITextField *billTf;
@property (nonatomic,assign) UITextField *truckTf;
@property (nonatomic,assign) UITextField *portTf;
@property (nonatomic,assign) UITextField *esealTf;
@property (nonatomic,assign) UITextField *containerTf;

@property (nonatomic,assign) CLLocationManager *locationManager;
@property(nonatomic) CLLocationDegrees laD;
@property(nonatomic) CLLocationDegrees loD;

@property (nonatomic, assign) NSString *tagIdStr;

@property (nonatomic, strong) UIView *containerVu;
@property (nonatomic, strong) UIView *loadingView;


@end
