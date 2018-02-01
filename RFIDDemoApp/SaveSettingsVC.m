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
 *  Description:  SaveSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SaveSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"
#import "AlertView.h"

#define ZT_VC_TAG_REPORT_CELL_TAG_PC                  0
#define ZT_VC_TAG_REPORT_CELL_TAG_RSSI                1
#define ZT_VC_TAG_REPORT_CELL_TAG_PHASE               2
#define ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX         3
#define ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT          4



typedef enum
{
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_ANTENNA = 0,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_SINGULATION,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_TAG_REPORT,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_BATCH_MODE,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_TRIGGER,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_BEEPER,
    //ZT_VC_SAVE_SETTINGS_SECTION_IDX_REGULATORY,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_PWR_MANAGEMENT,
    ZT_VC_SAVE_SETTINGS_SECTION_IDX_TOTAL
    
} ZT_SAVE_SETTING;

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_ANTENNA_POWER_LEVEL           0
#define ZT_VC_SAVE_SETTINGS_CELL_IDX_ANTENNA_LINK_PROFILE          1

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_SESSION           0
#define ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_TAG_POPULATION    1
#define ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_INV_STATE         2
#define ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_SL_FLAG           3

/* ZT_SLED_CFG_TAG_REPORT_* are used as cell idxs for tag report section */

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_REGULATORY_REGION             0
/* ZT_SLED_CFG_REGULATORY_CHANNEL_* + 1 are used as cell idxs for channels in 
 regulatory section */

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_TRIGGER_START                 0
/* ... */

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_BEEPER_ENABLED                0
#define ZT_VC_SAVE_SETTINGS_CELL_IDX_BEEPER_VOLUME                 1

#define ZT_VC_SAVE_SETTINGS_CELL_IDX_DPO_ENABLE                    0

@interface zt_SaveSettingsVC ()

@end

