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
 *  Description:  SettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SettingsVC.h"
#import "ReaderListVC.h"
#import "ConnectionSettingsVC.h"
#import "BatteryStatusVC.h"
#import "ui_config.h"
#import "AlertView.h"

#define ZT_VC_SETTINGS_CELL_IDX_READER_LIST                    0
#define ZT_VC_SETTINGS_CELL_IDX_CONNECTION                     1


#define ZT_VC_SETTINGS_OPTIONS_NUMBER                         2


#define ZT_CELL_ID_ACTIVE                                      @"ID_CELL_ACTIVE"
#define ZT_CELL_ID_DISABLE                                     @"ID_CELL_DISABLE"

@interface zt_SettingsVC () {
    NSNumber *m_LoadedViewIndex;
}

@property (nonatomic, retain) zt_SledConfiguration *localSled;

@end

@implementation zt_SettingsVC

/* Key to observe to detect change in DPO setting (KVO) */
static NSString *kKeyPathDpoEnable = @"currentDpoEnable";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_SettingsOptionsHeaders = [[NSMutableArray alloc] initWithCapacity:ZT_VC_SETTINGS_OPTIONS_NUMBER];
        m_SettingsOptionsImages = [[NSMutableArray alloc] initWithCapacity:ZT_VC_SETTINGS_OPTIONS_NUMBER];
        
        /* fill with empty elements to be replaced later */
        for (int i = 0; i < ZT_VC_SETTINGS_OPTIONS_NUMBER; i++)
        {
            [m_SettingsOptionsHeaders addObject:@""];
            [m_SettingsOptionsImages addObject:@""];
        }
        
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_CONNECTION withObject:ZT_STR_SETTINGS_CONNECTION];
        [m_SettingsOptionsHeaders replaceObjectAtIndex:ZT_VC_SETTINGS_CELL_IDX_READER_LIST withObject:ZT_STR_SETTINGS_READER_LIST];

        m_OffscreenImageLabelCell = [[zt_ImageLabelCellView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];

    if (nil != m_OffscreenImageLabelCell)
    {
        [m_OffscreenImageLabelCell release];
    }
    if (nil != m_SettingsOptionsImages)
    {
        [m_SettingsOptionsImages removeAllObjects];
        [m_SettingsOptionsImages release];
    }
    if (nil != m_SettingsOptionsHeaders)
    {
        [m_SettingsOptionsHeaders removeAllObjects];
        [m_SettingsOptionsHeaders release];
    }
    [m_tblSettingsOptions release];
    
    if( nil != _localSled)
    {
        [_localSled release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    [m_tblSettingsOptions setDelegate:self];
    [m_tblSettingsOptions setDataSource:self];
    [m_tblSettingsOptions registerClass:[zt_ImageLabelCellView class] forCellReuseIdentifier:ZT_CELL_ID_ACTIVE];
    [m_tblSettingsOptions registerClass:[zt_ImageLabelCellView class] forCellReuseIdentifier:ZT_CELL_ID_DISABLE];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblSettingsOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Settings"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblSettingsOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    [self configureAppearance];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (m_LoadedViewIndex == nil) {
        // do nothing
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    // observe "currentDpoEnable" property changes using KVO
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] addObserver:self forKeyPath:kKeyPathDpoEnable options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Remove KVO observer for the DPO option
    [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] removeObserver:self forKeyPath:kKeyPathDpoEnable];
}

- (void)applyNewSetting:(NSString *)name
{
    
    NSString *message = [NSString stringWithFormat:@"%@", name];
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(updateSled) withObject:nil withString:message];
}

- (void)updateSled
{
    int idx = [m_LoadedViewIndex intValue];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *response;
    
    switch (idx) {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            
            break;
        case ZT_VC_SETTINGS_CELL_IDX_CONNECTION:
            
            break;
    }
    sleep(1);
    
    [self handleCommandResult:result withStatusMessage:response];
    

    m_LoadedViewIndex = [NSNumber numberWithInt:-1];
}

