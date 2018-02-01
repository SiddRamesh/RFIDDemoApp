/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  RapidReadVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RapidReadVC.h"
#import "ui_config.h"
#import "config.h"

#define ZT_RR_TIMER_INTERVAL               0.2

@interface zt_RapidReadVC ()
{
    NSTimer *m_ViewUpdateTimer;
    
    IBOutlet UILabel *m_lblUniqueTagCountBackground;
    IBOutlet UILabel *m_lblUniqueTagCountData;
    IBOutlet UILabel *m_lblTotalTagCountNotice;
    IBOutlet UILabel *m_lblTotalTagCountData;
    IBOutlet UILabel *m_lblReadRateNotice;
    IBOutlet UILabel *m_lblReadRateData;
    IBOutlet UILabel *m_lblReadTimeNotice;
    IBOutlet UILabel *m_lblReadTimeData;
    IBOutlet UIButton *m_btnStartStop;
    
    CGFloat m_fszTotalTags;
    CGFloat m_fszReadTime;
    CGFloat m_fszReadRate;
    CGFloat m_fszUniqueTags;
    int m_TotalTags;
    int m_ReadTime;
    int m_ReadRate;
    int m_UniqueTags;
    UILabel *batchModeLabel;
    
     NSMutableString *m_strTagInput;
}

@end

@implementation zt_RapidReadVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ViewUpdateTimer = nil;
        m_fszReadRate = - 1.0;
        m_fszReadTime = -1.0;
        m_fszTotalTags = - 1.0;
        m_fszUniqueTags = -1.0;
        m_ReadRate = -1;
        m_ReadTime = -1;
        m_TotalTags = -1;
        m_UniqueTags = -1;
    }
    return self;
}

