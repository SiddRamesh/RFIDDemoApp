//
//  ScanVC.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 1/31/18.
//  Copyright © 2018. All rights reserved.
//

#import "ScanVC.h"
#import "config.h"
#import "ui_config.h"

#import "StockDataSource.h"
#import "StockData.h"
#import "StockCellTableViewCell.h"

#import "InventoryItem.h"

#define ZT_INVENTORY_TIMER_INTERVAL          0.2

@import MapKit;

@interface ScanVC ()

@property (nonatomic, strong) StockDataSource *stockDataSource;
@property (assign) id localChangedObserver;
@property (nonatomic, strong) UIAlertController *alert;

@property (nonatomic, assign) NSString *serialLbl;
@property (nonatomic, assign) NSString *iecLbl;
@property (nonatomic, assign) NSString *billLbl;
@property (nonatomic, assign) NSString *truckLbl;
@property (nonatomic, assign) NSString *codebl;
@property (nonatomic, assign) NSString *portLbl;
@property (nonatomic, assign) NSString *dateLbl;
@property (nonatomic, assign) NSString *timeLbl;
@property (nonatomic, assign) NSString *enteryByLbl;
@property (nonatomic, assign) NSString *esealLbl;

@property (nonatomic, assign) NSString *tagIdStr;

//@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *Serial;
@property (retain, nonatomic) IBOutlet UILabel *iec;
@property (retain, nonatomic) IBOutlet UILabel *eseal;
@property (retain, nonatomic) IBOutlet UILabel *truck;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *port;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *code;
@property (retain, nonatomic) IBOutlet UILabel *bill;

@property(nonatomic, retain) UILabel *tag;
//@property(nonatomic, retain) UILabel *port;

    @property NSString *soapMessage;
    @property NSString *currentElement;
    @property NSString *ele1;
    @property NSMutableData *webResponseData;

   // @property UILabel *tag;
  //  @property UILabel *port;
    @property UILabel *resultLbl;

//    @property NSString *serialLbl;
//    @property NSString *iecLbl;
//    @property NSString *billLbl;
//    @property NSString *truckLbl;
//    @property NSString *codebl;
//    @property NSString *portLbl;
//    @property NSString *dateLbl;
//    @property NSString *timeLbl;
//    @property NSString *enteryByLbl;
//    @property NSString *esealLbl;

@end

@implementation ScanVC

//@synthesize tableView;
//@synthesize serialLbl,iecLbl, billLbl,truckLbl,codebl,portLbl,dateLbl,timeLbl,enteryByLbl,esealLbl; //resultLabel;
@synthesize soapMessage, tag, port, webResponseData, currentElement;

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
        m_Tags = [NSMutableArray new];
        m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
       // [m_btnOptions setTitle:[m_Mapper getStringByEnum:m_SelectedInventoryOption]];
    }
    return self;
}

-(void)dealloc{
    
    [_Serial release];
    [_iec release];
    [_eseal release];
    [_truck release];
    [_date release];
 //   [_port release];
    [_time release];
    [_code release];
    [_bill release];
    [super dealloc];
}

//FIXME: - XML Handler
-(void)loadStockData {
    
    _stockDataSource = [StockDataSource new];
    
    [self.stockDataSource addObserver:self forKeyPath:@"stockdatas" options:0 context:nil];
    
    [self.stockDataSource addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
    
    _localChangedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                    //  [self->_tableView reloadData];
                                                  }];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.stockDataSource startStockdataLookup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //TODO: - Activate
 //    [self loadStockData];                                                    //Load This for Server
    
    // Setup the About button
