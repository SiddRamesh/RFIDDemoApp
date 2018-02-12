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

#import "ReportData.h"

#import "InventoryItem.h"

#import "CNPPopupController.h"
#import "PulsingHaloLayer.h"

#import "pulSVu.h"

#define ZT_INVENTORY_TIMER_INTERVAL          0.2

#define kMaxRadius 200
#define kMaxDuration 10


@import MapKit;

@interface ScanVC () <CNPPopupControllerDelegate>

@property (nonatomic, assign) PulsingHaloLayer *halo;
@property (nonatomic, assign)  UIImageView *beaconView;
@property (nonatomic, assign)  UIView *uiView;

@property (nonatomic, strong) CNPPopupController *popupController;

@property (nonatomic, strong) ReportData *reportdat;
@property (nonatomic, strong) NSMutableArray *reportDatas;

@property (nonatomic, strong) NSOperationQueue *que;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableURLRequest *theRequest;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSString *captureString;
@property (nonatomic, assign) BOOL *flag;



@property (nonatomic, strong) StockDataSource *stockDataSource;
@property (assign) id localChangedObserver;
@property (nonatomic, strong) UIAlertController *alert;

@property (nonatomic,copy) NSString *serialLbl;
@property (nonatomic,copy) NSString *iecLbl;
@property (nonatomic,copy) NSString *billLbl;
@property (nonatomic,copy) NSString *truckLbl;
@property (nonatomic,copy) NSString *codebl;
@property (nonatomic,copy) NSString *portLbl;
@property (nonatomic,copy) NSString *dateLbl;
@property (nonatomic,copy) NSString *timeLbl;
@property (nonatomic,copy) NSString *enteryByLbl;
@property (nonatomic,copy) NSString *esealLbl;
@property (retain, nonatomic) IBOutlet UITableViewCell *serialCellView;

@property (nonatomic, assign) NSString *tagIdStr;

//@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel *Serial;
@property (retain, nonatomic) IBOutlet UILabel *iec;
@property (retain, nonatomic) IBOutlet UILabel *eseal;
@property (retain, nonatomic) IBOutlet UILabel *truck;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *port;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *bill;
@property (retain, nonatomic) IBOutlet UILabel *shipDate;
@property (retain, nonatomic) IBOutlet UILabel *container;

@property(nonatomic, retain) UILabel *tag;
//@property(nonatomic, retain) UILabel *port;

    @property NSString *soapMessage;
    @property NSString *currentElement;
    @property NSString *ele1;
    @property NSMutableData *webResponseData;

   // @property UILabel *tag;
  //  @property UILabel *port;
    @property UILabel *resultLbl;

@end

@implementation ScanVC

@synthesize m_tblTags;
@synthesize soapMessage, tag, port, webResponseData, currentElement;

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
         _flag = false;
        _reportdat = [ReportData new];
      //  _reportDatas = [[NSArray alloc] initWithObjects:_reportdat, nil];
        _reportDatas =  [NSMutableArray array]; //[[NSMutableArray alloc] arrayByAddingObject:_reportdat];
        
        m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
        m_Tags = [NSMutableArray new];
        m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
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
  //  [_code release];
    [_bill release];
    [_serialCellView release];
    [m_tblTags release];
    [_tagIdStr release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup the Scan button
 //   UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanDataWithTag:nPort:)];
//    self.navigationItem.rightBarButtonItem = barButtonScan;
    
    [m_tblTags setDelegate:self];
    [m_tblTags setDataSource:self];
    [m_tblTags registerClass:[zt_RFIDTagCellView class] forCellReuseIdentifier:ZT_CELL_ID_TAG_DATA];
    
    [self showPopupWithStyle:CNPPopupStyleFullscreen];
    
    flag = false;
    
     [self scanDataWithTag:@"862425120607AAA000000021" nPort:@"INNSA1"]; // New
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [m_tblTags release];
    [_tagIdStr release];
    [super viewWillDisappear:YES];
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
    
    [m_tblTags release];
    [_tagIdStr release];
    
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
    
    [tag_cell setTagData:tag_data.getTagId];
 //   [tag_cell setTagCount:[NSString stringWithFormat:@"%d", tag_data.getCount]];

}

//MARK: - Main
- (IBAction)btnStartStopPressed:(id)sender
{
    if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
    {
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
        }
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:m_SelectedInventoryOption message:&status];
     //   [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"];
    //    NSLog(@"%@ This tagID is to be Scan..",_tagIdStr);
        if ([status isEqualToString:@"Inventory Started in Batch Mode"]) {
            NSLog(@"%@ btn Tag is",m_Tags);
            [m_Tags removeAllObjects];
            [m_tblTags reloadData];
        //    NSLog(@"%@ btn table",tableView);
        }
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
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