- (void)configureImageLabelCell:(zt_ImageLabelCellView*)cell forRow:(int)row
{
    NSString *settingHeader = (NSString*)[m_SettingsOptionsHeaders objectAtIndex:row];
    if ([settingHeader isEqualToString:ZT_STR_SETTINGS_CONNECTION] ||
        [settingHeader isEqualToString:ZT_STR_SETTINGS_READER_LIST])
    {
        [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
        [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
    }
    else
    {
        if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
            [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
        }
        else
        {
            [cell setInfoNotice:(NSString*)[m_SettingsOptionsHeaders objectAtIndex:row]];
            [cell setCellImage:(NSString*)[m_SettingsOptionsImages objectAtIndex:row]];
            [cell setDisableStyle];
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
    }
}

- (void)configureAppearance
{
    /* nothing */
}

- (BOOL)deviceListHasBeenUpdated
{
    /* This refreshes the power management button and the rest of the table */
    [self refreshPowerManagementButton];
    
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive]) {
        return YES;
    }
    
    switch ([m_LoadedViewIndex intValue])
    {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            // do nothing
            break;
        case ZT_VC_SETTINGS_CELL_IDX_CONNECTION:
            // do nothing
            break;
    }

    
    return YES;
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_SettingsOptionsHeaders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    [self configureImageLabelCell:m_OffscreenImageLabelCell forRow:(int)[indexPath row]];
    
    [m_OffscreenImageLabelCell setNeedsUpdateConstraints];
    [m_OffscreenImageLabelCell updateConstraintsIfNeeded];
    
   
    
    [m_OffscreenImageLabelCell setNeedsLayout];
    [m_OffscreenImageLabelCell layoutIfNeeded];
    
    height = [m_OffscreenImageLabelCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    zt_ImageLabelCellView *_cell = nil;
    NSString *settingHeader = (NSString*)[m_SettingsOptionsHeaders objectAtIndex:(int)[indexPath row]];
    if ([settingHeader isEqualToString:ZT_STR_SETTINGS_CONNECTION] ||
        [settingHeader isEqualToString:ZT_STR_SETTINGS_READER_LIST])
    {
        _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_ACTIVE forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_ACTIVE];
        }

    }
    else
    {
        if([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_ACTIVE forIndexPath:indexPath];
            
            if (_cell == nil)
            {
                _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_ACTIVE];
            }

        }
        else
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_DISABLE forIndexPath:indexPath];
            
            if (_cell == nil)
            {
                _cell = [[zt_ImageLabelCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_DISABLE];
            }
        }
    }
        
    [self configureImageLabelCell:_cell forRow:(int)[indexPath row]];
    
    [_cell setNeedsUpdateConstraints];
    [_cell updateConstraintsIfNeeded];
    
    return _cell;
    }
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int idx = (int)[indexPath row];
    
    UIViewController *vc = nil;
    zt_ReaderListVC *reader_list_vc = nil;
    zt_ConnectionSettingsVC *connection_vc = nil;
    zt_BatteryStatusVC *battery_vc = nil;
    
    switch (idx)
    {
        case ZT_VC_SETTINGS_CELL_IDX_READER_LIST:
            reader_list_vc = (zt_ReaderListVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_READER_LIST_VC"];
            vc = reader_list_vc;
            break;
        case ZT_VC_SETTINGS_CELL_IDX_CONNECTION:
            connection_vc = (zt_ConnectionSettingsVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_CONNECTION_SETTINGS_VC"];
            vc = connection_vc;
            break;
    }
    
    if (nil != vc)
    {
        m_LoadedViewIndex = [NSNumber numberWithInt:idx];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) refreshPowerManagementButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tblSettingsOptions reloadData];
    });
}

#pragma mark - KVO observer methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // detect if the current dpo enable value has changed
    if ([keyPath isEqual:kKeyPathDpoEnable])
    {
        [self refreshPowerManagementButton];
    }
}

@end
