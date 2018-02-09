//
//  GenerateMasterViewController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/3/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "GenerateMasterViewController.h"
#import "AlertView.h"

@interface GenerateMasterViewController ()

@property (nonatomic,copy) NSString* bill;
@property (nonatomic,copy) NSString* date;
@property (nonatomic,copy) NSString* timee;
@property (nonatomic,copy) NSString* container;
@property (nonatomic,copy) NSString* truck;
@property (nonatomic,copy) NSString* lat ;
@property (nonatomic,copy) NSString* longi;
@property (nonatomic,copy) NSString* entryBy;
@property (nonatomic,copy) NSString* port;
@property (nonatomic,copy) NSString* eseal;

@property(nonatomic) IBOutlet UITextField *dateTf;
@property(nonatomic) UITextField *entryTf;
@property(nonatomic) UITextField *billTf;
@property(nonatomic) UITextField *truckTf;
@property(nonatomic) UITextField *portTf;
@property(nonatomic) UITextField *esealTf;
@property(nonatomic) UITextField *containerTf;

@property(nonatomic) CLLocationManager *locationManager;


@end

@implementation GenerateMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//        UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(scanDataWithTag:nPort:)];
//        self.navigationItem.rightBarButtonItem = barButtonScan;
    
    [self hideKeyboardWhenTappedAround];
    
    [self locationSet];
    
//    CLLocationCoordinate2D coordinate = [self getLocation];
//    _lat = [NSString stringWithFormat:@"%f", coordinate.latitude];
//    _longi = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSLog(@"*dLatitude : %@", _lat);
    NSLog(@"*dLongitude : %@", _longi);
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0: {
            return 3;
        } break;
        case 1: {
            return 3;
        } break;
        default: {
            return 4;
        } break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
     return NSLocalizedString(@"Information", @"Information");
    
//    switch (section) {
//        case 0: {
//            return NSLocalizedString(@"Information", @"Information");
//        } break;
//        case 1: {
//            return NSLocalizedString(@"Entry Info", @"Entry Information");
//        } break;
//        default: {
//            return NSLocalizedString(@"Tracking Data", @"Tracking Data");
//        } break;
//    }
}

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder  {
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    tf.placeholder = placeholder ;
    tf.text = text ;
    tf.returnKeyType = UIReturnKeyNext;
   // tf.tag = 1;
   // tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.delegate = self;
 //   [cell.contentView addSubview:tf];
    tf.autocorrectionType = UITextAutocorrectionTypeNo ;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    
    [tf addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    return tf ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kAttributeCellID = @"AttributeCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributeCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kAttributeCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITextField* tf = nil ;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"E-Seal :", @"e-Seal :");
                cell.detailTextLabel.text =  @"E-Seal";
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Bill No.:", @"Bill No.");
                tf = _billTf = [self makeTextField:self.bill placeholder:@"SB001"];
                [cell addSubview:_billTf];
            } break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Entry By :", @"Entry By :");
                tf = _entryTf = [self makeTextField:self.entryBy placeholder:@"Admin"];
                [cell addSubview:_entryTf];
            } break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Container No. :", @"Container No.");
                tf = _containerTf = [self makeTextField:self.container placeholder:@"56789098765"];
                [cell addSubview:_containerTf];
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Truck No. :", @"Truck No.");
                tf = _truckTf = [self makeTextField:self.truck placeholder:@"MH-02-8765"];
                [cell addSubview:_truckTf];
            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Date :", @"Date");
                tf = _dateTf = [self makeTextField:self.date placeholder:@"02/15/2018"];
                [cell addSubview:_dateTf];
            } break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Time :", @"Time:");
                cell.detailTextLabel.text =  @"12:12:00";
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Latitude :", @"Latitude");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];//  self.lat;
            } break;
            case 2: {
                cell.textLabel.text = NSLocalizedString(@"Longitude :", @"Longitude");
                cell.detailTextLabel.text =  [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Area :",@"Area");
                cell.detailTextLabel.text = @"Area";
            } break;
        }
    }
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ( textField == _billTf ) {
        self.bill = textField.text ;
    } else if ( textField == _portTf ) {
        self.port = textField.text ;
    } else if ( textField == _esealTf ) {
        self.eseal = textField.text ;
    } else if ( textField == _truckTf ) {
        self.truck = textField.text ;
    }
    else if ( textField == _containerTf ) {
        self.container = textField.text ;
    }
    else if ( textField == _entryTf ) {
        self.entryBy = textField.text ;
    }
}
-(void)hideKeyboardWhenTappedAround {
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(dissmissKey)];
    [tap cancelsTouchesInView];
    [self.view addGestureRecognizer:tap];
}