@implementation zt_SaveSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self)
    {
        m_OffscreenInfoCell = [[zt_InfoCellView alloc] init];
        
        /* retrieve supported region info if not retrieved */
        if ([[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] regionOptions] count]==0) {
            //[[zt_RfidAppEngine sharedAppEngine] getSupportedRegions:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_OffscreenInfoCell)
    {
        [m_OffscreenInfoCell release];
    }
    
    [m_tblSledConfigOptions release];
    [m_btnSave release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblSledConfigOptions setDelegate:self];
    [m_tblSledConfigOptions setDataSource:self];
    [m_tblSledConfigOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblSledConfigOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Save Configuration"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_btnSave attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblSledConfigOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblSledConfigOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblSledConfigOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_btnSave attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c5];
    
    NSLayoutConstraint *c6 = [NSLayoutConstraint constraintWithItem:m_btnSave attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c6];
    
    NSLayoutConstraint *c7 = [NSLayoutConstraint constraintWithItem:m_btnSave attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.15 constant:0.0];
    [self.view addConstraint:c7];
    
    NSLayoutConstraint *c8 = [NSLayoutConstraint constraintWithItem:m_tblSledConfigOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_btnSave attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c8];

    [m_btnSave setTitle:@"SAVE" forState:UIControlStateNormal];
    
    [m_btnSave.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_ACCESS_FONT_SZ_BUTTON]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureInfoCell:(zt_InfoCellView*)cell forRow:(int)row forSection:(int)section;
{
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_ANTENNA == section)
    {
        if (ZT_VC_SAVE_SETTINGS_CELL_IDX_ANTENNA_LINK_PROFILE == row)
        {
            [cell setInfoNotice:@"Link profile"];
            
            NSNumber *linkProfileKey = [NSNumber numberWithInt:configuration.currentAntennaLinkProfile];
            
            [cell setData:(NSString*)[configuration.antennaOptionsLinkProfile objectForKey:linkProfileKey]];
        }
        else if (ZT_VC_SAVE_SETTINGS_CELL_IDX_ANTENNA_POWER_LEVEL == row)
        {
            [cell setInfoNotice:@"Power level"];
            
            [cell setData:[NSString stringWithFormat:@"%1.1f", configuration.currentAntennaPowerLevel]];
        }
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_PWR_MANAGEMENT == section)
    {
        if (ZT_VC_SAVE_SETTINGS_CELL_IDX_DPO_ENABLE == row)
        {
            [cell setInfoNotice:@"Dynamic Power"];
            
            BOOL dpo = [[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentDpoEnable] boolValue];
            
            [cell setData:((YES == dpo) ? @"On" : @"Off")];
        }
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_BEEPER == section)
    {
        if (ZT_VC_SAVE_SETTINGS_CELL_IDX_BEEPER_ENABLED == row)
        {
            [cell setInfoNotice:@"Beeper"];
            
            BOOL sled_beeper = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentBeeperEnable];
            
            [cell setData:((YES == sled_beeper) ? @"On" : @"Off")];
        }
        else if (ZT_VC_SAVE_SETTINGS_CELL_IDX_BEEPER_VOLUME == row)
        {
            [cell setInfoNotice:@"Beeper volume"];
            int sled_volume = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentBeeperLevel];
            
            [cell setData:(NSString *)[[[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] mapperBeeper] getDictionary] objectForKey:[NSNumber numberWithInt:sled_volume]]];
        }
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_SINGULATION == section)
    {
        if (ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_INV_STATE == row)
        {
            [cell setInfoNotice:@"Inventory state"];
            
            int state_selected = configuration.currentInventoryState;
            
            [cell setData:(NSString*)[[configuration.mapperInventoryState getDictionary] objectForKey:[NSNumber numberWithInt:state_selected]]];
        }
        else if (ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_SESSION == row)
        {
            [cell setInfoNotice:@"Session"];
            
            int session_selected = configuration.currentSession;
            
            [cell setData:(NSString*)[[configuration.mapperSession getDictionary] objectForKey:[NSNumber numberWithInt:session_selected]]];
        }
        else if (ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_TAG_POPULATION == row)
        {
            [cell setInfoNotice:@"Tag population"];
            
            int tag_population = configuration.currentTagPopulation;
            
            [cell setData:[NSString stringWithFormat:@"%d", tag_population]];
        }
        else if (ZT_VC_SAVE_SETTINGS_CELL_IDX_SINGULATION_SL_FLAG == row)
        {
            [cell setInfoNotice:@"SL flag"];
            
            int flag_selected = configuration.currentSLFLag;
            
            [cell setData:(NSString*)[[configuration.mapperSLFlag getDictionary] objectForKey:[NSNumber numberWithInt:flag_selected]]];
        }
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_TAG_REPORT == section)
    {
        
        NSArray *_fields = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getConfigTagReportOptions];
        BOOL option = NO;
        switch (row)
        {
            case ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX:
                option = configuration.tagReportChannelIdx;
                [cell setInfoNotice:(NSString*)[_fields objectAtIndex:ZT_SLED_CFG_TAG_REPORT_CHANNEL_INDEX]];
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_PC:
                option = configuration.tagReportPC;
                [cell setInfoNotice:(NSString*)[_fields objectAtIndex:ZT_SLED_CFG_TAG_REPORT_PC]];
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_PHASE:
                option = configuration.tagReportPhase;
                [cell setInfoNotice:(NSString*)[_fields objectAtIndex:ZT_SLED_CFG_TAG_REPORT_PHASE]];
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_RSSI:
                option = configuration.tagReportRSSI;
                [cell setInfoNotice:(NSString*)[_fields objectAtIndex:ZT_SLED_CFG_TAG_REPORT_RSSI]];
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT:
                option = configuration.tagReportSeenCount;
                [cell setInfoNotice:(NSString*)[_fields objectAtIndex:ZT_SLED_CFG_TAG_REPORT_TAG_SEEN_COUNT]];
                break;
        }
    
        [cell setData:((YES == option) ? @"On" : @"Off")];

    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_BATCH_MODE == section)
    {
        [cell setInfoNotice:@"Batch Mode"];
        NSArray *batchModeAry = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] batchModeOptions];
        int sled_batchMode = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentBatchMode];
        
        [cell setData:[batchModeAry objectAtIndex:sled_batchMode]];
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_TRIGGER == section)
    {
        NSArray *starts = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] triggerStartOptions];
        int startSelected = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartTriggerOption];
        
        int stopSelected = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTriggerOption];
        
        BOOL startExtra = ((ZT_SLED_CFG_TRIGGER_START_PERIODIC == startSelected) ||
                               (ZT_SLED_CFG_TRIGGER_START_HANDHELD == startSelected));
        
        BOOL stopOneExtra = ((ZT_SLED_CFG_TRIGGER_STOP_DURATION == stopSelected));
        
        BOOL stopTwoExtra = ((ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == stopSelected) ||
                             (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stopSelected) ||
                             (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == stopSelected));
        
        if (ZT_VC_SAVE_SETTINGS_CELL_IDX_TRIGGER_START == row)
        {
            [cell setInfoNotice:@"Start"];
            [cell setData:(NSString*)[starts objectAtIndex:startSelected]];
        }
        else
        {
            /*
             (startExtra == NO && stopOneExtra == NO && stopTwoExtra == NO)
             - 0 start
             - 1 stop
             
             startExtra
             (startExtra == YES && stopOneExtra == NO && stopTwoExtra == NO)
             - 0 start
             - 1 start period || trigger type
             - 2 stop

             startExtra
             stopOneExtra
             (startExtra == YES && stopOneExtra == YES && stopTwoExtra == NO)
             - 0 start
             - 1 period || type
             - 2 stop
             - 3 stop param || trigger type

             startExtra
             stopTwoExtra
             (startExtra == YES && stopOneExtra == NO && stopTwoExtra == YES)
             - 0 start
             - 1 start period || trigger type
             - 2 stop
             - 3 stop param || trigger type
             - 4 duration

             stopOneExtra
             (startExtra == NO && stopOneExtra == YES && stopTwoExtra == NO)
             - 0 start
             - 1 stop
             - 2 stop param || trigger type
             ------------------------

             stopTwoExtra
             (startExtra == NO && stopOneExtra == NO && stopTwoExtra == YES)
             - 0 start
             - 1 stop
             - 2 stop param || trigger type
             - 3 duration
             */
            
            if(startExtra == NO && stopOneExtra == NO && stopTwoExtra == NO)
            {
                switch (row) {
                    case 1:
                        [self configureInfoCellStop:cell];
                        break;
                }
            }
            
            if (startExtra == YES && stopOneExtra == NO && stopTwoExtra == NO)
            {
                switch (row) {
                    case 1:
                        if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == startSelected)
                        {
                            [self configureInfoCellStartPeriod:cell];
                        }
                        else if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == startSelected)
                        {
                            int startType = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartTriggerType];
                            [self configureInfoCellTriggerType:cell withType:startType];
                        }
                        break;
                    
                    case 2:
                        [self configureInfoCellStop:cell];
                        break;
                }
            }
            
            if (startExtra == YES && stopOneExtra == YES && stopTwoExtra == NO)
            {
                switch (row) {
                    case 1:
                        if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == startSelected)
                        {
                            [self configureInfoCellStartPeriod:cell];
                        }
                        else if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == startSelected)
                        {
                            int startType = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartTriggerType];
                            [self configureInfoCellTriggerType:cell withType:startType];
                        }
                        break;
                        
                    case 2:
                        [self configureInfoCellStop:cell];
                        break;
                        
                    case 3:
                        if ((ZT_SLED_CFG_TRIGGER_STOP_DURATION == stopSelected))
                        {
                            [self configureInfoCellStopParam:cell withParam:stopSelected];
                        }
                        break;
                }
            }
            
            if (startExtra == YES && stopOneExtra == NO && stopTwoExtra == YES)
            {
                switch (row) {
                    case 1:
                        if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == startSelected)
                        {
                            [self configureInfoCellStartPeriod:cell];
                        }
                        else if (ZT_SLED_CFG_TRIGGER_START_HANDHELD == startSelected)
                        {
                            int startType = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartTriggerType];
                            [self configureInfoCellTriggerType:cell withType:startType];
                        }
                        break;
                        
                    case 2:
                        [self configureInfoCellStop:cell];
                        break;
                        
                    case 3:
                        if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stopSelected)
                        {
                            int stopType = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTriggerType];
                            [self configureInfoCellTriggerType:cell withType:stopType];
                        }
                        else
                        {
                            [self configureInfoCellStopParam:cell withParam:stopSelected];
                        }
                        break;
                        
                    case 4:
                        [self configureInfoCellTimeout:cell];
                        break;

                }
            }
            
            if (startExtra == NO && stopOneExtra == YES && stopTwoExtra == NO)
            {
                switch (row) {
                    case 1:
                        [self configureInfoCellStop:cell];
                        break;
                        
                    case 2:
                        if ((ZT_SLED_CFG_TRIGGER_STOP_DURATION == stopSelected))
                        {
                            [self configureInfoCellStopParam:cell withParam:stopSelected];
                        }
                        
                        break;
                        
                }
            }
            
            if (startExtra == NO && stopOneExtra == NO && stopTwoExtra == YES)
            {
                switch (row) {
                    case 1:
                        [self configureInfoCellStop:cell];
                        break;
                        
                    case 2:
                        if (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stopSelected)
                        {
                            int stopType = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTriggerType];
                            [self configureInfoCellTriggerType:cell withType:stopType];
                        }
                        else
                        {
                            [self configureInfoCellStopParam:cell withParam:stopSelected];
                        }
                        break;
                        
                    case 3:
                        [self configureInfoCellTimeout:cell];
                        break;
                }
            }
        }
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setStyle:ZT_CELL_INFO_STYLE_GRAY];
}