- (void)dealloc
{
    
    [m_lblUniqueTagCountBackground release];
    //[m_lblUniqueTagCountNotice release];
    [m_lblUniqueTagCountData release];
    [m_lblTotalTagCountNotice release];
    [m_lblTotalTagCountData release];
    [m_lblReadRateNotice release];
    [m_lblReadRateData release];
    
    [m_lblReadTimeNotice release];
    [m_lblReadTimeData release];
    [m_btnStartStop release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  [m_strTagInput setDelegate:self];
    
    m_strTagInput = [NSMutableString new];
    
    /* set title */
    [self.tabBarController setTitle:@"Rapid Read"];

    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    CGFloat height = self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height - self.tabBarController.navigationController.navigationBar.bounds.size.height;
    
    CGFloat width = self.view.bounds.size.width;
    
    CGFloat tabbarHeight = self.tabBarController.tabBar.bounds.size.height;
    
    CGFloat marginS = 0.034*width;
    
    /* Inventory in batch mode label */
    batchModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 500, 50)];
    batchModeLabel.hidden = YES;
    batchModeLabel.text = @"Inventory running in Batch Mode";
    [self.view addSubview:batchModeLabel];
    
    
    /* top info bars*/
    
    NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:marginS];
    [self.view addConstraint:c5];
    
    NSLayoutConstraint *c01 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:marginS];
    [self.view addConstraint:c01];
    
    NSLayoutConstraint *c51 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblReadTimeData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-marginS];
    [self.view addConstraint:c51];
    
    NSLayoutConstraint *c52 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-marginS];
    [self.view addConstraint:c52];
    
    NSLayoutConstraint *c6 = [NSLayoutConstraint constraintWithItem:m_lblReadRateData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-marginS];
    [self.view addConstraint:c6];
    
    NSLayoutConstraint *c8 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblReadTimeData attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.view addConstraint:c8];
    
    NSLayoutConstraint *c81 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateData attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.view addConstraint:c81];
    
    NSLayoutConstraint *c82 = [NSLayoutConstraint constraintWithItem:m_lblReadRateData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.view addConstraint:c82];
    
    
    NSLayoutConstraint *c9 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.1037 constant:0];
    [self.view addConstraint:c9];
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblReadRateData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c101 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.view addConstraint:c101];
    
    NSLayoutConstraint *c11 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeTop multiplier:1.0 constant:-marginS];
    [self.view addConstraint:c11];
    
    NSLayoutConstraint *c12 = [NSLayoutConstraint constraintWithItem:m_lblReadRateData attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.view addConstraint:c12];
    
    NSLayoutConstraint *c121 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeData attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.view addConstraint:c121];
    
    NSLayoutConstraint *c13 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.view addConstraint:c13];
    
    NSLayoutConstraint *c14 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:c14];
    
    NSLayoutConstraint *c131 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblReadTimeData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.view addConstraint:c131];
    
    NSLayoutConstraint *c141 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblReadTimeData attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:c141];
    
    NSLayoutConstraint *c15 = [NSLayoutConstraint constraintWithItem:m_lblReadRateNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.view addConstraint:c15];
    
    NSLayoutConstraint *c16 = [NSLayoutConstraint constraintWithItem:m_lblReadRateNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateData attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:c16];
    
    NSLayoutConstraint *c17 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.view addConstraint:c17];
    
    NSLayoutConstraint *c171 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.view addConstraint:c171];
    
    NSLayoutConstraint *c18 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.view addConstraint:c18];
    
    NSLayoutConstraint *c181 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeNotice attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblReadRateNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.view addConstraint:c181];
    
    NSLayoutConstraint *c19 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagCountData attribute:NSLayoutAttributeTop multiplier:1.0 constant:-0.0075*height];
    [self.view addConstraint:c19];
    
    NSLayoutConstraint *c191 = [NSLayoutConstraint constraintWithItem:m_lblReadTimeNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblReadTimeData attribute:NSLayoutAttributeTop multiplier:1.0 constant:-0.0075*height];
    [self.view addConstraint:c191];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagCountNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.045 constant:0];
    [self.view addConstraint:c20];

    /* Unique Tag Count */
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.034*width];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-0.034*width];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c25 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeTop  multiplier:1.0 constant:(0.0247 + 0.0124)*height];
    [self.view addConstraint:c25];
    
    NSLayoutConstraint *c26 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [self.view addConstraint:c26];
    
    NSLayoutConstraint *c27 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.view addConstraint:c27];
    
    NSLayoutConstraint *c28 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.0617*height];
    [self.view addConstraint:c28];
    
    NSLayoutConstraint *uniqueBottom = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagCountBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_btnStartStop attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self.view addConstraint:uniqueBottom];
    
    /* Start/Stop button */
    
    NSLayoutConstraint *buttonBottom = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:buttonBottom];
    
    NSLayoutConstraint *buttonLeading = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:buttonLeading];
    
    NSLayoutConstraint *buttonTrailing = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:buttonTrailing];
    
    NSLayoutConstraint *buttonHeight = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:tabbarHeight];
    [self.view addConstraint:buttonHeight];

    [self configureAppearance];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];

	/* set title */
    [self.tabBarController setTitle:@"Rapid Read"];
	
    BOOL is_inventory = (ZT_RADIO_OPERATION_INVENTORY == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    if (NO == is_inventory)
    {
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_INVENTORY];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
        if (YES == requested)
        {
            /* simple logic of radioStateChangedOperationRequested w/o cleaning of selected inventory item */
            [UIView performWithoutAnimation:^
             {
                 [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
                 [m_btnStartStop layoutIfNeeded];
             }];
            
            [self updateOperationDataUI];
            
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
            
            if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
            {
                m_lblUniqueTagCountData.hidden = YES;
                batchModeLabel.hidden = NO;
                [self setTotalTagCount:0];
                [self setReadTime:0];
                [self setReadRate:0];
            }
            
        }
        else
        {
            [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_INVENTORY];
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
        }
    }
    
    /* add dpo button to the titlebar */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
    
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
}