-(void)scanDataWithTag:(NSString *)tag nPort:(NSString *)port {
    
    //first create the soap envelope
    self.soapMessage = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetAssignTag1 xmlns='http://tempuri.org/'>                                                                                                                                                                                                  <Tag>%@</Tag>                                                                                                                                                                                                                            <port>%@</port>                                                                                                                                                                                                                                     </GetAssignTag1>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>", tag, port];
   
    NSLog(@"%@ tag n %@ port",tag,port);
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://atm-india.in/RFIDDemoservice.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //ad required headers to the request
    [theRequest initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    
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
                                                                   [self setData];
                                                                   
                                                               } else {
                                                                   NSString *errorString =
                                                                   NSLocalizedString(@"HTTP Error", @"Error message displayed when receiving an error from the server.");
                                                                 //  NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                                                                   [self showPopupWithTagStatus:@"cancel" found:errorString];
                                                               } //else ...
                                                           }
                                                       }];
                                                   }];
    [self.dataTask resume];
}
    
    
//
//    //initiate the request
//    NSURLConnection *connection =
//    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:true];
//
//    if(connection)
//    {
//        self.webResponseData = [NSMutableData data];
//
//    }
//    else
//    {
//        NSLog(@"Connection is NULL");
//    }
//    [connection start];
//
//    //TODO: - Session Management
////    NSURLSession *soapSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
////                                                                      delegate:self delegateQueue:[NSOperationQueue mainQueue]];
////    NSURLSessionDataTask *dataTask = [soapSession dataTaskWithURL: url];
////    self.webResponseData = [NSMutableData new];
////    [dataTask resume];
//
//}

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
/*
//MARK: - Connection Delegate Methods.
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Some error in your Connection. Please try again.");
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.webResponseData = [NSMutableData new];
    [self.webResponseData  setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
//    if (data != nil) {
//        [self showPopupWithTagStatus:@"complete" found:@"Not Tampered"];
//    } else
//        [self showPopupWithTagStatus:@"complete" found:@"Tampered"];
    
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
 //   [self.popupController dismissPopupControllerAnimated:YES];
}
*/

//MARK: - NSXMlParser Delegate Methods
-(void) parserDidStartDocument:(NSXMLParser *)parser {
    
    _flag = false;
    _captureString = @"";
    _reportDatas = [NSMutableArray new];
}


-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
 //  NSLog(@"%@ Element -> ",elementName);
 //   self.ele1 = elementName;
    
    flag = false;
    _captureString = @"";
    
    if ([elementName isEqualToString:@"ReportData"]) { _reportdat = [[ReportData alloc] init]; }
    else if ([elementName isEqualToString:@"S1"] || [elementName isEqualToString:@"S2"] || [elementName isEqualToString:@"S3"] || [elementName isEqualToString:@"S4"]
             || [elementName isEqualToString:@"S5"] || [elementName isEqualToString:@"S6"] || [elementName isEqualToString:@"S7"] || [elementName isEqualToString:@"S8"] || [elementName isEqualToString:@"S9"] || [elementName isEqualToString:@"S10"])
             
        //|| [elementName isEqualToString:@"S10"] || [elementName isEqualToString:@"S11"] ||
         //    [elementName isEqualToString:@"12"] || [elementName isEqualToString:@"13"])
    { flag = true; }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if (flag) {_captureString = [_captureString stringByAppendingString:string]; }
    
    
    [self.popupController dismissPopupControllerAnimated:YES];///working..