-(void)dissmissKey {
    
    [self.view endEditing:YES];
}

- (IBAction)textFieldFinished:(id)sender {
    // [sender resignFirstResponder];
}


-(void)locationSet {
    
    // Here you can check whether you have allowed the permission or not.
    if (CLLocationManager.locationServicesEnabled)
    {
        switch([CLLocationManager authorizationStatus])
        {
           
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Accessing Location.." withDuration:3];
                
                _locationManager.allowsBackgroundLocationUpdates = false; /// for continues update
                _locationManager.delegate = self;
                [_locationManager requestWhenInUseAuthorization];
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [_locationManager startUpdatingLocation];
                [_locationManager startMonitoringSignificantLocationChanges];
                break;
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"Not Determined");
                [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Not Determined" withDuration:3];
                break;
            case kCLAuthorizationStatusRestricted:
                 NSLog(@"Restricted");
                   [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Restricted" withDuration:3];
                break;
            case kCLAuthorizationStatusDenied:
                 NSLog(@"Denied");
                 [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Location Service is Denied!" withDuration:3];
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                 [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Authorized" withDuration:3];
                break;
           
                
             //   CLGeocoder().
                
          //       CLLocationDegrees  *clldeg = (locationManager.location?.coordinate.latitude)!
          //      let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
        //        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
         //       latitudelbl.text  = latitude.description
          //      longitudelbl.text = longitude.description
                // print("Lat : %f  Long : %f",latitude as Any,longitude as Any) 8650232078 vodone 100
                
//                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
//                    if error != nil {
//                        return
//                    }else if let country = placemarks?.first?.country,
//                        let city = placemarks?.first?.locality,
//                        let pot = placemarks?.first?.postalCode {
//                            print(city + ",",country)
//                            self.locationlbl.text = pot + ", " + city + ", " + country
//                        }
//                    else {
//                    }
//                })
               // break;
        }
    }
}

 /*
-(void)showAlertMessage:(NSString *)messageTitle withMessage:(NSString *)message  {
    UIAlertController *alertController = [UIAlertController new];
    alertController.title = messageTitle;
    alertController.message = message;
    [alertController preferredStyle];
    
    UIAlertAction *alertAct = [UIAlertAction new];
  //  alertAct.title = @"Cancel";
    [alertAct style];
    [alertController setPreferredAction:alertAct];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:Cancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        //..
    }];
    [alertController addAction:alertAct];
    
    
//    UIAlertAction *OKAction = UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction!) in
//        if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/com.company.AppName") {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//    alertController.addAction(OKAction)
//    self.present(alertController, animated: true, completion:nil)
//
    UIAlertAction *OkAaction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        //..
        NSURL *url = [[NSURL init] initWithString:@"App-Prefs:root=Privacy&path=LOCATION/com.company.AppName"];
     //   [UIApplication sharedApplication.open(<#const char *#>, <#int, ...#>)]
    }];
    [alert addAction:OkAaction];
    
    if (self.presentedViewController == nil) {
        [self presentViewController:self.alert animated:YES completion:^ {
            //..
        }];
    }
}
*/


-(CLLocationCoordinate2D) getLocation{
    CLLocationManager *locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    return coordinate;
}

+(void)showPopUpWithMessage:(NSString *)message inController:(UIViewController *)controller
{
    
    CGFloat width =  [message sizeWithFont:[UIFont systemFontOfSize:20.0f ]].width;
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, width+10, 40)];
    [alertView setBackgroundColor:[UIColor redColor]];
    
    [alertView setCenter:CGPointMake( controller.view.bounds.size.width / 2, (controller.view.bounds.size.height-40) / 2)];
    
    [alertView.layer setCornerRadius:  5.0f];
    [alertView.layer setBorderWidth: 2.0f];
    [alertView.layer setMasksToBounds: YES];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, width, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [label setFont:[UIFont systemFontOfSize:20.0f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    
    [label setText:message];
    
    [alertView addSubview:label];
    
    [controller.view addSubview:alertView];
    
    [UIView animateWithDuration:5.0
                     animations:^  {alertView.alpha = 0; }
                     completion:^ (BOOL finished) { [alertView removeFromSuperview]; }];
    
    
}


@end