- (void)updateOperationDataUI
{
    /* unique tags */
    
    NSArray *_tags = [[[[zt_RfidAppEngine sharedAppEngine] operationEngine] inventoryData] getInventoryList:NO];
    
    int tag_count = (int)[zt_InventoryData getUniqueCount:_tags];
    
    /* total tags */
    int total_tag_count = [zt_InventoryData getTotalCount:_tags];

    NSTimeInterval read_time = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getRadioOperationTime];
    BOOL in_progress = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress];
    if (YES == in_progress)
    {
        NSDate *last_start = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLastStartOperationTime];
        if (nil != last_start)
        {
            read_time += [[NSDate date] timeIntervalSinceDate:last_start];
            [last_start release];
        }
    }
    
    int read_rate = 0;
    if (read_time >= 1)
    {
        read_rate = total_tag_count / read_time;
    }
    if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
    {
        batchModeLabel.hidden = YES;
        m_lblUniqueTagCountData.hidden = NO;
        [self setUniqueTagCount:tag_count];
        [self setTotalTagCount:total_tag_count];
        if (SRFID_BATCHMODECONFIG_ENABLE != [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getBatchModeConfig])
        [self setReadRate:read_rate];
        else
            [self setReadRate:0];
        [self setReadTime:read_time];
    }

    
    if (nil != _tags)
    {
        [_tags release];
    }

}

- (void)showWarning:(NSString *)message
{
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
}

-(void)getTag{
    
    [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdLocationing]];
    NSLog(@"%@ AppFunc tag is 1",m_strTagInput);
    
    [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLocationingTagId]];
     NSLog(@"%@ OpFunc tag is 1",m_strTagInput); // Here is tag
}

- (IBAction)btnStartStopPressed:(id)sender
{
    NSLog(@"Start getting RFID...");
    [self getTag];
    
    NSString *statusMsg = nil;
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine]  getTags:&statusMsg];
    NSLog(@"RFID getTag is %@",statusMsg);
    
   //  NSString *statusMsg = nil;
      [[[zt_RfidAppEngine sharedAppEngine] operationEngine] purgeTags:&statusMsg];
      NSLog(@"RFID pure is %@",statusMsg);
    
    if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
    {
        [self showWarning:@"Getting batched tags: operation not allowed"];
        return;
    }
    
    BOOL inventory_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
 //   NSString *statusMsg = nil;
    if (NO == inventory_requested)
    {
        if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES])
        {
            rfid_res = [[zt_RfidAppEngine sharedAppEngine] purgeTags:&statusMsg];
            NSLog(@"%u ",rfid_res);
        }
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:SRFID_MEMORYBANK_NONE message:&statusMsg];
        if([statusMsg  isEqualToString:@"Inventory Started in Batch Mode"])
        {
            [self getTag];
            batchModeLabel.hidden = NO;
            [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
            m_lblUniqueTagCountData.hidden = YES;
            [self setTotalTagCount:0];
            [self setReadRate:0];
            [self setReadTime:0];
        }
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopInventory:nil];
        NSLog(@"%u ",rfid_res);
    }
}

- (void)setUniqueTagCount:(int)count
{
    if (count == m_UniqueTags)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_UniqueTags / 10) == (count / 10))
    {
        upd = NO;
    }
    
    m_UniqueTags = count;
    
    [m_lblUniqueTagCountData setText:[NSString stringWithFormat:@"%d", count]];
    
    if ((YES == upd) || (m_fszUniqueTags < 0.0))
    {
        m_fszUniqueTags = [self fontSizeToFit:[m_lblUniqueTagCountData text] forLabel:m_lblUniqueTagCountData aMaxSize:200.0];
        [m_lblUniqueTagCountData setFont:[UIFont boldSystemFontOfSize:m_fszUniqueTags]];

    }
}