- (void)configureInfoCellTriggerType:(zt_InfoCellView*)cell withType:(int)type
{
    /* time */
    [cell setInfoNotice:@"Trigger Type"];
    
    NSArray *types = [[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] mapperTriggerType] getStringArray];
    
    [cell setData:(NSString *)[types objectAtIndex:type]];
}

- (void)configureInfoCellStop:(zt_InfoCellView*)cell
{
    /* stop */
    NSArray *stops = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] triggerStopOptions];
    int stop_selected = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTriggerOption];
    
    [cell setInfoNotice:@"Stop"];
    [cell setData:(NSString*)[stops objectAtIndex:stop_selected]];
}

-(void)configureInfoCellTimeout:(zt_InfoCellView*)cell
{
    [cell setInfoNotice:@"Timeout"];
    long long timeout = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTimeout];
    [cell setData:[NSString stringWithFormat:@"%lld", timeout]];
}
- (void)configureInfoCellDuration:(zt_InfoCellView*)cell
{
    /* periodic report */
    [cell setInfoNotice:@"Duration"];
    long long duration = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTimeout];
    [cell setData:[NSString stringWithFormat:@"%lld", duration]];
}

- (void)configureInfoCellStartPeriod:(zt_InfoCellView*)cell
{
    /* start period */
    [cell setInfoNotice:@"Periodic"];
    long long _start_period = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartDelay];
    [cell setData:[NSString stringWithFormat:@"%lld", _start_period]];
}

