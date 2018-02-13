//
//  VerifyVCViewController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 04/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "VerifyVCViewController.h"
#import "config.h"
#import "ui_config.h"
#import "InventoryItem.h"

#define ZT_INVENTORY_TIMER_INTERVAL          0.2


@interface VerifyVCViewController ()

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

@property (nonatomic, assign) NSString *tagIdStr;

@property (retain, nonatomic) IBOutlet UILabel *Serial;
@property (retain, nonatomic) IBOutlet UILabel *iec;
@property (retain, nonatomic) IBOutlet UILabel *eseal;
@property (retain, nonatomic) IBOutlet UILabel *truck;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *port;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *code;
@property (retain, nonatomic) IBOutlet UILabel *bill;

@property NSString *soapMessage;
@property NSString *currentElement;
@property NSMutableData *webResponseData;

@end

@implementation VerifyVCViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    // Do any additional setup after loading the view.
    
     self.serialLbl = @"";
     self.iecLbl = @"";
     self.billLbl = @"";
     self.truckLbl = @"";
     self.portLbl = @"";
     self.esealLbl = @"";
    
  //  [self scanDataWithTag:@"E200637C90D1D6B16611275A" nPort:@"INNSA1"];
    
    UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanDataWithTag:nPort:)];
    self.navigationItem.rightBarButtonItem = barButtonScan;
    
       [self.tableView registerClass:[zt_RFIDTagCellView class] forCellReuseIdentifier:ZT_CELL_ID_TAG_DATA];
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
                [self.tableView reloadData];
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
    __block VerifyVCViewController *__weak_self = self;
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
        if ([status isEqualToString:@"Inventory Started in Batch Mode"]) {
            NSLog(@"%@ btn Tag is",m_Tags);
            [m_Tags removeAllObjects];
            [self.tableView reloadData];
         //   NSLog(@"%@ btn table",self.tableView);
        }
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
    }
}

-(void)scanDataWithTag:(NSString *)tag nPort:(NSString *)port {
    
 //   tag = @"E200637C90D1D6B16611275A";
 //   port = @"INNSA1";
    
    //first create the soap envelope
    self.soapMessage = [NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?>                                                                                                                                           <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'>                           <soap:Body>                                                                                                                                                                                                  <GetAssignTag1 xmlns='http://tempuri.org/'>                                                                                                                                                                                                  <Tag>%@</Tag>                                                                                                                                                                                                                            <port>%@</port>                                                                                                                                                                                                                                     </GetAssignTag1>                                                                                                                                                                                                                             </soap:Body>                                                                                                                                                                                                                                                                                                                                                                                                                           </soap:Envelope>", tag, port];
    
    NSLog(@"%@ tag n %@ port",tag,port);
    
    //Now create a request to the URL
    NSURL *url = [NSURL URLWithString:@"http://atm-india.in/EnopeckService.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[_soapMessage length]];
    
    //ad required headers to the request
    [theRequest initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [_soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
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
        [self.tableView reloadData];
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
}

//MARK: - NSXMlParser Delegate Methods
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:
(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _currentElement = elementName;
  //  NSLog(@"%@ Element -> ",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   //  dispatch_async(dispatch_get_main_queue(), ^{
        if ([_currentElement isEqualToString:@"S1"]) { self.serialLbl = string;  }
        else if ([_currentElement isEqualToString:@"S2"]) { self.iecLbl = string; }
        else if ([_currentElement isEqualToString:@"S3"]) { self.billLbl = string; }
        else if ([_currentElement isEqualToString:@"S4"]) { self.truckLbl = string; }
        else if ([_currentElement isEqualToString:@"S5"]) { self.codebl =  string; }
        else if ([_currentElement isEqualToString:@"S6"]) { self.portLbl = string; }
        else if ([_currentElement isEqualToString:@"S7"]) { self.dateLbl  = string; }
        else if ([_currentElement isEqualToString:@"S8"]) { self.timeLbl  =  string; }
        else  if ([_currentElement isEqualToString:@"S9"]) { self.enteryByLbl =  string; }
        else if ([_currentElement isEqualToString:@"S10"]){ self.esealLbl = string; }
        
        [zt_AlertView showInfoMessage:self.view withHeader:@"Verfied" withDetails:@"Succesfully" withDuration:2];
  //  });
    
    NSLog(@"%@ <- PData",string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   // NSLog(@"Parsed Element : %@", _currentElement);
}

//MARK: - NSURLSessionTask Delegate Methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //handle data here
    [self.webResponseData appendData:data];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
    }else{
        NSLog(@"DONE. Received Bytes: %lu", (unsigned long)[self.webResponseData length]);
        NSString *theXML = [[NSString alloc] initWithBytes:[self.webResponseData bytes] length:[self.webResponseData length] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",theXML);
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
            [self.tableView reloadData];
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
            self.tableView.hidden = NO;
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
            return 4;
        } break;
        default: {
            return 3;
        } break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return NSLocalizedString(@"Information", @"Information");
        } break;
        case 1: {
            return NSLocalizedString(@"Entry Info", @"Entry Information");
        } break;
        default: {
            return NSLocalizedString(@"Tracking Data", @"Tracking Data");
        } break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kAttributeCellID = @"AttributeCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributeCellID];
    if (cell == nil) {
        cell = [[ UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kAttributeCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Serial No :", @"Serial No :");
                cell.detailTextLabel.text = _serialLbl;
            } break;
            case 1: {
                 cell.textLabel.text = NSLocalizedString(@"IEC :", @"IEC :");
                 cell.detailTextLabel.text = self.iecLbl;
            } break;
            default: {
                 cell.textLabel.text = NSLocalizedString(@"Bill No :", @"Bill No. :");
                 cell.detailTextLabel.text = self.billLbl;
            } break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                 cell.textLabel.text = NSLocalizedString(@"Truck No :", @"Truck No. :");
                 cell.detailTextLabel.text = _truckLbl;
            } break;
            case 1: {
                 cell.textLabel.text = NSLocalizedString(@"Dest. Port :", @"Dest. Port :");
                cell.detailTextLabel.text =  _portLbl;
            }break;
            case 2: {
                cell.textLabel.text = NSLocalizedString(@"Code :", @"Code :");
                cell.detailTextLabel.text =  self.codebl;
            }
        break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"e-Seal :", @"e-Seal :");
                cell.detailTextLabel.text = self.esealLbl;
            } break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = NSLocalizedString(@"Date :", @"Date :");
                cell.detailTextLabel.text =  self.dateLbl;
            } break;
            case 1: {
                cell.textLabel.text = NSLocalizedString(@"Time :", @"Time :");
                cell.detailTextLabel.text = self.timeLbl;
            } break;
            default: {
                cell.textLabel.text = NSLocalizedString(@"Entry On :", @"Entry By :");
                cell.detailTextLabel.text =  self.enteryByLbl;
            } break;
        }
    }
    
    return cell;
}

@end
