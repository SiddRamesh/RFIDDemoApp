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
 *  Description:  FilterConfigVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "FilterConfigVC.h"

#define ZT_VC_FILTER_CELL_IDX_TAG_ID              0
#define ZT_VC_FILTER_CELL_IDX_MEMORY              1
#define ZT_VC_FILTER_CELL_IDX_OFFSET              2
#define ZT_VC_FILTER_CELL_IDX_ACTION              3
#define ZT_VC_FILTER_CELL_IDX_TARGET              4
#define ZT_VC_FILTER_CELL_IDX_ENABLED             5

#define ZT_VC_FILTER_OPTION_ID_NOT_AN_OPTION      -1
#define ZT_VC_FILTER_OPTION_ID_TARGET             0
#define ZT_VC_FILTER_OPTION_ID_ACTION             1

#define ZT_VC_FILTER_CELL_TAG_TAG_ID              0
#define ZT_VC_FILTER_CELL_TAG_PASSWORD            1
#define ZT_VC_FILTER_CELL_TAG_OFFSET              2
#define ZT_VC_FILTER_CELL_TAG_ENABLED             3

#define ZT_OFFSET_MIN                               0
#define ZT_OFFSET_MAX                               1024
#define ZT_OFFSET_DEFAULT                           0

@interface zt_FilterConfigVC ()

@end

@implementation zt_FilterConfigVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_PickerCellIdx = -1;
        
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_NOT_AN_OPTION;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    [m_segFilters release];
    [m_tblFilterOptions release];
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    if (nil != m_cellTagId)
    {
        [m_cellTagId release];
    }
    if (nil != m_cellMemoryBank)
    {
        [m_cellMemoryBank release];
    }
    if (nil != m_cellOffset)
    {
        [m_cellOffset release];
    }
    if (nil != m_cellAction)
    {
        [m_cellAction release];
    }
    if (nil != m_cellTarget)
    {
        [m_cellTarget release];
    }
    if (nil != m_cellPicker)
    {
        [m_cellPicker release];
    }
    if (nil != m_cellEnabled)
    {
        [m_cellEnabled release];
    }

    if (nil != m_strTagIdOne)
    {
        [m_strTagIdOne release];
    }
    if (nil != m_strTagIdTwo)
    {
        [m_strTagIdTwo release];
    }
    if (nil != m_strOffsetOne)
    {
        [m_strOffsetOne release];
    }
    if (nil != m_strOffsetTwo)
    {
        [m_strOffsetTwo release];	
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Setup the DPO button */
    self.navigationItem.rightBarButtonItem = barButtonDpo;
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    m_strTagIdOne = [[NSMutableString alloc] init];
    m_strTagIdTwo = [[NSMutableString alloc] init];
    m_strOffsetOne = [[NSMutableString alloc] init];
    m_strOffsetTwo = [[NSMutableString alloc] init];
    
    /* configure table view */
    [m_tblFilterOptions registerClass:[zt_TextFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    [m_tblFilterOptions registerClass:[zt_PickerCellView class] forCellReuseIdentifier:ZT_CELL_ID_PICKER];
    [m_tblFilterOptions registerClass:[zt_LabelInputFieldCellView class] forCellReuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    [m_tblFilterOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    [m_tblFilterOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblFilterOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    
    /* configure segments */
    [m_segFilters addTarget:self action:@selector(actionSelectedFilterChanged) forControlEvents:UIControlEventValueChanged];
    
    /* set title */
    [self setTitle:@"Pre Filters"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    CGFloat navigationbar_height = self.navigationController.navigationBar.bounds.size.height;
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_tblFilterOptions attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_tblFilterOptions attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c20];
    
    NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_tblFilterOptions attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c30];
    
    NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_segFilters attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_ACCESS_INDENT];
    [self.view addConstraint:c40];
    
    NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_segFilters attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_ACCESS_INDENT];
    [self.view addConstraint:c50];
    
    NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_segFilters attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_ACCESS_INDENT];
    [self.view addConstraint:c60];
    
    NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_segFilters attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:0.8*navigationbar_height];
    [self.view addConstraint:c70];
    
    NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_tblFilterOptions attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_segFilters attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_ACCESS_INDENT];
    [self.view addConstraint:c80];
    
    [self configureAppearance];
    
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
    
    [m_tblFilterOptions setDelegate:self];
    [m_tblFilterOptions setDataSource:self];
    
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTagIdChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOffsetFieldChange:) name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [m_tblFilterOptions setDelegate:nil];
    [m_tblFilterOptions setDataSource:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellTagId getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellOffset getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleTagIdChanged:(NSNotification *)notif
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int prefilterIdx = localSled.currentPrefilterIndex;
    NSMutableString *string = nil;
    if (prefilterIdx == 0)
    {
        string = [m_strTagIdOne retain];
    }
    else if(prefilterIdx == 1)
    {
        string = [m_strTagIdTwo retain];
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellTagId getCellData] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellTagId getCellData]] == NO)
        {
            [m_cellTagId setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellTagId setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellTagId getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    [string release];
}

- (void)handleOffsetFieldChange:(NSNotification *)notif
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int prefilterIdx = localSled.currentPrefilterIndex;
    NSMutableString *string = nil;
    if (prefilterIdx == 0)
    {
        string = [m_strOffsetOne retain];
    }
    else if(prefilterIdx == 1)
    {
        string = [m_strOffsetTwo retain];
    }
    
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellOffset getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellOffset getCellData]] == NO)
        {
            [m_cellOffset setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellOffset setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellOffset getTextField] undoManager] removeAllActions];
    }
    
    [_input release];
    [string release];
}

