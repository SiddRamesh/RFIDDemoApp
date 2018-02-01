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
 *  Description:  TagReportSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TagReportSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"

#define ZT_VC_TAG_REPORT_CELL_TAG_PC                  0
#define ZT_VC_TAG_REPORT_CELL_TAG_RSSI                1
#define ZT_VC_TAG_REPORT_CELL_TAG_PHASE               2
#define ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX         3
#define ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT          4

#define ZT_VC_TAG_REPORT_SECTION_IDX                   0
#define ZT_VC_BATCH_MODE_SECTION_IDX                   1

#define ZT_VC_REPORTUNIQUETAGS_SECTION_IDX             2
#define ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS     5

@interface zt_TagReportSettingsVC ()

@end

@implementation zt_TagReportSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
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
    if( nil != m_cellBatchMode)
    {
        [m_cellBatchMode release];
    }
    if(m_cellPicker != nil)
    {
        [m_cellPicker release];
    }
    
    [m_tblTagReportOptions release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [m_tblTagReportOptions setDelegate:self];
    [m_tblTagReportOptions setDataSource:self];
    [m_tblTagReportOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblTagReportOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Tag Reporting"];
    
    localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    /* Batch Mode elements */
    
    m_OptionsBatchMode = [[NSArray alloc] initWithObjects:ZT_TAGREPORT_BATCHMODE_DISABLE, ZT_TAGREPORT_BATCHMODE_AUTO,ZT_TAGREPORT_BATCHMODE_ENABLE, nil];
    m_SelectedOptionMemoryBank = 0;
    
    m_PickerCellIdx = -1;
    
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setDelegate:self];
    
    m_cellBatchMode = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellBatchMode setInfoNotice:@"Batchmode"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblTagReportOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    [self setupConfigurationInitial];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(NSIndexPath *)indexPath
{
    zt_SledConfiguration *config = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX){
        if (ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX == [indexPath row])
        {
            [cell setInfoNotice:@"Channel Index"];
            [cell setOption:config.tagReportChannelIdx];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX];
        }
        else if (ZT_VC_TAG_REPORT_CELL_TAG_PC == [indexPath row])
        {
            [cell setInfoNotice:@"PC"];
            [cell setOption:config.tagReportPC];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_PC];
        }
        else if (ZT_VC_TAG_REPORT_CELL_TAG_PHASE == [indexPath row])
        {
            [cell setInfoNotice:@"Phase"];
            [cell setOption:config.tagReportPhase];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_PHASE];
        }
        else if (ZT_VC_TAG_REPORT_CELL_TAG_RSSI == [indexPath row])
        {
            [cell setInfoNotice:@"RSSI"];
            [cell setOption:config.tagReportRSSI];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_RSSI];
        }
        else if (ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT == [indexPath row])
        {
            [cell setInfoNotice:@"Tag Seen Count"];
            [cell setOption:config.tagReportSeenCount];
            [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT];
        }
    }if(indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX){
        
        [cell setInfoNotice:@"Report unique tags"];
        [cell setOption:[config.isUniqueTagsReport boolValue]];
        [cell setCellTag:ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS];
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setDelegate:self];
}