//    UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanDataWithTag:nPort:)];
    
 //   self.navigationItem.rightBarButtonItem = barButtonScan;
    
    [m_tblTags setDelegate:self];
    [m_tblTags setDataSource:self];
    [m_tblTags registerClass:[zt_RFIDTagCellView class] forCellReuseIdentifier:ZT_CELL_ID_TAG_DATA];
    
 //   [self configureAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];
    
    BOOL is_inventory = (ZT_RADIO_OPERATION_INVENTORY == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    if (NO == is_inventory && ![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_INVENTORY];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        if (YES == requested)
        {
            [m_Tags removeAllObjects];
            [self updateOperationDataUI];
            
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
            if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
            {
                [m_Tags removeAllObjects];
                [m_tblTags reloadData];
            }
        }
        else
        {
            [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_INVENTORY];
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
}

- (BOOL)onNewTriggerEvent:(BOOL)pressed
{
    __block ScanVC *__weak_self = self;
    BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    
    if (YES == pressed)
    {
        /* trigger press -> start operation if start trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerImmediate])
        {
            /* immediate start trigger */
            
            if (NO == requested)
            {
                /* operation is not in progress / requested */
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    else
    {
        /* trigger release -> stop operation if stop trigger immediate */
        
        if (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerImmediate])
        {
            /* immediate stop trigger */
            
            if (YES == requested)
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                 //  [__weak_self scanData:nil];
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    return YES;
}

- (void)configureTagCell:(zt_RFIDTagCellView*)tag_cell forRow:(int)row isExpanded:(BOOL)expanded
{
    /* TBD */
    zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:row];
    _tagIdStr = tag_data.getTagId;
    NSLog(@"%@ Feteched tag ID",tag_data.getTagId);
    [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"];
    NSLog(@"%@ This tagID is to be Scan..",_tagIdStr);
    
  //  [tag_cell setTagData:tag_data.getTagId];
 //   [tag_cell setTagCount:[NSString stringWithFormat:@"%d", tag_data.getCount]];
}

//MARK: - Main
- (IBAction)btnStartStopPressed:(id)sender
{
 
 //   if (_tagIdStr != NULL) {
    
//    } else {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Unable To Process.. " delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
 
    //  [self getTag];
 //   NSString *statusMsg;
    if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
    {
      //  [self showWarning:@"Getting batched tags: operation not allowed"];
     //   [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"];
     //   NSLog(@"%@ This tagID is to be Scan..",_tagIdStr);
        return;
    }
    BOOL inventory_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    
    if (NO == inventory_requested)
    {
        if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES])
        {
            rfid_res = [[zt_RfidAppEngine sharedAppEngine] purgeTags:&status];
          //  [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"];
          //  NSLog(@"%@ This tagID is to be Scan..",_tagIdStr);
        }
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:m_SelectedInventoryOption message:&status];
    //    [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"];
    //    NSLog(@"%@ This tagID is to be Scan..",_tagIdStr);
        if ([status isEqualToString:@"Inventory Started in Batch Mode"]) {
            NSLog(@"%@ btn Tag is",m_Tags);
            [m_Tags removeAllObjects];
            [m_tblTags reloadData];
            NSLog(@"%@ btn table",m_tblTags);
        }
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
    }
}

-(void)scanDataWithTag:(NSString *)tag nPort:(NSString *)port {
    
    // tag = @"E200637C90D1D6B16611275A";
    // port = @"INNSA1";
    
    //first create the soap envelope
    self.soapMessage = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetAssignTag1 xmlns='http://tempuri.org/'>                                                                                                                                                                                                  <Tag>%@</Tag>                                                                                                                                                                                                                            <port>%@</port>                                                                                                                                                                                                                                     </GetAssignTag1>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>", tag, port];
   
    NSLog(@"%@ tag n %@ port",tag,port);
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://atm-india.in/RFIDDemoservice.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //ad required headers to the request
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initiate the request
    NSURLConnection *connection =
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:true];
    
    if(connection)
    {
        self.webResponseData = [NSMutableData data];
    }
    else
    {
        NSLog(@"Connection is NULL");
    }
    [connection start];
    
    //TODO: - Session Management
//    NSURLSession *soapSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
//                                                                      delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    NSURLSessionDataTask *dataTask = [soapSession dataTaskWithURL: url];
//    self.webResponseData = [NSMutableData new];
//    [dataTask resume];
    
}

- (void)updateOperationDataUI
{
    /* unique tags */
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
    int tag_count = (int)[zt_InventoryData getUniqueCount:_tags];
  //  [self setLabelTextToFit:[NSString stringWithFormat:@"%d", tag_count] forLabel:m_lblUniqueTagsData withMaxFontSize:19.0];
    
    /* total tags */
    int totalTagCount = [zt_InventoryData getTotalCount:_tags];
 //   [self setLabelTextToFit:[NSString stringWithFormat:@"%d", totalTagCount] forLabel:m_lblTotalTagsData withMaxFontSize:19.0];
    
    
    if (0 < [[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagSearchCriteria] length])
    {
        /* we have search criteria */
        [_tags release];
        _tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:YES];
    }
    
    [m_Tags removeAllObjects];
    [m_Tags addObjectsFromArray:_tags];
    
    if (nil != _tags)
    {
        [_tags release];
    }
    
    /* tags data */
    if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
      //  batchModeLabel.hidden = YES;
        [m_tblTags reloadData];
    }
}

