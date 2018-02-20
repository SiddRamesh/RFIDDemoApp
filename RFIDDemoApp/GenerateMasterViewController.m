//
//  GenerateMasterViewController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/3/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "GenerateMasterViewController.h"
#import "AlertView.h"
#import "RFIDController.h"
#import "CNPPopupController.h"

@interface GenerateMasterViewController () <NSXMLParserDelegate, TagSearchDelegate, CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;


@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableURLRequest *theRequest;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic,copy) NSString *soapMessage;

@end

@implementation GenerateMasterViewController


+ (NSString *)stringFromDate {
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSString *da = [dateFormatter stringFromDate:[NSDate date]];
    return da;
}

+ (NSString *)stringFromTime {
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
  //  [dateFormatter setDateFormat:@"hh:mm:ss"];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *tim = [dateFormatter stringFromDate:[NSDate date]];
    return tim;
}


-(void)showActivityView:(UIView *)view {
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    self.containerVu = [[UIView alloc] init];
    self.loadingView = [[UIView alloc] init];
    
    [self.containerVu setFrame:view.frame];
    [self.containerVu setCenter:view.center];
    [self.containerVu setBackgroundColor:[UIColor clearColor]];
    
    self.loadingView.frame = CGRectMake(0, 0, 80.0, 80.0);
    [self.loadingView setCenter:view.center];
    [self.loadingView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
    self.loadingView.clipsToBounds = true;
    self.loadingView.layer.cornerRadius = 10;
    
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicatorView.hidesWhenStopped = true;
    self.activityIndicatorView.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2, 80.0, 80.0);
    self.activityIndicatorView.center = self.view.center;
    
    [self.loadingView addSubview:self.activityIndicatorView];
    [self.containerVu addSubview:self.loadingView];
    [view addSubview:self.containerVu];
    [view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView bringSubviewToFront:view];
    [self.activityIndicatorView startAnimating];
    
}

-(void)hideActivityView{
    [self.activityIndicatorView stopAnimating];
    [self.containerVu removeFromSuperview];
}

#pragma mark - TickerSearch delegate

-(void) retrievedTagsFromSearch:(NSString *)tags :(NSError*) error {
    if(error) {
        NSLog(@"Error %@", error);
//        NSString *reason = [error localizedDescription];
//        
//        UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:reason
//                                                        message:nil
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
    } else {
      //  [array removeAllObjects];
       
       NSString *fetchTag = [[NSString alloc] initWithString:tags];
       self.tagIdStr = fetchTag;
        NSLog(@"%@", @"Scanned Tag!");
        //  [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self locationSet];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self hideKeyboardWhenTappedAround];
    [self initDatePicker];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:@"Save"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(saveData:)];
                                                         //  action:@selector(retrievedTagsFromSearch::)];
    self.navigationItem.rightBarButtonItem = save;
    
}

-(IBAction)saveData:(id)sender {
    
 //   [self showActivityView:self.view];
    self.soapMessage = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                                                                  <soap:Body>                                                                                                                                                                                                        <InsertEntryMaster xmlns='http://tempuri.org/'>                                                                                                                                                                                                     <billno>%@</billno>                                                                                                                                                                                                                          <date>%@</date>                                                                                                                                                                                                                                                  <time>%@</time>                                                                                                                                                                                                                                         <container>%@</container>                                                                                                                                                                                                                     <truck>%@</truck>                                                                                                                                                                                                                                                  <latitude>%@</latitude>                                                                                                                                                                                                                                            <longitude>%@</longitude>                                                                                                                                                                                                                                         <eseal>%@</eseal>                                                                                                                                                                                                                                                                             <entryby>%@</entryby>                                                                                                                                                                                                                                                  <port>%@</port>                                                                                                                                                                                                                                                   </InsertEntryMaster>                                                                                                                                                                                                                           </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>",self.bill,self.date,self.timee,self.container,self.truck,self,_lat,self.longi,self.eseal,self.entryBy]; // self.port
    
//    NSLog(@"%@ tag n %@ port",tag,port);
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://atm-india.in/RFIDDemoservice.asmx"];
  //  NSURL *url = [NSURL URLWithString:@"http://atm-india.in/EnopeckService.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[_soapMessage length]];
    
    //ad required headers to the request
    [theRequest initWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [_soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    _dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:theRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                        if (error != nil && response == nil) {
                                                            if (error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
                                                                
                                                                NSAssert(NO, @"NSURLErrorAppTransportSecurityRequiresSecureConnection");
                                                            }
                                                            else {
                                                                // use KVO to notify our client of this error
                                                            }
                                                        }
                                                        if (response != nil) {
                                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                            if (((httpResponse.statusCode/100) == 2) && [response.MIMEType isEqual:@"text/xml"]) {
                                                                NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
                                                                parser.delegate = self;
                                                                [parser parse];
                                                           //   [self hideActivityView];
                                                            } else {
                                                                NSString *errorString =
                                                                NSLocalizedString(@"HTTP Error", @"Error message displayed when receiving an error from the server.");
                                                                //  NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                                                                [self showPopupWithTagStatus:@"cancel" found:errorString];
                                                                //  abort();
                                                            } //else ...
                                                        }
                                                    }];
                                                }];
    NSLog(@"Loading... %@",theRequest);
    [self.dataTask resume];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([string isEqualToString:@"true"]) {
        NSLog(@"Saved");
         [self showPopupWithTagStatus:@"complete" found:@"Success"];
        
    } else {
        NSLog(@"Not Saved");
         [self showPopupWithTagStatus:@"cancel" found:@"Failed!"];
    }
}

