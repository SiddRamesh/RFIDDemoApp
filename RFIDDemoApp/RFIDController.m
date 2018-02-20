//
//  RFIDController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/17/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "RFIDController.h"
#import "config.h"
#import "ui_config.h"
#import "InventoryItem.h"

#import "CNPPopupController.h"
#import "PulsingHaloLayer.h"
#import "pulSVu.h"

#define ZT_INVENTORY_TIMER_INTERVAL          0.2

@interface RFIDController () <CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

@property (nonatomic, assign) PulsingHaloLayer *halo;
@property (nonatomic, assign)  UIImageView *beaconView;
@property (nonatomic, assign)  UIView *uiView;


@property (nonatomic, assign) NSString *tagIdStr;

@end

@implementation RFIDController

//MARK: - Delegate
-(void) searchForTags:(NSString *)tag :(id<TagSearchDelegate>)delegate {
    
    assert([NSThread isMainThread]);
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
    [self showPopupWithStyle:CNPPopupStyleCentered];     //session
 //   [self btnStartStopPressed:(id<TagSearchDelegate>)delegate];
    NSError* error = nil;
        if (error) {
            if(delegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate retrievedTagsFromSearch:_tagIdStr :error];
                    NSLog(@"%@ GOT",_tagIdStr);
                });
            }
        }
    }];
}

//MARK: Init
//- (id)init
//{
//    self = [super init];
//    if (self != nil)
//    {
//        m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
//        m_Tags = [NSMutableArray new];
//        m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
//    }
//    return self;
//}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
        m_Tags = [NSMutableArray new];
        m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
    }
    return self;
}

-(void)dealloc{
    
//    [self reset];
    [m_tblTags release];
    [m_Tags removeAllObjects];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [m_tblTags setDelegate:self];
    [m_tblTags setDataSource:self];
  //  _tagIdStr = @" ";
  //  [self showPopupWithStyle:CNPPopupStyleActionSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: - SDK
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
  //  [self reset];
    [m_Tags removeAllObjects];
    [m_tblTags release];
  //  [_tagIdStr release];
    
    /* stop timer */ //new
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
}

//MARK: - Radio Operation
- (BOOL)onNewTriggerEvent:(BOOL)pressed
{
    __block RFIDController*__weak_self = self;
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
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    return YES;
}


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
        }
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
    }
}

- (void)updateOperationDataUI
{
    /* unique tags */
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [m_Tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kAttributeCellID = ZT_CELL_ID_TAG_DATA;
    
    zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:indexPath.row];
    _tagIdStr = tag_data.getTagId;
    NSLog(@"%@",_tagIdStr);
    [self performSelectorOnMainThread:@selector(searchForTags::) withObject:_tagIdStr waitUntilDone:NO];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAttributeCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAttributeCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text =  _tagIdStr;
    return cell;
}

//MARK: - PopUp Delegate

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
    NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"scanning..." attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
    NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"_tagIdStr" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:1.46 green:0.8 blue:0.8 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
    
    CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 4;
    button.selectionHandler = ^(CNPPopupButton *button){
        [self.popupController dismissPopupControllerAnimated:YES];
        NSLog(@"Block for button: %@", button.titleLabel.text);
    };
    
    UIView *vu = (pulSVu *) [[[NSBundle mainBundle] loadNibNamed:@"pulSVu" owner:self options:nil] lastObject];
    vu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    vu.backgroundColor = [UIColor whiteColor];
    
    UIImageView *pulseImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 100.0)];
    pulseImg.contentMode = UIViewContentModeScaleAspectFit;
    pulseImg.center = CGPointMake(200, 200);
    pulseImg.image = [UIImage imageNamed:@"IPhone_5s"];
    [vu addSubview:pulseImg];   // [vu addSubview:m_tblTags];
    
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    [pulseImg.layer addSublayer:layer];
    [pulseImg.superview.layer insertSublayer:layer below:pulseImg.layer];
    layer.position = pulseImg.center;
    
    // Customization...
    layer.pulseInterval = 1;
    layer.haloLayerNumber = 5;
    layer.radius = 250;
    layer.animationDuration = 10;
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
    self.halo.radius = 250;
    self.halo.animationDuration = 10;
    [self.halo start];

    //Init + [self view] working
    self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel,vu, button]]; // lineOneLabel ,lineTwoLabel
    self.popupController.theme = [CNPPopupTheme defaultTheme];
    self.popupController.theme.popupStyle = popupStyle;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}


@end