- (void)configureAppearance
{
    /* configure segmented control */
    [m_segFilters setTitle:@"Filter 1" forSegmentAtIndex:0];
    [m_segFilters setTitle:@"Filter 2" forSegmentAtIndex:1];
    
    [m_segFilters setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:
      [UIFont systemFontOfSize:ZT_UI_ACCESS_FONT_SZ_MEDIUM] forKey:NSFontAttributeName]
                                   forState:UIControlStateNormal];
    
    /* TBD: adjust font size for header of table view */
}

- (void)createPreconfiguredOptionCells
{
    m_cellTagId = [[zt_TextFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_TEXT_FIELD];
    m_cellMemoryBank = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellOffset = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_LABEL_TEXT_FIELD];
    m_cellPicker = [[zt_PickerCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_PICKER];
    m_cellEnabled = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    m_cellAction = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellTarget = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellTagId setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellOffset setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPicker setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellEnabled setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [m_cellEnabled setCellTag:ZT_VC_FILTER_CELL_TAG_ENABLED];
    [m_cellEnabled setDelegate:self];
    
    [m_cellTagId setCellTag:ZT_VC_FILTER_CELL_TAG_TAG_ID];
    [m_cellTagId setDelegate:self];

    [m_cellOffset setCellTag:ZT_VC_FILTER_CELL_TAG_OFFSET];
    [m_cellOffset setDelegate:self];
    
    [m_cellPicker setDelegate:self];
    
    [m_cellTagId setPlaceholder:@"Tag Pattern"];
    [m_cellMemoryBank setStyle:ZT_CELL_INFO_STYLE_BLUE];
    [m_cellMemoryBank setInfoNotice:@"Memory bank"];
    [m_cellOffset setInfoNotice:@"Offset"];
    [m_cellOffset setDataFieldWidth:30];
    [m_cellOffset setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellEnabled setInfoNotice:@"Filter"];
    [m_cellAction setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellAction setInfoNotice:@"Action"];
    [m_cellTarget setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellTarget setInfoNotice:@"Target"];
}

- (void)setupConfigurationInitial
{
    [[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] setCurrentPrefilterIndex:0];
    [m_segFilters setSelectedSegmentIndex:[[[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy] currentPrefilterIndex]];
    
    [self configureForSelectedFilter];
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

- (void)actionSelectedFilterChanged
{
    [self saveCurrentFilterConfiguration];
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    [localSled setCurrentPrefilterIndex:(int)[m_segFilters selectedSegmentIndex]];
    
    [self configureForSelectedFilter];
}

- (void)configureForSelectedFilter
{
    
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    int offset = [[localSled prefilterOffset] intValue];
    if (localSled.currentPrefilterIndex == 0)
    {
        [m_strTagIdOne setString:[localSled prefilterTagPattern]];
        
        if (offset == ZT_VC_EMPTY_FIELD)
            [m_strOffsetOne setString:@""];
        else
            [m_strOffsetOne setString:[NSString stringWithFormat:@"%@",[localSled prefilterOffset]]];
    }
    else if (localSled.currentPrefilterIndex == 1)
    {
        [m_strTagIdTwo setString:[localSled prefilterTagPattern]];
        
        if (offset == ZT_VC_EMPTY_FIELD)
            [m_strOffsetTwo setString:@""];
        else
            [m_strOffsetTwo setString:[NSString stringWithFormat:@"%@",[localSled prefilterOffset]]];
    }
    
    
    [m_cellTagId setData:[[localSled prefilterTagPattern] uppercaseString]];
    
    if (offset == ZT_VC_EMPTY_FIELD)
        [m_cellOffset setData:@""];
    else
        [m_cellOffset setData:[NSString stringWithFormat:@"%@", [localSled prefilterOffset]]];
    
    [m_cellEnabled setInfoNotice:[NSString stringWithFormat:@"Enable Filter %d", ([localSled currentPrefilterIndex] + 1)]];
    
    [m_cellEnabled setOption:[localSled prefilterEnabled]];
    
    [m_cellMemoryBank setData:[localSled prefilterMemoryBank]];
    
    [m_cellAction setData:[localSled prefilterAction]];
    
    [m_cellTarget setData:[localSled prefilterTagert]];
    
    /* hide picker cells */
    m_PickerCellIdx = -1;
    [m_tblFilterOptions reloadData];
}

- (void)saveCurrentFilterConfiguration
{
    /* 
        TBD: filter configuration shall be saved at app-level:
            - currently config is saved only to local variables from ui elements
        when switching between filters via segmented control
            - future solution: save config from ui to local variables when vc is popped 
        from navigation stack and save local variables at app-level 
        (singleton engine, settings, etc)
     */
    
    /* memory bank, action and target option ids (indexes) are saved directly on changes ->
     refer IOptionCellDelegate and ISelectionTableVCDelegate protocols implementations
     */
    
    /* tag id, password, offset and enabled are saved directly on changes ->
     refer IOptionCellDelegate protocols implementations */
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblFilterOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblFilterOptions.contentInset = contentInsets;
    m_tblFilterOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblFilterOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblFilterOptions.contentInset = contentInsets;
    m_tblFilterOptions.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

/* ###################################################################### */
/* ########## ISelectionTableVCDelegate Protocol implementation ######### */
/* ###################################################################### */
- (void)didChangeSelectedOption:(NSString *)value
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (ZT_VC_FILTER_OPTION_ID_ACTION == m_PresentedOptionId)
    {
        [localSled setPrefilterAction:value];
        [m_cellAction setData:value];
        
    }
    else if (ZT_VC_FILTER_OPTION_ID_TARGET == m_PresentedOptionId)
    {
        [localSled setPrefilterTarget:value];
        [m_cellTarget setData:value];
    }
}

/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (YES == [option_cell isKindOfClass:[zt_PickerCellView class]])
    {
        int option = [(zt_PickerCellView*)option_cell getSelectedChoice];
        NSString *value = [[local.mapperBankPrefilters getStringArray] objectAtIndex:option];
        
        [local setPrefilterMemoryBank:value];
        
        [m_cellMemoryBank setData:local.prefilterMemoryBank];
    }
    else if (YES == [option_cell isKindOfClass:[zt_SwitchCellView class]])
    {
        BOOL cell_value = [(zt_SwitchCellView*)option_cell getOption];
        [local setPrefilterEnabled:cell_value];
    }
    else  if (YES == [option_cell isKindOfClass:[zt_TextFieldCellView class]])
    {
        zt_TextFieldCellView *_cell = (zt_TextFieldCellView*)option_cell;
        if (ZT_VC_FILTER_CELL_TAG_TAG_ID == [_cell getCellTag])
        {
            [local setPrefilterTagPattern:[_cell getCellData]];
        }
    }
    else if (YES == [option_cell isKindOfClass:[zt_LabelInputFieldCellView class]])
    {
        zt_LabelInputFieldCellView *_cell = (zt_LabelInputFieldCellView*)option_cell;
        if (ZT_VC_FILTER_CELL_TAG_OFFSET == [_cell getCellTag])
        {
            if ([@"" length] == [[_cell getCellData] length])
                [local setPrefilterOffset:[NSNumber numberWithInt:ZT_VC_EMPTY_FIELD]];
            else
                [local setPrefilterOffset:[NSNumber numberWithInt:[[_cell getCellData] intValue]]];
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
    return 6 + ((m_PickerCellIdx != -1) ? 1 : 0);
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
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TAG_ID] == cell_idx)
    {
        cell = m_cellTagId;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        cell = m_cellMemoryBank;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_OFFSET] == cell_idx)
    {
        cell = m_cellOffset;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        cell = m_cellAction;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        cell = m_cellTarget;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ENABLED] == cell_idx)
    {
        cell = m_cellEnabled;
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
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TAG_ID] == cell_idx)
    {
        return m_cellTagId;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        return m_cellMemoryBank;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_OFFSET] == cell_idx)
    {
        return m_cellOffset;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        return m_cellAction;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        return m_cellTarget;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ENABLED] == cell_idx)
    {
        return m_cellEnabled;
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
    zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_MEMORY] == cell_idx)
    {
        NSMutableArray *memory_banks = [local.mapperBankPrefilters getStringArray];
        [m_cellPicker setChoices:memory_banks];
        
        [m_cellPicker setSelectedChoice:[[zt_SledConfiguration getKeyFromDictionary:[local.mapperBankPrefilters getDictionary] withValue:[local prefilterMemoryBank]] intValue] - 1];
        
        main_cell_idx = ZT_VC_FILTER_CELL_IDX_MEMORY;
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
    
    /* check whether additional table view with list of options shall be presented */
    BOOL _need_present_options = NO;
    
    if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_TARGET] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_TARGET;
        _need_present_options = YES;
    }
    else if ([self recalcCellIndex:ZT_VC_FILTER_CELL_IDX_ACTION] == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_FILTER_OPTION_ID_ACTION;
        _need_present_options = YES;
    }
    
    if (YES == _need_present_options)
    {
        zt_SelectionTableVC *vc = (zt_SelectionTableVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SELECTION_TABLE_VC"];
        [vc setDelegate:self];
        
        int selectedOption = 0;
        
        if (ZT_VC_FILTER_OPTION_ID_ACTION == m_PresentedOptionId)
        {
            [vc setCaption:@"Action"];
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            int dictionarySize =(int)[[local.mapperAction getDictionary] count];
            for (int i=0; i < dictionarySize; i++) {
                [actions addObject:[[local.mapperAction getDictionary] objectForKey:[NSNumber numberWithInt:i]]];
            }
            
            
            selectedOption = [[zt_SledConfiguration getKeyFromDictionary:[local.mapperAction getDictionary] withValue:[local prefilterAction]] intValue];

            [vc setOptionsWithStringArray:actions];
        }
        else if (ZT_VC_FILTER_OPTION_ID_TARGET == m_PresentedOptionId)
        {
            [vc setCaption:@"Target"];
            
            NSMutableArray *targets = [local.mapperTargetOption getStringArray];
            
            selectedOption = [[zt_SledConfiguration getKeyFromDictionary:[local.mapperTargetOption getDictionary] withValue:[local prefilterTagert]] intValue];
            
            [vc setOptionsWithStringArray:targets];
        }
        [vc setSelectedOptionInt:selectedOption];
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    //[self.view endEditing:YES];
}

/* ###################################################################### */
/* ########## Text View Delegate Protocol implementation ################ */
/* ###################################################################### */
- (void)textViewDidChange:(UITextView *)textView
{
    /* update text view and cell height dynamically */
    [m_tblFilterOptions beginUpdates];
    [m_tblFilterOptions endUpdates];
    /* TBD: scroll to cursor position ??? */
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    /* scroll to cursor position */
    CGRect cursor_rect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursor_rect = [m_tblFilterOptions convertRect:cursor_rect fromView:textView];
    cursor_rect.size.height += 8;
    [m_tblFilterOptions scrollRectToVisible:cursor_rect animated:YES];
}


@end