- (void)showPopupWithTagStatus:(NSString *)imageName found:(NSString *)string {
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel,imageView]];
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

-(IBAction)scanTag:(id)sender {
    
    RFIDController *rf = [[RFIDController alloc] init];
    
    [rf searchForTags:_tagIdStr :sender];
    
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
    
     return NSLocalizedString(@"            ", @"Information");
    
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
                cell.detailTextLabel.text =  self.tagIdStr;
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
            //    cell.detailTextLabel.text = _dateTf.text;
                tf = _dateTf = [self makeTextField:self.date placeholder:[GenerateMasterViewController stringFromDate]];
                [cell addSubview:_dateTf];
            } break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Time :", @"Time:");
                cell.detailTextLabel.text = [GenerateMasterViewController stringFromTime];
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Latitude :", @"Latitude");
                cell.detailTextLabel.text = self.lat;
            } break;
            case 2: {
                cell.textLabel.text = NSLocalizedString(@"Longitude :", @"Longitude");
                cell.detailTextLabel.text = self.longi;
            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Area :",@"Area");
                cell.detailTextLabel.text = self.placemark;
            } break;
        }
    }
    return cell;
}

//MARK: - Init UI Elements
-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder  {
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
    tf.placeholder = placeholder ;
    tf.text = text ;
    tf.returnKeyType = UIReturnKeyNext;
    tf.clearsOnBeginEditing = YES;
    // tf.tag = 1;
    // tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.delegate = self;
    //   [cell.contentView addSubview:tf];
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    
    [tf addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    return tf ;
}

-(void)initDatePicker {
    
    UIDatePicker *pic = [UIDatePicker new];
    pic.datePickerMode = UIDatePickerModeDate;
    _dateTf.inputView = pic;
    [pic addTarget:self action:@selector(dateValueChaned:) forControlEvents:UIControlEventValueChanged];
}

-(void)dateValueChaned:(UIDatePicker *)picker {
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    _dateTf.text = [dateFormatter stringFromDate:picker.date];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   
    if ( textField == _dateTf ) {
        UIDatePicker *pic = [UIDatePicker new];
        pic.datePickerMode = UIDatePickerModeDate;
        _dateTf.inputView = pic;
        [pic addTarget:self action:@selector(dateValueChaned:) forControlEvents:UIControlEventValueChanged];
        self.date = textField.text ;
    } else if ( textField == _billTf ) {
        self.bill = textField.text ;
    } else if ( textField == _portTf ) {
        self.port = textField.text ;
    } else if ( textField == _esealTf ) {
        self.eseal = textField.text ;
    } else if ( textField == _truckTf ) {
        self.truck = textField.text ;
    } else if ( textField == _containerTf ) {
        self.container = textField.text ;
    } else if ( textField == _entryTf ) {
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
     [sender resignFirstResponder];
}

-(void)locationSet {
    
    CLLocationManager *locationManager = [CLLocationManager new];
    locationManager.allowsBackgroundLocationUpdates = false; /// for continues update
    [locationManager.delegate  self];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];

    // Here you can check whether you have allowed the permission or not.
    if (CLLocationManager.locationServicesEnabled)
    {
        switch([CLLocationManager authorizationStatus])
        {
            case kCLAuthorizationStatusAuthorizedAlways:
                [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Authorized" withDuration:1];
              //  break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION" withDetails:@"Accessing Location.." withDuration:3];
                 _laD = locationManager.location.coordinate.latitude;
                 _loD = locationManager.location.coordinate.longitude;
                CLLocation *loc  = [[CLLocation alloc] initWithLatitude:_laD longitude:_loD];
                self.lat = [NSString stringWithFormat:@"%f",loc.coordinate.latitude];
                self.longi = [NSString stringWithFormat:@"%f",loc.coordinate.longitude];
                dispatch_async(dispatch_get_main_queue(), ^{
                CLGeocoder *geo = [[CLGeocoder alloc] init];
                [geo reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    if(error){
                        [zt_AlertView showInfoMessage:self.view withHeader:@"LOCATION Error" withDetails:@"Location Not Determined.." withDuration:3];
                    } else {
                  //  NSString *country = placemarks.firstObject.country;
                    NSString *city = placemarks.firstObject.locality;
                 // NSString *postal = placemarks.firstObject.postalCode;
                        self.placemark = city; //[city stringByAppendingString:country];
                    }
                }];
                      });
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
        }
    }
}


@end
