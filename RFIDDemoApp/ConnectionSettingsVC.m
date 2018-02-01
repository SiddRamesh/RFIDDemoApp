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
 *  Description:  ConnectionSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConnectionSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"

#define ZT_VC_CONNECTION_SECTION_IDX_CONNECTION               0
#define ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION             1
#define ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT              2

#define ZT_VC_CONNECTION_CELL_IDX_AUTO_RECONNECT              0

#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_AVAILABLE      0
#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_ACTIVE         1
#define ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_BATTERY        2

#define ZT_VC_CONNECTION_CELL_IDX_DATA_EXPORT_DATA            0

#define ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT              0
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE      1
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE         2
#define ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY        3
#define ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT                 4

@interface zt_ConnectionSettingsVC ()

@end

@implementation zt_ConnectionSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_OptionsHeaders = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_HEADER_CONNECTION, ZT_STR_SETTINGS_CONNECTION_HEADER_NOTIFICATION,ZT_STR_SETTINGS_CONNECTION_HEADER_DATA_EXPORT, nil];
        m_OptionsConnection = [[NSArray alloc] initWithObjects:
            ZT_STR_SETTINGS_CONNECTION_AUTO_RECONNECT,
            nil];
        m_OptionsNotification = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_AVAILABLE, ZT_STR_SETTINGS_CONNECTION_NOTIFICATION_ACTIVE, ZT_STR_SETTINGS_CONNECTION_NOTIFICAtiON_BATTERY, nil];
        m_OptionsDataExport = [[NSArray alloc] initWithObjects:ZT_STR_SETTINGS_CONNECTION_DATA_EXPORT, nil];
        
        m_OffscreenSwitchCell = [[zt_SwitchCellView alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_OffscreenSwitchCell)
    {
        [m_OffscreenSwitchCell release];
    }
    if (nil != m_OptionsHeaders)
    {
        [m_OptionsHeaders release];
    }
    if (nil != m_OptionsConnection)
    {
        [m_OptionsConnection release];
    }
    if (nil != m_OptionsNotification)
    {
        [m_OptionsNotification release];
    }
    if (nil != m_OptionsDataExport)
    {
        [m_OptionsDataExport release];
    }
    [m_tblOptions release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Application"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    [self setupConfigurationInitial];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(int)row inSection:(int)section
{
    NSArray *options = nil;
    
    switch (section) {
        case ZT_VC_CONNECTION_SECTION_IDX_CONNECTION:
            options = m_OptionsConnection;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION:
            options = m_OptionsNotification;
            break;
        
        case ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT:
            options = m_OptionsDataExport;
            break;
            
        default:
            break;
    }

    [cell setInfoNotice:(NSString*)[options objectAtIndex:row]];
    
    if (ZT_VC_CONNECTION_SECTION_IDX_CONNECTION == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_AUTO_RECONNECT == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigConnectionAutoReconnection];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT];
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_ACTIVE == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationConnection];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_AVAILABLE == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationAvailable];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE];
        }
        else if (ZT_VC_CONNECTION_CELL_IDX_NOTIFICATION_BATTERY == row)
        {
            int _option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigNotificationBattery];
            [cell setOption:_option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY];
        }
    }
    else if (ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT == section)
    {
        if (ZT_VC_CONNECTION_CELL_IDX_DATA_EXPORT_DATA == row) {
            int option = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigDataExport ];
            [cell setOption:option];
            [cell setCellTag:ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT];
        }
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

- (void)setupConfigurationInitial
{

}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        zt_SwitchCellView *_cell = (zt_SwitchCellView*)option_cell;
        int cell_tag = [_cell getCellTag];
        BOOL cell_value = [_cell getOption];
        switch (cell_tag)
        {
            case ZT_VC_CONNECTION_CELL_TAG_AUTO_RECONNECT:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigConnectionAutoReconnection:cell_value];
                [[zt_RfidAppEngine sharedAppEngine] setAutoReconect:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_ACTIVE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationConnection:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_AVAILABLE:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationAvailable:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_NOTIFICATION_BATTERY:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigNotificationBattery:cell_value];
                break;
            case ZT_VC_CONNECTION_CELL_TAG_DATA_EXPORT:
                [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setConfigDataExport:cell_value];
                break;
        }
    }
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [m_OptionsHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (NSString*)[m_OptionsHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *options = nil;
    switch (section) {
        case ZT_VC_CONNECTION_SECTION_IDX_CONNECTION:
            options = m_OptionsConnection;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_NOTIFICATION:
            options = m_OptionsNotification;
            break;
            
        case ZT_VC_CONNECTION_SECTION_IDX_DATA_EXPORT:
            options = m_OptionsDataExport;
            break;
            
        default:
            break;
    }
    return [options count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    [self configureSwitchCell:m_OffscreenSwitchCell forRow:(int)[indexPath row] inSection:(int)[indexPath section]];
    
    [m_OffscreenSwitchCell setNeedsUpdateConstraints];
    [m_OffscreenSwitchCell updateConstraintsIfNeeded];
    
    [m_OffscreenSwitchCell setNeedsLayout];
    [m_OffscreenSwitchCell layoutIfNeeded];
    
    height = [m_OffscreenSwitchCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0; /* for cell separator */
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
    
    if (_cell == nil)
    {
        // toDo autoRelease
        _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    }
    
    [self configureSwitchCell:_cell forRow:(int)[indexPath row] inSection:(int)[indexPath section]];
    
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
