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
 *  Description:  AntennaSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AntennaSettingsVC.h"
#import "RfidAppEngine.h"
#import "ui_config.h"

#define ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL            0
#define ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE           1
#define ZT_VC_ANTENNA_CELL_IDX_TARI                   2
#define ZT_VC_ANTENNA_CELL_IDX_DO_SELECT              3

#define ZT_VC_ANTENNA_OPTION_ID_NOT_AN_OPTION         -1
#define ZT_VC_ANTENNA_OPTION_ID_POWER_LEVEL           0
#define ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE          1
#define ZT_VC_ANTENNA_OPTION_ID_TARI                  2
#define ZT_VC_ANTENNA_OPTION_ID_DO_SELECT             3

@interface zt_AntennaSettingsVC ()
    @property zt_SledConfiguration *localSled;
@end

/* TBD: save & apply (?) configuration during hide */
@implementation zt_AntennaSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {

        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_NOT_AN_OPTION;
        
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_cellLinkProfile)
    {
        [m_cellLinkProfile release];
    }
    if (nil != m_cellPowerLevel)
    {
        [m_cellPowerLevel release];
    }
    if (nil != m_cellTari)
    {
        [m_cellTari release];
    }
    if (nil != m_cellDoSelect)
    {
        [m_cellDoSelect release];
    }
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    [m_tblOptions release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_localSled setAntennaOptionsWithConfig:[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getAntennaConfig]];
    
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_InfoCellView class] forCellReuseIdentifier:ZT_CELL_ID_INFO];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Antenna"];
    
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
    
    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    [self setupConfigurationInitial];
}

