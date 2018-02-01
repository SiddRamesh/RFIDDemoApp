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
 *  Description:  PowerManagementVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ui_config.h"
#import "PowerManagementVC.h"
#import "RfidAppEngine.h"

/* Table sections */
#define ZT_VC_PWR_MANAGEMENT_SECTION_DYNAMIC_POWER    0

/* Table row tags */
#define ZT_VC_PWR_MANAGEMENT_CELL_TAG_DYNAMIC_POWER   0

#define ZT_VC_PWR_MANAGEMENT_OPTION_ID_NOT_AN_OPTION -1

@interface zt_PowerManagementVC ()
    @property zt_SledConfiguration *localSled;
@end

@implementation zt_PowerManagementVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self createPreconfiguredOptionCells];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_cellDynamicPowerOptimization)
    {
        [m_cellDynamicPowerOptimization release];
    }
    
    [m_tblOptions release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_localSled setDpoOptionsWithConfig:[[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] getDpoConfig]];
    
    [m_tblOptions setDelegate:self];
    [m_tblOptions setDataSource:self];
    [m_tblOptions registerClass:[zt_SwitchCellView class] forCellReuseIdentifier:ZT_CELL_ID_SWITCH];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblOptions setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Power Optimization"];
    
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

- (void)createPreconfiguredOptionCells
{
    m_cellDynamicPowerOptimization = [[zt_SwitchCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_SWITCH];
    
    [m_cellDynamicPowerOptimization setSelectionStyle:UITableViewCellSelectionStyleNone];
    [m_cellDynamicPowerOptimization setInfoNotice:ZT_STR_SETTINGS_PWR_MANAGEMENT_DYNAMIC_POWER];
    [m_cellDynamicPowerOptimization setCellTag:ZT_VC_PWR_MANAGEMENT_CELL_TAG_DYNAMIC_POWER];
    [m_cellDynamicPowerOptimization setDelegate:self];
}

- (void)setupConfigurationInitial
{
    /* TBD: configure based on app / reader settings */
    zt_SledConfiguration *configuration = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
    
    [m_cellDynamicPowerOptimization setOption:[[configuration currentDpoEnable] boolValue]];
    
}

/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case ZT_VC_PWR_MANAGEMENT_SECTION_DYNAMIC_POWER:
            return @"Dynamic Power Optimization configures the reader for best battery life and works with pre-configured settings.\n\nDynamic Power Optimization works only for inventory operation with no select commands.";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    UITableViewCell *cell = nil;
    
    int cell_idx = (int)[indexPath row];
    
    if (ZT_VC_PWR_MANAGEMENT_CELL_TAG_DYNAMIC_POWER == cell_idx)
    {
        cell = m_cellDynamicPowerOptimization;
    }
    
    if (nil != cell)
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
    int cellTag = (int)[indexPath row];
    
    if (ZT_VC_PWR_MANAGEMENT_CELL_TAG_DYNAMIC_POWER == cellTag)
    {
        return m_cellDynamicPowerOptimization;
    }

    return nil;
}


/* ###################################################################### */
/* ########## IOptionCellDelegate Protocol implementation ############### */
/* ###################################################################### */
- (void)didChangeValue:(id)option_cell
{
    int cellTag = [option_cell getCellTag];
    
    if (ZT_VC_PWR_MANAGEMENT_CELL_TAG_DYNAMIC_POWER == cellTag)
    {
        BOOL dynamicPowerOptimizationEnabled = [(zt_SwitchCellView*)option_cell getOption];
        
        zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        
        localSled.currentDpoEnable = [NSNumber numberWithBool:dynamicPowerOptimizationEnabled];
    }
}



@end