//MARK: - Connection Delegate Methods.
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Some error in your Connection. Please try again.");
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.webResponseData = [NSMutableData new];
    [self.webResponseData  setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.webResponseData  appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Received %lu Bytes", (unsigned long)[self.webResponseData length]);
    NSString *theXML = [[NSString alloc] initWithBytes:[self.webResponseData mutableBytes] length:[self.webResponseData length] encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",theXML);
    
    NSData *myData = [theXML dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:myData];
    
    //setting delegate of XML parser to self
    xmlParser.delegate = self;
    [xmlParser parse];
    
    //FIXME: - Handle Parsed Object
//    // Run the parser
//    @try{
//        BOOL parsingResult = [xmlParser parse];
//        NSLog(@"%i parsing result",parsingResult);
//    }
//    @catch (NSException* exception)
//    {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Server Error" message:[exception reason] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
    
}

//MARK: - NSXMlParser Delegate Methods
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:
(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
   NSLog(@"%@ Element -> ",elementName);
    self.ele1 = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
 //   if ([currentElement isEqualToString:@"ReportData"]) {
      //  self.sshowAlertMessage(messageTitle: "Fetching Data", withMessage: "Failed!")
       //  self.resultLbl.text = string;
 //   if ([currentElement isEqualToString:@"S1"]) { self.Serial.text = string; }
//    if ([currentElement isEqualToString:@"S2"]) { self.iec.text = string; }
      //  if ([currentElement isEqualToString:@"S3"]) { billLbl = string; }
        
//    } else  {
    
        if ([_ele1 isEqualToString:@"S1"]) { self.Serial.text = string; }
        if ([_ele1 isEqualToString:@"S2"]) { self.iec.text = string; }
        if ([_ele1 isEqualToString:@"S3"]) { self.bill.text = string; }
        if ([_ele1 isEqualToString:@"S4"]) {  self.truck.text =  string; }
        if ([_ele1 isEqualToString:@"S5"]) {  self.code.text =  string; }
        if ([_ele1 isEqualToString:@"S6"]) {  self.port.text =  string; }
        if ([_ele1 isEqualToString:@"S7"]) {  self.date.text =  string; }
        if ([_ele1 isEqualToString:@"S8"]) {  self.time.text =  string; }
        if ([_ele1 isEqualToString:@"S9"]) {  self.enteryByLbl =  string; }
        if ([_ele1 isEqualToString:@"S10"]){  self.eseal.text =  string; }
    
 //   zt_AlertView *alertView = [[zt_AlertView alloc]init];
    
  //  [alertView showSuccessFailureWithText:nil isSuccess:YES aSuccessMessage:@"Verified" aFailureMessage:nil];
    
 //   }
    NSLog(@"%@ PData ->: ",string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"Parsed Element : %@", currentElement);
}

//MARK: - NSURLSessionTask Delegate Methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //handle data here
    [self.webResponseData appendData:data];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //Called when the data transfer is complete
    //Client side errors are indicated with the error parameter
    if (error) {
        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
    }else{
        NSLog(@"DONE. Received Bytes: %lu", (unsigned long)[self.webResponseData length]);
        NSString *theXML = [[NSString alloc] initWithBytes:[self.webResponseData bytes] length:[self.webResponseData length] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",theXML);
    }
}


//MARK: - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
//    switch (section) {
//        case 0: {
//            return 1;
//        } break;
//        case 1: {
//            return 1;
//        } break;
//        default: {
//            return  [m_Tags count];;
//        } break;
//    }
    return [m_Tags count]; //(section == m_Tags.count) ? 3 : 0;
  //  return self.stockDataSource.stockdatas.count;
   // return (section == 0) ? 3: 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return NSLocalizedString(@"Information", @"Information");
        } break;
        case 1: {
            return NSLocalizedString(@"Tracking Data", @"Tracking Data");
        } break;
        default: {
            return NSLocalizedString(@"Entry Info", @"Entry Information");
        } break;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *kAttributeCellID = @"AttributeCellID";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributeCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kAttributeCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
 //      StockData *stockdata = self.stockDataSource.stockdatas[indexPath.row];
//       [cell configureWithStockData:stockdata];

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Serial No", @"Serial No :");
                cell.detailTextLabel.text =  self.serialLbl;    //  stockdata.serial;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"IEC", @"IEC :");
                cell.detailTextLabel.text =  _iecLbl; //stockdata.iec;
            } break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Bill No", @"Bill No. :");
                cell.detailTextLabel.text =   _billLbl; //stockdata.bill;
            } break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Truck No", @"Truck No. :");
                cell.detailTextLabel.text =  [self truckLbl]; // stockdata.truck;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Dest. Port", @"Dest. Port :");
                cell.detailTextLabel.text =  _portLbl; // stockdata.port;
            }break;