- (void)setupConfigurationInitial
{
    /* TBD: fill with real data on view appearance */
    
    [m_cellPicker setChoices:m_OptionsBatchMode];
    int sled_mode = [localSled currentBatchMode];
    [m_cellPicker setSelectedChoice:sled_mode];
    [m_cellBatchMode setData:(NSString *)[m_OptionsBatchMode objectAtIndex:sled_mode]];
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        zt_SwitchCellView *cell = (zt_SwitchCellView*)option_cell;
        int cellTag = [cell getCellTag];
        BOOL cellValue = [cell getOption];
        switch (cellTag)
        {
            case ZT_VC_TAG_REPORT_CELL_TAG_CHANNEL_IDX:
                localSled.tagReportChannelIdx = cellValue;
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_PC:
                localSled.tagReportPC = cellValue;
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_PHASE:
                localSled.tagReportPhase = cellValue;
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_RSSI:
                localSled.tagReportRSSI = cellValue;
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_SEEN_COUNT:
                localSled.tagReportSeenCount = cellValue;
                break;
            case ZT_VC_TAG_REPORT_CELL_TAG_REPORTUNIQUETAGS:
                localSled.isUniqueTagsReport = [NSNumber numberWithBool: cellValue];
                break;
        }
    }
    else if(YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int sled_mode = [(zt_PickerCellView*)option_cell getSelectedChoice];
        localSled.currentBatchMode = sled_mode;
        [m_cellBatchMode setData:(NSString *)[m_OptionsBatchMode objectAtIndex:sled_mode]];
    }
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return ZT_SLED_TAG_REPORT_PROPERTY_NUMBER;
    if(section == ZT_VC_TAG_REPORT_SECTION_IDX)
        return ZT_SLED_TAG_REPORT_PROPERTY_NUMBER;
    else if (section == ZT_VC_BATCH_MODE_SECTION_IDX)
        return 1 + ((m_PickerCellIdx != -1) ? 1 : 0);
    else if (section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
        return 1 ;
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == ZT_VC_TAG_REPORT_SECTION_IDX)
        return @"Tag report data fields";
    else if(section == ZT_VC_BATCH_MODE_SECTION_IDX)
        return @"Batch Mode Setings";
    else if(section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
        return @"Unique tag settings";
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    CGFloat height = 0.0;
    
    UITableViewCell *cell = nil;
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX)
    {
        
        [self configureSwitchCell:m_OffscreenSwitchCell forRow:indexPath];
        cell = m_OffscreenSwitchCell;
    }
    else if(indexPath.section == ZT_VC_BATCH_MODE_SECTION_IDX)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            cell = m_cellPicker;
        }
        else
            cell = m_cellBatchMode;
    }
        else if(indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
      {
        [self configureSwitchCell:m_OffscreenSwitchCell forRow:indexPath];
        cell = m_OffscreenSwitchCell;
        
      }
    if(cell != nil)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1.0; /* for cell separator */
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    if(indexPath.section == ZT_VC_TAG_REPORT_SECTION_IDX)
    {
        zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            // toDo autorelease
            _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
        }
        
        [self configureSwitchCell:_cell forRow:indexPath];
        
        [_cell setNeedsUpdateConstraints];
        [_cell updateConstraintsIfNeeded];
        
        return _cell;
    }
    else if (indexPath.section == ZT_VC_BATCH_MODE_SECTION_IDX)
    {
        if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
        {
            return m_cellPicker;
        }
        else
            return m_cellBatchMode;
    }
else if (indexPath.section == ZT_VC_REPORTUNIQUETAGS_SECTION_IDX)
    {
        zt_SwitchCellView *_cell = [tableView dequeueReusableCellWithIdentifier:ZT_CELL_ID_SWITCH forIndexPath:indexPath];
        
        if (_cell == nil)
        {
            _cell = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
        }
        
        [self configureSwitchCell:_cell forRow:indexPath];
        
        [_cell setNeedsUpdateConstraints];
        [_cell updateConstraintsIfNeeded];
        
        return _cell;
    }
    return nil;
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
    int row_to_hide = -1;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int main_cell_idx = -1;
    
    /* enable view animation that was disabled during
     switching between segments - see configureForSelectedOperation */
    [UIView setAnimationsEnabled:YES];
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    if (ZT_VC_BATCH_MODE_SECTION_IDX == indexPath.section)
    {
        int sled_mode = localSled.currentBatchMode;
        [m_cellPicker setSelectedChoice:sled_mode];
        main_cell_idx = 0;
    }
    
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        
        if (-1 != row_to_hide)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:ZT_VC_BATCH_MODE_SECTION_IDX]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ((main_cell_idx + 1) != _picker_cell_idx)
        {
            m_PickerCellIdx = main_cell_idx + 1;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:ZT_VC_BATCH_MODE_SECTION_IDX]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:ZT_VC_BATCH_MODE_SECTION_IDX] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

@end