- (void) viewWillAppear:(BOOL)animated
{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePowerLevelChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellPowerLevel getTextField]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTariChanged:) name:UITextFieldTextDidChangeNotification object:[m_cellTari getTextField]];
    /* just for auto scroll on keyboard events */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellPowerLevel getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:[m_cellTari getTextField]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if([[m_cellPowerLevel getCellData] length]>0)
    {
        NSString * floatString = [m_cellPowerLevel getCellData];
        configuration.currentAntennaPowerLevel = [floatString floatValue];
    }
    if([[m_cellTari getCellData] length]>0)
    {
        
        NSString * floatString = [m_cellTari getCellData];
        configuration.currentAntennaTari = [floatString floatValue];        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPreconfiguredOptionCells
{
    m_cellPowerLevel = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    [m_cellPowerLevel setKeyboardType:UIKeyboardTypeDecimalPad];
    m_cellLinkProfile = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    m_cellTari = [[zt_LabelInputFieldCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    m_cellDoSelect = [[zt_InfoCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_INFO];
    
    [m_cellPowerLevel setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellPowerLevel setDataFieldWidth:40];
    [m_cellPowerLevel setInfoNotice:ZT_STR_SETTINGS_ANTENNA_POWER_LEVEL];
    [m_cellLinkProfile setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellLinkProfile setInfoNotice:ZT_STR_SETTINGS_ANTENNA_LINK_PROFILE];
    
    [m_cellTari setKeyboardType:UIKeyboardTypeDecimalPad];
    [m_cellTari setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellTari setDataFieldWidth:40];
    [m_cellTari setInfoNotice:ZT_STR_SETTINGS_ANTENNA_TARI];
    
    [m_cellDoSelect setStyle:ZT_CELL_INFO_STYLE_GRAY_DISCLOSURE_INDICATOR];
    [m_cellDoSelect setInfoNotice:ZT_STR_SETTINGS_ANTENNA_DO_SELECT];
}

- (void)setupConfigurationInitial
{
    /* TBD: configure based on app / reader settings */
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    NSNumber *powerLevelKey = [NSNumber numberWithInt:configuration.currentAntennaPowerLevel];
    //[m_cellPowerLevel setData:[NSString stringWithFormat:@"%1.1f",[powerLevelKey floatValue]]];
    [m_cellPowerLevel setData:[NSString stringWithFormat:@"%1.0f",[powerLevelKey floatValue]]];
    NSNumber *linkProfileKey = [NSNumber numberWithInt:configuration.currentAntennaLinkProfile];
    [m_cellLinkProfile setData:(NSString*)[configuration.antennaOptionsLinkProfile objectForKey:linkProfileKey]];
    
    NSNumber *tari = [NSNumber numberWithInt:configuration.currentAntennaTari];
    [m_cellTari setData:[NSString stringWithFormat:@"%@",tari]];
    
    NSNumber *doSelectKey = [NSNumber numberWithInt:configuration.currentAntennaDoSelect];
    [m_cellDoSelect setData:(NSString*)[configuration.antennaOptionsDoSelect objectForKey:doSelectKey]];
    
}
/* ###################################################################### */
/* ########## ISelectionTableVCDelegate Protocol implementation ######### */
/* ###################################################################### */
- (void)didChangeSelectedOption:(NSString *)value
{
    zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    if (ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE == m_PresentedOptionId)
    {
        //using config sled for existing antenna link profile options
        localSled.currentAntennaLinkProfile = [[zt_SledConfiguration getKeyFromDictionary:localSled.antennaOptionsLinkProfile withValue:value] intValue];
        NSNumber *linkProfileKey = [NSNumber numberWithInt:localSled.currentAntennaLinkProfile];
        [m_cellLinkProfile setData:(NSString*)[localSled.antennaOptionsLinkProfile objectForKey:linkProfileKey]];
    }
    else if (ZT_VC_ANTENNA_OPTION_ID_DO_SELECT == m_PresentedOptionId)
    {
        localSled.currentAntennaDoSelect = [[zt_SledConfiguration getKeyFromDictionary:localSled.antennaOptionsDoSelect withValue:value] boolValue];
        NSNumber *doSelectKey = [NSNumber numberWithInt:localSled.currentAntennaTari];
        [m_cellDoSelect setData:(NSString*)[localSled.antennaOptionsDoSelect objectForKey:doSelectKey]];
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
    // change to 4 for tari and do select options
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    UITableViewCell *_info_cell = nil;
    
    int cell_idx = (int)[indexPath row];
    
    if (ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE == cell_idx)
    {
        _info_cell = m_cellLinkProfile;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL == cell_idx)
    {
        _info_cell = m_cellPowerLevel;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_TARI == cell_idx)
    {
        _info_cell = m_cellTari;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_DO_SELECT == cell_idx)
    {
        _info_cell = m_cellDoSelect;
    }
    
    if (nil != _info_cell)
    {
        [_info_cell setNeedsUpdateConstraints];
        [_info_cell updateConstraintsIfNeeded];
        
        [_info_cell setNeedsLayout];
        [_info_cell layoutIfNeeded];
        
        height = [_info_cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1.0; /* for cell separator */
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cell_idx = (int)[indexPath row];
    
    if (ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE == cell_idx)
    {
        return m_cellLinkProfile;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL == cell_idx)
    {
        return m_cellPowerLevel;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_TARI == cell_idx)
    {
        return m_cellTari;
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_DO_SELECT == cell_idx)
    {
        return m_cellDoSelect;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int cell_idx = (int)[indexPath row];
    
    zt_SelectionTableVC *vc = (zt_SelectionTableVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SELECTION_TABLE_VC"];
    [vc setDelegate:self];

    
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    if (ZT_VC_ANTENNA_CELL_IDX_LINK_PROFILE == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_LINK_PROFILE;
        [vc setCaption:ZT_STR_SETTINGS_ANTENNA_LINK_PROFILE];
        [vc setOptionsWithStringArray:[configuration getLinkProfileArray]];
        NSNumber *linkProfileKey = [NSNumber numberWithInt:configuration.currentAntennaLinkProfile];
        [vc setSelectedValue:(NSString*)[configuration.antennaOptionsLinkProfile objectForKey:linkProfileKey]];
    }
    else if (ZT_VC_ANTENNA_CELL_IDX_DO_SELECT == cell_idx)
    {
        m_PresentedOptionId = ZT_VC_ANTENNA_OPTION_ID_DO_SELECT;
        [vc setCaption:ZT_STR_SETTINGS_ANTENNA_DO_SELECT];
        [vc setOptionsWithDictionary:configuration.antennaOptionsDoSelect withStringPrefix:nil];
        NSNumber *key = [NSNumber numberWithInt:configuration.currentAntennaDoSelect];
        [vc setSelectedValue:(NSString*)[configuration.antennaOptionsDoSelect objectForKey:key]];
    }
    else
    {
        if([[m_cellPowerLevel getCellData] length]>0)
            {
                NSString * floatString = [m_cellPowerLevel getCellData];
                configuration.currentAntennaPowerLevel = [floatString floatValue];
            }
            if([[m_cellTari getCellData] length]>0)
            {

                NSString * floatString = [m_cellTari getCellData];
                configuration.currentAntennaTari = [floatString floatValue];
            }
            else
            {
                NSLog(@"alert");
            }
    }
    if (ZT_VC_ANTENNA_CELL_IDX_POWER_LEVEL != cell_idx && ZT_VC_ANTENNA_OPTION_ID_TARI != cell_idx)
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void)handlePowerLevelChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellPowerLevel getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellPowerLevel getCellData]] == NO)
        {
            [m_cellPowerLevel setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellPowerLevel setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellPowerLevel getTextField] undoManager] removeAllActions];
    }
    [_input release];
    
}

- (BOOL)checkNumInput:(NSString *)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* :, 0 .. 9, A .. F */
        if ((_ch < 48) || (_ch > 57) )
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

- (void)handleTariChanged:(NSNotification *)notif
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_cellTari getCellData] uppercaseString]];
    
    if ([self checkNumInput:_input] == YES)
    {
        [string setString:_input];
        if ([string isEqualToString:[m_cellTari getCellData]] == NO)
        {
            [m_cellTari setData:string];
        }
    }
    else
    {
        /* restore previous one */
        [m_cellTari setData:string];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[[m_cellTari getTextField] undoManager] removeAllActions];
    }
    [_input release];
    
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOptions.contentInset.top, 0.0, kbSize.height, 0.0);
    m_tblOptions.contentInset = contentInsets;
    m_tblOptions.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(m_tblOptions.contentInset.top, 0.0, 0.0, 0.0);
    m_tblOptions.contentInset = contentInsets;
    m_tblOptions.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}


@end