- (void)configureInfoCellStopParam:(zt_InfoCellView*)cell withParam:(int)param
{
    if (ZT_SLED_CFG_TRIGGER_STOP_DURATION == param)
    {
        [cell setInfoNotice:@"Duration"];
        long long _duration = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTimeout];
        [cell setData:[NSString stringWithFormat:@"%lld", _duration]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == param)
    {
        [cell setInfoNotice:@"N Attempts"];
        long long _attempts = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopInventoryCount];
        [cell setData:[NSString stringWithFormat:@"%lld", _attempts]];
    }
    else if (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == param)
    {
        [cell setInfoNotice:@"Tag Observation"];
        long long _observation = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTagCount];
        [cell setData:[NSString stringWithFormat:@"%lld", _observation]];
    }
}

- (IBAction)btnSaveConfigPressed:(id)sender
{
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(saveConfigAction) withObject:nil withString:@"Saving configuration"];
}

- (void)saveConfigAction
{
    SRFID_RESULT result = [[zt_RfidAppEngine sharedAppEngine] saveReaderConfig:nil];
    sleep(1);
    dispatch_sync(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:result==SRFID_RESULT_SUCCESS aSuccessMessage:@"Settings applied successfully" aFailureMessage:@"Failed to apply settings"];
        //[alertView showSuccessFailure:self.view isSuccess:result];
    });

}
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (ZT_VC_SAVE_SETTINGS_SECTION_IDX_TOTAL + 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_ANTENNA:
            return @"Antenna";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_BEEPER:
            return @"Beeper";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_SINGULATION:
            return @"Singulation";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_TRIGGER:
            return @"Start\\Stop Triggers";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_TAG_REPORT:
            return @"Tag Report";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_PWR_MANAGEMENT:
            return @"Power Optimization";
        case ZT_VC_SAVE_SETTINGS_SECTION_IDX_BATCH_MODE:
            return @"Batch Mode";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_ANTENNA == section)
    {
        return 2;
    }
        
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_BEEPER == section)
    {
        return 2;
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_BATCH_MODE == section)
    {
        return 1;
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_SINGULATION == section)
    {
        return 4;
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_TAG_REPORT == section)
    {
        return 5;
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_TRIGGER == section)
    {
        count = 2;
        
        int startOption = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStartTriggerOption];
        
        if (ZT_SLED_CFG_TRIGGER_START_PERIODIC == startOption ||
            ZT_SLED_CFG_TRIGGER_START_HANDHELD == startOption)
        {
            count += 1;
        }
        
        int stopOption = [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] currentStopTriggerOption];
        
        if ((ZT_SLED_CFG_TRIGGER_STOP_DURATION == stopOption))
        {
            count+= 1;
        }
        else if ((ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS == stopOption)  ||
                 (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == stopOption) ||
                 (ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION == stopOption))
                 
        {
            count += 2;
        }
        return count;
    }
    else if (ZT_VC_SAVE_SETTINGS_SECTION_IDX_PWR_MANAGEMENT == section)
    {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    int section_idx = (int)[indexPath section];
    
    CGFloat height = 0.0;
    
    [self configureInfoCell:m_OffscreenInfoCell forRow:cell_idx forSection:section_idx];
    
    [m_OffscreenInfoCell setNeedsUpdateConstraints];
    [m_OffscreenInfoCell updateConstraintsIfNeeded];
    
    [m_OffscreenInfoCell setNeedsLayout];
    [m_OffscreenInfoCell layoutIfNeeded];
    
    height = [m_OffscreenInfoCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    int section_idx = (int)[indexPath section];
    
    zt_InfoCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_INFO forIndexPath:indexPath];
    
    if (_cell == nil)
    {
        _cell = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    }
    
    [self configureInfoCell:_cell forRow:cell_idx forSection:section_idx];
    
    [_cell setNeedsUpdateConstraints];
    [_cell updateConstraintsIfNeeded];
    
    return _cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