/*
  //  if (self.popupController != nil) {
    
        [self showPopupWithTagStatus:@"complete" found:@"Not Tampered"]; //Working
    //    flag = true;
    if ([_ele1 isEqualToString:@"S2"]) { self.iec.text = [@" IEC No. : " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S3"]) { self.bill.text = [@" Bill No. :  " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S7"]) {  self.date.text =  [@" Date :  " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S10"]){  self.eseal.text =  [@" E-Seal :  " stringByAppendingString:string]; }
    // Sealing Date
        if ([_ele1 isEqualToString:@"S8"]) {  self.time.text =  [@" Time :  " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S6"]) {  self.port.text =  [@" Dest. Port :  " stringByAppendingString:string]; }
    // Container No.
        if ([_ele1 isEqualToString:@"S4"]) {  self.truck.text =  [@" Truck No :  " stringByAppendingString:string]; }
    // lat, long, IMEI..
        if ([_ele1 isEqualToString:@"S1"]) { self.Serial.text = [@" Serial No. :  " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S5"]) {  self.code.text =  [@" Code No. :  " stringByAppendingString:string]; }
        if ([_ele1 isEqualToString:@"S9"]) {  self.enteryByLbl =  [@" Entry By :  " stringByAppendingString:string]; }
 //   }
  //   NSLog(@"%@ PData ->: ",string);
 */
    NSLog(@"%@ PData ->: ",string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    flag = false;
    
    if ([elementName isEqualToString:@"S1"]) { _reportdat.S1 = _captureString; }
    else if ([elementName isEqualToString:@"S2"]) { _reportdat.S2 = _captureString; }
    else if ([elementName isEqualToString:@"S3"]) { _reportdat.S3 = _captureString; }
    else if ([elementName isEqualToString:@"S4"]) { _reportdat.S4 = _captureString; }
    else if ([elementName isEqualToString:@"S5"]) { _reportdat.S5 = _captureString; }
    else if ([elementName isEqualToString:@"S6"]) { _reportdat.S6 = _captureString; }
    else if ([elementName isEqualToString:@"S7"]) { _reportdat.S7 = _captureString; }
    else if ([elementName isEqualToString:@"S8"]) { _reportdat.S8 = _captureString; }
    else if ([elementName isEqualToString:@"S9"]) { _reportdat.S9 = _captureString; }
    else if ([elementName isEqualToString:@"S10"]) { _reportdat.S10 = _captureString; }
//    else if ([elementName isEqualToString:@"S11"]) { _reportdat.S1 = _captureString; }
 //   else if ([elementName isEqualToString:@"S12"]) { _reportdat.S1 = _captureString; }
 //   else if ([elementName isEqualToString:@"S13"]) { _reportdat.S1 = _captureString; }
    else if ([elementName isEqualToString:@"ReportData"]) { [_reportDatas addObject:_reportdat];} // arrayByAddingObject:_reportdat]; } //addObject:_reportdat];}
    
 /*
    NSLog(@"Parsed Element : %@", currentElement);
    if (flag == false) {
        
      //  [self showPopupWithTagStatus:@"cancel" found:@"Tampered"];
    }
    
    */
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {

    if (_reportDatas == nil) {
        NSLog(@"No Data Found");
        [self showPopupWithTagStatus:@"cancel" found:@"Tampered"];
    }
}


-(void)setData {
    
   // ReportData *repo = (_reportDatas)[indexPath.row];
    
    self.Serial.text = [@" Serial No. : " stringByAppendingString:_reportdat.S1];
    self.iec.text = [@" IEC No. : " stringByAppendingString:_reportdat.S2];
    self.bill.text = [@" Bill No. : " stringByAppendingString:_reportdat.S3];
    self.truck.text = [@" Truck No. : " stringByAppendingString:_reportdat.S4];
    self.eseal.text = [@" e-Seal No. : " stringByAppendingString:_reportdat.S5];
    self.port.text = [@" Dest. Port : " stringByAppendingString:_reportdat.S6];
    self.shipDate.text = [@" Sealing Date : " stringByAppendingString:_reportdat.S7];
    self.time.text = [@" Sealing Time : " stringByAppendingString:_reportdat.S8];
    self.date.text = [@" Bill date : " stringByAppendingString:_reportdat.S9];
    self.container.text = [@" Container No. : " stringByAppendingString:_reportdat.S10];
    
    //     self.iec.text = [@" IEC No. : " stringByAppendingString:repo.S11];
    //    self.iec.text = [@" IEC No. : " stringByAppendingString:repo.S12];
    //    self.iec.text = [@" IEC No. : " stringByAppendingString:repo.S13];
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

//MARK: - NSURLSessionTask Delegate Methods
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
//{
//    //handle data here
//    [self.webResponseData appendData:data];
//}
//
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
//{
//    if (error) {
//        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
//    }else{
//        NSLog(@"DONE. Received Bytes: %lu", (unsigned long)[self.webResponseData length]);
//        NSString *theXML = [[NSString alloc] initWithBytes:[self.webResponseData bytes] length:[self.webResponseData length] encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",theXML);
//    }
//}

//MARK: - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [m_Tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *kAttributeCellID = ZT_CELL_ID_TAG_DATA;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributeCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kAttributeCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:[indexPath row]];
    _tagIdStr = tag_data.getTagId;
    NSLog(@"%@ This TID isto be Scan..",_tagIdStr);
    cell.textLabel.text =  [@"TID : " stringByAppendingString:_tagIdStr];
 //   [self scanDataWithTag:_tagIdStr nPort:@"INNSA1"]; // All working...
   
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.Serial.layer.borderWidth = 2.0; self.Serial.layer.cornerRadius = 5; self.Serial.layer.masksToBounds = true;
    self.iec.layer.borderWidth = 2.0; self.iec.layer.cornerRadius = 5; self.iec.layer.masksToBounds = true;
    self.bill.layer.borderWidth = 2.0; self.bill.layer.cornerRadius = 5; self.bill.layer.masksToBounds = true;
    self.truck.layer.borderWidth = 2.0; self.truck.layer.cornerRadius = 5; self.truck.layer.masksToBounds = true;
    self.container.layer.borderWidth = 2.0; self.container.layer.cornerRadius = 5; self.container.layer.masksToBounds = true;
    self.port.layer.borderWidth = 2.0; self.port.layer.cornerRadius = 5; self.port.layer.masksToBounds = true;
    self.time.layer.borderWidth = 2.0; self.time.layer.cornerRadius = 5; self.time.layer.masksToBounds = true;
    self.date.layer.borderWidth = 2.0; self.date.layer.cornerRadius = 5; self.date.layer.masksToBounds = true;
    self.eseal.layer.borderWidth = 2.0; self.eseal.layer.cornerRadius = 5; self.eseal.layer.masksToBounds = true;
    self.shipDate.layer.borderWidth = 2.0; self.shipDate.layer.cornerRadius = 5; self.shipDate.layer.masksToBounds = true;
}


//MARK: - PopUp Controller
#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.halo.position = self.beaconView.center;
}