- (void)setTotalTagCount:(int)count;
{
    if (count == m_TotalTags)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_TotalTags / 10) == (count / 10))
    {
        upd = NO;
    }
    
    m_TotalTags = count;
    
    [m_lblTotalTagCountData setText:[NSString stringWithFormat:@"%d", count]];
    
    if ((YES == upd) || (m_fszTotalTags < 0.0))
    {
        m_fszTotalTags = [self fontSizeToFit:[m_lblTotalTagCountData text] forLabel:m_lblTotalTagCountData aMaxSize:50.0];
        [m_lblTotalTagCountData setFont:[UIFont boldSystemFontOfSize:m_fszTotalTags]];
    }
}

- (void)setReadRate:(int)rate
{
    if (rate == m_ReadRate)
    {
        return;
    }
    
    BOOL upd = YES;
    
    if ((m_ReadRate / 10) == (rate / 10))
    {
        upd = NO;
    }
    
    m_ReadRate = rate;
    
    [m_lblReadRateData setText:[NSString stringWithFormat:@"%d t/s", rate]];
    
    if ((YES == upd) || (m_fszReadRate < 0.0))
    {
        m_fszReadRate = [self fontSizeToFit:[m_lblReadRateData text] forLabel:m_lblReadRateData aMaxSize:50.0];
        [m_lblReadRateData setFont:[UIFont boldSystemFontOfSize:m_fszReadRate]];
    }
}

- (void)setReadTime:(int)time
{
    int _time = time;
    int min = _time / 60;
    int sec = _time % 60;
    [m_lblReadTimeData setText:[NSString stringWithFormat:@"%02d:%02d ",min,sec]];
    
    if (m_fszReadTime < 0.0)
    {
        m_fszReadTime = [self fontSizeToFit:[m_lblReadTimeData text] forLabel:m_lblReadTimeData aMaxSize:50.0];
        [m_lblReadTimeData setFont:[UIFont boldSystemFontOfSize:m_fszReadTime]];
    }
}


- (CGFloat)fontSizeToFit:(NSString*)text forLabel:(UILabel*)ui_label aMaxSize:(CGFloat)max_size;
{
    float lbl_height = ui_label.frame.size.height;
    float lbl_width = ui_label.frame.size.width;
    
    CGFloat font_size = max_size;
    CGSize text_size;
    
    do
    {
        font_size--;
        text_size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:font_size]}];
        
    } while ((text_size.height > lbl_height) || (text_size.width > lbl_width));
    
    return font_size - 5.0;
}

