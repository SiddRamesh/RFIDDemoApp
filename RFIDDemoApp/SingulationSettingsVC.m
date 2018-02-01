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
 *  Description:  SingulationSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "SingulationSettingsVC.h"

#define ZT_VC_SINGULATION_CELL_IDX_SESSION            0
#define ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION     1
#define ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE    2
#define ZT_VC_SINGULATION_CELL_IDX_SLFLAG             3

@interface zt_SingulationSettingsVC ()

@property (nonatomic) NSArray *sessionChoices;
@property (nonatomic) NSArray *stateChoices;
@property (nonatomic) NSArray *flagChoices;
@property (nonatomic) NSArray *tagPopulationChoices;

@end

/* TBD: save & apply (?) configuration during hide */
@implementation zt_SingulationSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [m_tblSingulationOptions release];

    if (nil != m_cellSession)
    {
        [m_cellSession release];
    }
    if (nil != m_cellTagPopulation)
    {
        [m_cellTagPopulation release];
    }
    if (nil != m_cellInventoryState)
    {
        [m_cellInventoryState release];
    }
    if (nil != m_cellSlFlag)
    {
        [m_cellSlFlag release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    
    if (nil != _sessionChoices)
    {
        [_sessionChoices release];
    }
    if (nil != _stateChoices)
    {
        [_stateChoices release];
    }
    if (nil != _flagChoices)
    {
        [_flagChoices release];
    }
    
    if (nil != _tagPopulationChoices)
    {
        [_tagPopulationChoices release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* configure table view */
    [m_tblSingulationOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [m_tblSingulationOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [m_tblSingulationOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];

    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblSingulationOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Singulation Control"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_tblSingulationOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_tblSingulationOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_tblSingulationOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_tblSingulationOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c4];
    
    [self setupConfigurationInitial];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [m_tblSingulationOptions setDelegate:self];
    [m_tblSingulationOptions setDataSource:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_tblSingulationOptions setDelegate:nil];
    [m_tblSingulationOptions setDataSource:nil];
}

- (void)createPreconfiguredOptionCells
{
    m_cellTagPopulation = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellSession = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_cellInventoryState = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellSlFlag = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [m_cellPicker setDelegate:self];
    
    [m_cellTagPopulation setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellTagPopulation setInfoNotice:@"Tag Population"];
    [m_cellSession setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellSession setInfoNotice:@"Session"];
    [m_cellInventoryState setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellInventoryState setInfoNotice:@"Inventory State"];
    [m_cellSlFlag setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellSlFlag setInfoNotice:@"SL Flag"];
}

- (void)setupConfigurationInitial
{
    /* TBD: configure based on app / reader settings */
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    SRFID_SESSION session_selected = configuration.currentSession;
    [m_cellSession setData:[configuration.mapperSession getStringByEnum:session_selected]];
    
    SRFID_INVENTORYSTATE state_selected = configuration.currentInventoryState;
    [m_cellInventoryState setData:[configuration.mapperInventoryState getStringByEnum:state_selected]];
    
    SRFID_SLFLAG flag_selected = configuration.currentSLFLag;
    [m_cellSlFlag setData:[configuration.mapperSLFlag getStringByEnum:flag_selected]];
    
    int tag_population = configuration.currentTagPopulation;
    [m_cellTagPopulation setData:[configuration.mapperTagPopulation getStringByEnum:tag_population]];
    
    _sessionChoices = [[configuration.mapperSession getStringArray] mutableCopy];
    
    _stateChoices = [[configuration.mapperInventoryState getStringArray] mutableCopy];
    
    _flagChoices = [[configuration.mapperSLFlag getStringArray] mutableCopy];
    
    _tagPopulationChoices = [[configuration.mapperTagPopulation getStringArray] mutableCopy];
}

- (int)recalcCellIndex:(int)cell_index
{
    if (-1 == m_PickerCellIdx)
    {
        return cell_index;
    }
    else
    {
        if (cell_index < m_PickerCellIdx)
        {
            return cell_index;
        }
        else
        {
            return (cell_index + 1);
        }
    }
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int choice = [(zt_PickerCellView*)option_cell getSelectedChoice];
        
        if (ZT_VC_SINGULATION_CELL_IDX_SESSION == (m_PickerCellIdx - 1))
        {
            NSString *value = _sessionChoices[choice];
            localSled.currentSession = [localSled.mapperSession getEnumByIndx:choice];
            [m_cellSession setData:value];
        }
        else if (ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE == (m_PickerCellIdx - 1))
        {
            NSString *value = _stateChoices[choice];
            int enumValue = [localSled.mapperInventoryState getEnumByIndx:choice];
            localSled.currentInventoryState = enumValue;
            [m_cellInventoryState setData:value];
        }
        else if (ZT_VC_SINGULATION_CELL_IDX_SLFLAG == (m_PickerCellIdx - 1))
        {
            NSString *value = _flagChoices[choice];
            localSled.currentSLFLag = [localSled.mapperSLFlag getEnumByIndx:choice];
            [m_cellSlFlag setData:value];
        }
        else if (ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION == (m_PickerCellIdx - 1))
        {
            NSString *value = _tagPopulationChoices[choice];
            localSled.currentTagPopulation = [localSled.mapperTagPopulation getEnumByIndx:choice];
            [m_cellTagPopulation setData:value];
        }
    }
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
    return 4 + ((m_PickerCellIdx != -1) ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    CGFloat height = 0.0;
    UITableViewCell *cell = nil;
    
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        cell = m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE] == cell_idx)
    {
        cell = m_cellInventoryState;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SESSION] == cell_idx)
    {
        cell = m_cellSession;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SLFLAG] == cell_idx)
    {
        cell = m_cellSlFlag;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION] == cell_idx)
    {
        cell = m_cellTagPopulation;
    }
    
    if (nil != cell)
    {
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        //cell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(m_tblFilterOptions.bounds), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        
        height += 1.0;
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    if (-1 != m_PickerCellIdx && cell_idx == m_PickerCellIdx)
    {
        return m_cellPicker;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE] == cell_idx)
    {
        return m_cellInventoryState;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SESSION] == cell_idx)
    {
        return m_cellSession;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SLFLAG] == cell_idx)
    {
        return m_cellSlFlag;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION] == cell_idx)
    {
        return m_cellTagPopulation;
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
    int cell_idx = (int)[indexPath row];
    int row_to_hide = -1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int main_cell_idx = -1;
    
    /* expected index for new picker cell */
    row_to_hide = m_PickerCellIdx;
    
    zt_SledConfiguration *config = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SESSION] == cell_idx)
    {
        [m_cellPicker setChoices:_sessionChoices];
        [m_cellPicker setSelectedChoice:[config.mapperSession getIndxByEnum:config.currentSession]];
        main_cell_idx = ZT_VC_SINGULATION_CELL_IDX_SESSION;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE] == cell_idx)
    {
        [m_cellPicker setChoices:_stateChoices];
        [m_cellPicker setSelectedChoice:[config.mapperInventoryState getIndxByEnum:config.currentInventoryState]];
        main_cell_idx = ZT_VC_SINGULATION_CELL_IDX_INVENTORY_STATE;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_SLFLAG] == cell_idx)
    {
        [m_cellPicker setChoices:_flagChoices];
        [m_cellPicker setSelectedChoice:[config.mapperSLFlag getIndxByEnum:[config currentSLFLag]]];
        main_cell_idx = ZT_VC_SINGULATION_CELL_IDX_SLFLAG;
    }
    else if ([self recalcCellIndex:ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION] == cell_idx)
    {
        [m_cellPicker setChoices:_tagPopulationChoices];
        [m_cellPicker setSelectedChoice:[config.mapperTagPopulation getIndxByEnum:config.currentTagPopulation]];
        main_cell_idx = ZT_VC_SINGULATION_CELL_IDX_TAG_POPULATION;
    }
    if (-1 != main_cell_idx)
    {
        int _picker_cell_idx = m_PickerCellIdx;
        
        if (-1 != row_to_hide)
        {
            m_PickerCellIdx = -1; // required for adequate assessment of number of rows during delete operation
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row_to_hide inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        /* if picker was not shown for this cell -> let's show it */
        if ((main_cell_idx + 1) != _picker_cell_idx)
        {
            m_PickerCellIdx = main_cell_idx + 1;
        }
        
        if (m_PickerCellIdx != -1)
        {
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:m_PickerCellIdx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    //[self.view endEditing:YES];
}

@end