- (void)showPopupWithStyle:(CNPPopupStyle)popupStyle {
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Scan the Tag!" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"or its" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Tampered!" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:1.46 green:0.8 blue:0.8 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"Close Me" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    
    UIView *vu = (pulSVu *) [[[NSBundle mainBundle] loadNibNamed:@"pulSVu" owner:self options:nil] lastObject];
    vu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    vu.backgroundColor = [UIColor whiteColor];
    
    UIImageView *pulseImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 100.0)];
    //   self.beaconView.contentMode = UIViewContentModeScaleAspectFit;
    pulseImg.center = CGPointMake(150, 150);
    pulseImg.image = [UIImage imageNamed:@"IPhone_5s"];
    [vu addSubview:pulseImg];
    
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    [pulseImg.layer addSublayer:layer];
    [pulseImg.superview.layer insertSublayer:layer below:pulseImg.layer];
    layer.position = pulseImg.center;
    
    // Customization...
    layer.pulseInterval = 1;
    layer.haloLayerNumber = 5;
    layer.radius = kMaxRadius;
    layer.animationDuration = kMaxDuration;
    UIColor *pulCol = [[UIColor alloc] initWithRed:0 green:0.45 blue:0.75 alpha:0.8];
    layer.backgroundColor = pulCol.CGColor;
    [layer start];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.attributedText = title;
    
    UILabel *lineOneLabel = [[UILabel alloc] init];
    lineOneLabel.numberOfLines = 0;
    lineOneLabel.attributedText = lineOne;
    
    UILabel *lineTwoLabel = [[UILabel alloc] init];
    lineTwoLabel.numberOfLines = 0;
    lineTwoLabel.attributedText = lineTwo;

    
    UIColor *col = [UIColor blueColor];
    [self.halo setBackgroundColor:col.CGColor];
    self.halo.radius = kMaxRadius;
    self.halo.animationDuration = kMaxDuration;
    [self.halo start];
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, vu,lineOneLabel ,lineTwoLabel,button]]; // lineOneLabel ,lineTwoLabel
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}


-(IBAction)resetData:(id)sender {
    
    _tagIdStr = @" ";
    self.Serial.text = @" Serial No. :  ";
    self.iec.text = @" IEC : ";
    self.bill.text = @" Bill No. :  ";
    self.truck.text = @" Truck No. :  ";
    self.container.text = @" Container No. :  ";
    self.port.text = @" Dest. Port :  ";
    self.time.text = @" Time :  ";
    self.date.text = @" Date :  ";
    self.eseal.text = @" E-Seal :  ";
    self.shipDate.text = @" Shipping Date :  ";
    [m_Tags removeAllObjects];
 //   [m_tblTags reloadData];
    
    //   [self showPopupWithStyle:CNPPopupStyleCentered];
    [self showPopupWithStyle:CNPPopupStyleActionSheet];
}


@end