//            case 2: {
//                cell.textLabel.text = NSLocalizedString(@"Code", @"Code :");
//                cell.detailTextLabel.text =   stockdata.code;
//            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"e-Seal", @"e-Seal :");
                cell.detailTextLabel.text =  _esealLbl; // stockdata.eseal;
            } break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Date", @"Date :");
                cell.detailTextLabel.text = _dateLbl; // stockdata.datee;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Time", @"Time :");
                cell.detailTextLabel.text =  _timeLbl; // stockdata.time;
            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Entry By", @"Entry By :");
                cell.detailTextLabel.text = _enteryByLbl; // stockdata.entryby;
            } break;
        }
    }
    return cell;
}
*/
//MARK: - Obsever
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    StockDataSource *stockdataSource = object;
    
    if ([keyPath isEqualToString:@"earthquakes"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
          //  [self->_tableView reloadData];
        });
    }
    else if ([keyPath isEqualToString:@"error"])
    {
        /* Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSError *error = stockdataSource.error;
            
            NSString *errorMessage = error.localizedDescription;
            NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
            NSString *okTitle = NSLocalizedString(@"OK", @"OK Title for alert displayed when download or parse error occurs.");
            
            _alert = [UIAlertController alertControllerWithTitle:alertTitle message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
                //..
            }];
            [self.alert addAction:action];
            
            if (self.presentedViewController == nil) {
                [self presentViewController:self.alert animated:YES completion:^ {
                    //..
                }];
            }
        });
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//MARK: - Radio Operation
- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_btnOptions setEnabled:NO];
        
        /* clear selection information */
     //   m_ExpandedCellIdx = -1;
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
        
        /* clear tags only on start of new operation */
        [m_Tags removeAllObjects];
        if(batchModeLabel.hidden)
        {
            [m_Tags removeAllObjects];
            [m_tblTags reloadData];
            batchModeLabel.hidden = NO;
        }
        
        [self updateOperationDataUI];
        
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setTitle:@"START" forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_btnOptions setEnabled:YES];
        
        if(!batchModeLabel.hidden)
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getTags:&statusMsg];
            [self updateOperationDataUI];
            batchModeLabel.hidden=YES;
            m_tblTags.hidden = NO;
        }
        if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress]) //else
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] purgeTags:&statusMsg];
            if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
            {
                [[zt_RfidAppEngine sharedAppEngine] reconnectAfterBatchMode];
            }
        }
        /* update statictics */
        [self updateOperationDataUI];
    }
}

- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == in_progress)
    {
        /* start timer */
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_INVENTORY_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
    }
    else
    {
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        /* update statistics */
        [self updateOperationDataUI];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RFIDTagCellIdentifier = ZT_CELL_ID_TAG_DATA;
    
    zt_RFIDTagCellView *cell = [m_tblTags dequeueReusableCellWithIdentifier:RFIDTagCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[zt_RFIDTagCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RFIDTagCellIdentifier];
    }
    // BOOL expanded = ((m_ExpandedCellIdx == [indexPath row]) ? YES : NO);
    [self configureTagCell:cell forRow:(int)[indexPath row] isExpanded:NO];
 //   tag_cell.textLabel.text = tag_data.getTagId;
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Serial No", @"Serial No :");
                cell.detailTextLabel.text =  self.serialLbl; //@"Serial"; // _serialLbl   //  stockdata.serial;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"IEC", @"IEC :");
                cell.detailTextLabel.text = self.iec.text ;//@"Serial"; // _iecLbl; //stockdata.iec;
            } break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Bill No", @"Bill No. :");
                cell.detailTextLabel.text = self.bill.text ;//@"Serial"; // _billLbl; //stockdata.bill;
            } break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Truck No", @"Truck No. :");
                cell.detailTextLabel.text = @"Serial"; // [self truckLbl]; // stockdata.truck;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Dest. Port", @"Dest. Port :");
                cell.detailTextLabel.text = @"Serial"; // _portLbl; // stockdata.port;
            }break;
                //            case 2: {
                //                cell.textLabel.text = NSLocalizedString(@"Code", @"Code :");
                //                cell.detailTextLabel.text =   stockdata.code;
                //            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"e-Seal", @"e-Seal :");
                cell.detailTextLabel.text = @"Serial"; // _esealLbl; // stockdata.eseal;
            } break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Date", @"Date :");
                cell.detailTextLabel.text = @"Serial"; // _dateLbl; // stockdata.datee;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Time", @"Time :");
                cell.detailTextLabel.text = @"Serial"; // _timeLbl; // stockdata.time;
            }break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Entry By", @"Entry By :");
                cell.detailTextLabel.text = @"Serial"; // _enteryByLbl; // stockdata.entryby;
            } break;
        }
    }
    return cell;
}


@end