- (void)configureAppearance
{
    /* background colors */
    float bgnd_color = (float)ZT_UI_RAPID_READ_COLOR_LBL_BACKGROUND / 255.0;
    UIColor *bgnd_ui_color = [UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0];
    [m_lblTotalTagCountData setBackgroundColor:bgnd_ui_color];
    [m_lblReadRateData setBackgroundColor:bgnd_ui_color];
    [m_lblUniqueTagCountBackground setBackgroundColor:bgnd_ui_color];
    [m_lblReadTimeData setBackgroundColor:bgnd_ui_color];
    
    /* rounded elements */
    [[m_lblUniqueTagCountBackground layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_BIG];
    [[m_lblReadRateData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
    [[m_lblTotalTagCountData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
    [[m_lblReadTimeData layer] setCornerRadius:ZT_UI_RAPID_READ_CORNER_RADIUS_SMALL];
    
    m_lblTotalTagCountData.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblUniqueTagCountData.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblReadRateData.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblReadTimeData.lineBreakMode = NSLineBreakByWordWrapping;

    /* text color */
    [m_lblReadRateData setTextColor:[UIColor blackColor]];
    [m_lblTotalTagCountData setTextColor:[UIColor blackColor]];
    [m_lblUniqueTagCountData setTextColor:[UIColor blackColor]];
    [m_lblReadTimeData setTextColor:[UIColor blackColor]];
    [m_lblReadRateNotice setTextColor:[UIColor blackColor]];
    [m_lblTotalTagCountNotice setTextColor:[UIColor blackColor]];
    [m_lblReadTimeNotice setTextColor:[UIColor blackColor]];
    
    /* text */
    [m_lblTotalTagCountNotice setText:@"Total Tags"];
    [m_lblReadRateNotice setText:@"Read Rate"];
    [m_lblReadTimeNotice setText:@"Read Time"];
    
    /* text alignment */
    [m_lblReadRateNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblTotalTagCountNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblReadRateNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblReadRateData setTextAlignment:NSTextAlignmentCenter];
    [m_lblTotalTagCountData setTextAlignment:NSTextAlignmentCenter];
    [m_lblUniqueTagCountData setTextAlignment:NSTextAlignmentCenter];
    [m_lblReadTimeData setTextAlignment:NSTextAlignmentCenter];
    
    /* font size */
    [m_lblReadRateNotice setFont:[UIFont systemFontOfSize:ZT_UI_RAPID_READ_FONT_SZ_LBL]];
    [m_lblTotalTagCountNotice setFont:[UIFont systemFontOfSize:ZT_UI_RAPID_READ_FONT_SZ_LBL]];
    [m_lblReadTimeNotice setFont:[UIFont systemFontOfSize:ZT_UI_RAPID_READ_FONT_SZ_LBL]];
    [m_btnStartStop.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BUTTON]];
}

- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_INVENTORY != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        [UIView performWithoutAnimation:^
         {
             [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
             [m_btnStartStop layoutIfNeeded];
         }];
        
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
        if(batchModeLabel.hidden)
        {
            m_lblUniqueTagCountData.hidden = YES;
            batchModeLabel.hidden = NO;
            [self setTotalTagCount:0];
            [self setReadRate:0];
            [self setReadTime:0];
        }
        
        [self updateOperationDataUI];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setTitle:@"START" forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        if(!batchModeLabel.hidden)
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getTags:&statusMsg];
//            NSLog(@"%u ",&statusMsg);
            batchModeLabel.hidden=YES;
            m_lblUniqueTagCountData.hidden = NO;
        }
        else if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
        {
            NSString *statusMsg;
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] purgeTags:&statusMsg];
            if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
                [[zt_RfidAppEngine sharedAppEngine] reconnectAfterBatchMode];
            NSLog(@"%i tag is ",&statusMsg);
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
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_RR_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
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

- (BOOL)onNewTriggerEvent:(BOOL)pressed
{
    __block zt_RapidReadVC *__weak_self = self;
    
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
                /* operation is already in progress or has been requested (case of periodic start trigger */
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    return YES;
//    /* nrv364: process only on trigger press
//     root cause:
//     - suppose that start trigger is HH press and stop is immediate
//     - command issued
//     - trigger pressed
//     - trigger PRESS notification from RFID
//     - operation START notification from RFID
//     - trigger released
//     - trigger RELEASE notification from RFID
//     - we abort ongoing operation */
//    if (YES == pressed)
//    {
//        /* nrv364:
//         with periodic start trigger operation start/stop notifications indicate
//         inventory "loops" and abort cmd is required to stop the on going operation */
//        if ((YES == [[zt_RfidAppEngine sharedAppEngine] isRadioOperationInProgress]) ||
//            ((YES == m_OperationRequested) && (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerPeriodic])))
//        {
//            /* op in progress -> shall stop */
//            
//            if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerHandheld])
//            {
//                /* if stop trigger is HH than we have no reason to perform a stop action manually */
//                dispatch_async(dispatch_get_main_queue(),
//                               ^{
//                                   [__weak_self btnStartStopPressed:nil];
//                               });
//            }
//        }
//        else
//        {
//            /* op not in progress -> shall start */
//            if (NO == m_OperationRequested)
//            {
//                if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerHandheld])
//                {
//                    /* if start trigger is HH than we have no reason to perform a start action manually */
//                    dispatch_async(dispatch_get_main_queue(),
//                                   ^{
//                                       [__weak_self btnStartStopPressed:nil];
//                                   });
//                }
//            }
//        }
//        
//    }
//    return YES;
}


@end
