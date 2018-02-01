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
 *  Description:  InventoryVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "InventoryVC.h"
#import "config.h"
#import "ui_config.h"
#import "AlertView.h"

// toDo check if inventory public header
#import "InventoryItem.h"

#define ZT_INVENTORY_CFG_OPTION_COUNT        5

#define ZT_INVENTORY_TIMER_INTERVAL          0.2

@interface zt_InventoryVC ()

@end

@implementation zt_InventoryVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_standartCellHeight = -1;
        
        m_OffscreenTagCell = [[zt_RFIDTagCellView alloc] init];
        m_ExpandedCellIdx = -1;
        
        m_btnOptions = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(btnOptionsPressed)];
        
        m_Mapper = [[zt_EnumMapper alloc] initWithMEMORYBANKMapperForInventory];
        
        m_InventoryOptions = [[m_Mapper getStringArray] retain];
        
        m_SelectedInventoryOption = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryMemoryBankUI];
        [m_btnOptions setTitle:[m_Mapper getStringByEnum:m_SelectedInventoryOption]];
        
        m_Tags = [[NSMutableArray alloc] init];
        
        m_SearchString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [m_lblHeader release];
    [m_txtSearch release];
    [m_lblUniqueTagsNotice release];
    [m_lblUniqueTagsData release];
    [m_lblTotalTagsNotice release];
    [m_lblTotalTagsData release];
    [m_tblTags release];
    [m_btnStartStop release];
    
    if(nil != m_Mapper)
    {
        [m_Mapper release];
    }
    
    if (nil != m_Tags)
    {
        [m_Tags removeAllObjects];
        [m_Tags release];
    }
    
    if (nil != m_OffscreenTagCell)
    {
        [m_OffscreenTagCell release];
    }
    
    if (nil != m_btnOptions)
    {
        [m_btnOptions release];
    }
    
    if (nil != m_InventoryOptions)
    {
        [m_InventoryOptions removeAllObjects];
        [m_InventoryOptions release];
    }
    
    if (nil != m_SearchString)
    {
        [m_SearchString release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    /* set title */
    [self.tabBarController setTitle:@"Inventory"];
    
    [m_tblTags setDelegate:self];
    [m_tblTags setDataSource:self];
    [m_tblTags registerClass:[zt_RFIDTagCellView class] forCellReuseIdentifier:ZT_CELL_ID_TAG_DATA];
    
    /* Inventory in batch mode label */
    batchModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, 500, 50)];
    batchModeLabel.hidden = YES;
    batchModeLabel.text = @"Inventory running in Batch Mode";
    [self.view addSubview:batchModeLabel];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblTags setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    [m_txtSearch setDelegate:self];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
    CGFloat tabbar_height = self.tabBarController.tabBar.bounds.size.height;
    
    /* nrv364: navigation bar height is 0 when is presented from home vc */
    CGFloat navigationbar_height = tabbar_height; //self.tabBarController.navigationController.navigationBar.bounds.size.height;
    
    //CGFloat height = self.view.bounds.size.height - tabbar_height - navigationbar_height;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat paddingS = 0.017*width;
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:tabbar_height];
    [self.view addConstraint:c4];
    
    NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_tblTags attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_btnStartStop attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c5];
    
    NSLayoutConstraint *c6 = [NSLayoutConstraint constraintWithItem:m_tblTags attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c6];
    
    NSLayoutConstraint *c7 = [NSLayoutConstraint constraintWithItem:m_tblTags attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c7];

    NSLayoutConstraint *c8 = [NSLayoutConstraint constraintWithItem:m_lblHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c8];
    
    NSLayoutConstraint *c9 = [NSLayoutConstraint constraintWithItem:m_lblHeader attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c9];
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblHeader attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c11 = [NSLayoutConstraint constraintWithItem:m_lblHeader attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:1.0*navigationbar_height];
    [self.view addConstraint:c11];
    
    /* constant due to offset for shadow */
    NSLayoutConstraint *c12 = [NSLayoutConstraint constraintWithItem:m_tblTags attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.05*navigationbar_height];
    [self.view addConstraint:c12];
    
    NSLayoutConstraint *c13 = [NSLayoutConstraint constraintWithItem:m_txtSearch attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeLeading multiplier:1.0 constant:paddingS];
    [self.view addConstraint:c13];
    
    NSLayoutConstraint *c14 = [NSLayoutConstraint constraintWithItem:m_txtSearch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.1489*navigationbar_height];
    [self.view addConstraint:c14];
    
    NSLayoutConstraint *c15 = [NSLayoutConstraint constraintWithItem:m_txtSearch attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.1489*navigationbar_height];
    [self.view addConstraint:c15];
    
    NSLayoutConstraint *c161 = [NSLayoutConstraint constraintWithItem:m_txtSearch attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.5 * width];
    [self.view addConstraint:c161];
 
    NSLayoutConstraint *c17 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-paddingS];
    [self.view addConstraint:c17];
    
    NSLayoutConstraint *c18 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    [self.view addConstraint:c18];
    
    NSLayoutConstraint *c19 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.1489*navigationbar_height];
    [self.view addConstraint:c19];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeHeight multiplier:0.234 constant:0.0];
    [self.view addConstraint:c20];
    
    NSLayoutConstraint *c21 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-paddingS];
    [self.view addConstraint:c21];
    
    NSLayoutConstraint *c22 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:m_txtSearch attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:paddingS];
    [self.view addConstraint:c22];
    
    NSLayoutConstraint *c23 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:c23];
    
    NSLayoutConstraint *c24 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c24];
    
    NSLayoutConstraint *c25 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0638*navigationbar_height];
    [self.view addConstraint:c25];
    
    NSLayoutConstraint *c26 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblHeader attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.1489*navigationbar_height];
    [self.view addConstraint:c26];
    
    NSLayoutConstraint *c27 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c27];
    
    NSLayoutConstraint *c28 = [NSLayoutConstraint constraintWithItem:m_lblTotalTagsData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsNotice attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c28];
    
    NSLayoutConstraint *c29 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:m_txtSearch attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.01492*width];
    [self.view addConstraint:c29];
    
    NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c30];
    
    NSLayoutConstraint *c33 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblUniqueTagsNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:1.0];
    [self.view addConstraint:c33];
    
    NSLayoutConstraint *c31 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:c31];
    
    NSLayoutConstraint *c32 = [NSLayoutConstraint constraintWithItem:m_lblUniqueTagsData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTotalTagsData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c32];

    [self configureAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSearchFieldChanged:) name:UITextFieldTextDidChangeNotification object:m_txtSearch];
    
    /* add options button */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:m_btnOptions];
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
    
    /* set title */
    [self.tabBarController setTitle:@"Inventory"];

    /* load saved search criteria */
    [m_SearchString setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagSearchCriteria]];
    [m_txtSearch setText:m_SearchString];
    
    /* load saved selected index */
    m_ExpandedCellIdx = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getSelectedInventoryItemIndex];
    
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
            /* simple logic of radioStateChangedOperationRequested w/o cleaning of selected inventory item */
            [UIView performWithoutAnimation:^{
                [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
                [m_btnStartStop layoutIfNeeded];
            }];
            
            [m_btnOptions setEnabled:NO];
            
            [m_Tags removeAllObjects];
            
            [self updateOperationDataUI];
            
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
            if([[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
            {
                [m_Tags removeAllObjects];
                [m_tblTags reloadData];
                batchModeLabel.hidden = NO;
            }
        }
        else
        {
            [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_INVENTORY];
            [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_INVENTORY];
        }
    }
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:m_txtSearch];
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
    
}

- (void)handleSearchFieldChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[[NSMutableString alloc] init] autorelease];
    [_input setString:[[m_txtSearch text] uppercaseString]];
    
    if ([self checkHexPattern:_input] == YES)
    {
        [m_SearchString setString:_input];
        if ([m_SearchString isEqualToString:[m_txtSearch text]] == NO)
        {
            [m_txtSearch setText:m_SearchString];
        }
    }
    else
    {
        /* restore previous input and return */
         
        /* restore previous one */
        [m_txtSearch setText:m_SearchString];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[m_txtSearch undoManager] removeAllActions];
        return;
    }
    
    
    /* UI update based on search criteria is going to be performed */
    /* clear selection information */
    m_ExpandedCellIdx = -1;
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
    
    /* save search criteria */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagSearchCriteria:m_SearchString];
    
    /* clear tags array to perform full UI update */
    [m_Tags removeAllObjects];
    
    /* update UI */
    [self updateOperationDataUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)onNewTriggerEvent:(BOOL)pressed
{
    __block zt_InventoryVC *__weak_self = self;
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

- (void)showWarning:(NSString *)message
{
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
}

- (void)configureTagCell:(zt_RFIDTagCellView*)tag_cell forRow:(int)row isExpanded:(BOOL)expanded
{
    /* TBD */
    zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:row];
     NSLog(@"%@ This is tag ID",tag_data.getTagId);
    
    
    [tag_cell setTagData:tag_data.getTagId];
    [tag_cell setTagCount:[NSString stringWithFormat:@"%d", tag_data.getCount]];
    
    if (YES == expanded)
    {
        [tag_cell setBankIdentifier:(NSString*)[m_Mapper getStringByEnum:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryMemoryBank]]];
        
        [tag_cell setBankData:[NSString stringWithFormat:@"%@", tag_data.getMemoryBankData]];
        
        srfidReportConfig *report_fields = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getInventoryReportConfig];
        
        if (YES == [report_fields getIncPC])
        {
            [tag_cell setPCData:tag_data.getPC];
        }
        else
        {
            [tag_cell setUnperfomPCData];
        }
        
        if (YES == [report_fields getIncRSSI])
        {
            [tag_cell setRSSIData:tag_data.getRSSI];
        }
        else
        {
            [tag_cell setUnperfomRSSIData];
        }

        if (YES == [report_fields getIncPhase])
        {
            [tag_cell setPhaseData:tag_data.getPhase];

        }
        else
        {
            [tag_cell setUnperfomPhaseData];
        }

        if (YES == [report_fields getIncChannelIndex])
        {
            [tag_cell setChannelData:tag_data.getChannelIndex];
        }
        else
        {
            [tag_cell setUnperfomChannelData];
        }
        if (YES == [report_fields getIncTagSeenCount])
        {
            [tag_cell setTagCount:[NSString stringWithFormat:@"%d",tag_data.getCount]];
        }
        else
        {
            [tag_cell setUnperfomTagSeenCount];
        }
        [report_fields release];
    }
    
    [tag_cell configureViewMode:expanded];
}

- (void)setLabelTextToFit:(NSString*)text forLabel:(UILabel*)label withMaxFontSize:(float)max_font_size
{
    float lbl_height = label.frame.size.height;
    float lbl_width = label.frame.size.width;
    
    CGFloat font_size = max_font_size + 1.0;
    CGSize text_size;
    
    do
    {
        font_size--;
        text_size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font_size]}];
        
    } while ((text_size.height > lbl_height) || (text_size.width > lbl_width));
    
    [label setFont:[UIFont systemFontOfSize:font_size]];
    [label setText:text];
}

- (void)configureAppearance
{
    /* background colors and shadows */
    float bgnd_color = (float)ZT_UI_INVENTORY_COLOR_LBL_HEADER / 255.0;
    UIColor *bgnd_ui_color = [UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0];
    [m_lblHeader setBackgroundColor:bgnd_ui_color];
    
    bgnd_color = (float)ZT_UI_INVENTORY_COLOR_LBL_HEADER_SHADOW / 255.0;
    bgnd_ui_color = [UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0];
    
    [[m_lblHeader layer] setMasksToBounds:NO]; // required for shadow
    [[m_lblHeader layer] setShadowColor:bgnd_ui_color.CGColor];
    [[m_lblHeader layer] setShadowOffset:CGSizeMake(0.0, 0.05 * self.tabBarController.tabBar.bounds.size.height)];
    [[m_lblHeader layer] setShadowOpacity:1.0f];
    
    bgnd_color = (float)ZT_UI_INVENTORY_COLOR_SEARCH_FIELD / 255.0;
    bgnd_ui_color = [UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0];
    
    [m_txtSearch setBackgroundColor:bgnd_ui_color];
    
    /* configure search text field */
    [m_txtSearch setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_txtSearch setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_txtSearch setKeyboardType:UIKeyboardTypeDefault];
    [m_txtSearch setReturnKeyType:UIReturnKeySearch];
    [m_txtSearch setClearButtonMode:UITextFieldViewModeAlways];
    [m_txtSearch setPlaceholder:@"Search"];
    [m_txtSearch setText:@""];
    
    UIImageView *search_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find.png"]];
    
    [m_txtSearch setLeftView:search_icon];
    [m_txtSearch setLeftViewMode:UITextFieldViewModeUnlessEditing];
    [search_icon release];
    
    /* text color */
    [m_txtSearch setTextColor:[UIColor whiteColor]];
    [m_lblTotalTagsNotice setTextColor:[UIColor whiteColor]];
    [m_lblTotalTagsData setTextColor:[UIColor whiteColor]];
    [m_lblUniqueTagsNotice setTextColor:[UIColor whiteColor]];
    [m_lblUniqueTagsData setTextColor:[UIColor whiteColor]];
    
    /* text */
    [m_lblTotalTagsNotice setText:@"TOTAL TAGS"];
    [m_lblUniqueTagsNotice setText:@"UNIQUE TAGS"];

    /* text alignment */
    [m_lblTotalTagsNotice setTextAlignment:NSTextAlignmentCenter];
    [m_lblTotalTagsData setTextAlignment:NSTextAlignmentCenter];
    [m_lblUniqueTagsNotice setTextAlignment:NSTextAlignmentCenter];
    [m_lblUniqueTagsData setTextAlignment:NSTextAlignmentCenter];
    
    /* font size */
    [m_lblTotalTagsNotice setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_SMALL]];
    [m_lblUniqueTagsNotice setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_SMALL]];
    [m_lblTotalTagsData setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]];
    [m_lblUniqueTagsData setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]];
    [m_txtSearch setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_MEDIUM]];
    [m_btnStartStop.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BUTTON]];
}

- (void)btnOptionsPressed
{
    UIActionSheet *_options_menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (int i = 0; i < [m_InventoryOptions count]; i++)
    {
        [_options_menu addButtonWithTitle:[NSString stringWithFormat:@"%@ %@ \u2001", (([m_Mapper getIndxByEnum:m_SelectedInventoryOption] == i) ? @"\u2713" : @"\u2001"), (NSString*)[m_InventoryOptions objectAtIndex:i]]];
    }

    /* recolor & center */
    NSString *_offset_str = @"\u2713 ";
    UIButton *_btn = nil;
    UIColor *_txt_color = [UIColor blackColor];
    float _offset = [_offset_str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]}].width;
    

    NSArray *_views = [_options_menu subviews];
    for (UIView *_vw in _views)
    {
        if (YES == [_vw isKindOfClass:[UIButton class]])
        {
            _btn = (UIButton*)_vw;
            
            [_btn.titleLabel setTextColor:_txt_color];
            [_btn.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_INVENTORY_FONT_SZ_BIG]];
            
            [((UIButton*)_vw).titleLabel setTextAlignment:NSTextAlignmentCenter];
            [((UIButton*)_vw) setContentEdgeInsets:UIEdgeInsetsMake(0.0, -_offset, 0.0, 0.0)];
        }
    }
    
    _options_menu.cancelButtonIndex = [_options_menu addButtonWithTitle:@"Hide"];
    
    [_options_menu showFromTabBar:self.tabBarController.tabBar];
    [_options_menu release];
}

//-(void)getTag {
//
//    zt_InventoryItem *tag_data = (zt_InventoryItem *)[m_Tags objectAtIndex:0];
//    NSLog(@"%@ Get Data Func",tag_data.getTagId);
//}

- (IBAction)btnStartStopPressed:(id)sender
{
  //  [self getTag];
    NSString *statusMsg;
    if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
    {
        [self showWarning:@"Getting batched tags: operation not allowed"];
        return;
    }
    BOOL inventory_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];

    if (NO == inventory_requested)
    {
        if ([[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isUniqueTagsReport] == [NSNumber numberWithBool:YES])
        {
            rfid_res = [[zt_RfidAppEngine sharedAppEngine] purgeTags:&statusMsg];
        }
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startInventory:YES aMemoryBank:m_SelectedInventoryOption message:&status];
        if ([status isEqualToString:@"Inventory Started in Batch Mode"]) {
            [m_Tags removeAllObjects];
            NSLog(@"%@ btn Tag is",m_Tags);
            [m_tblTags reloadData];
             NSLog(@"%@ btn table",m_tblTags);
            
            batchModeLabel.hidden = NO;
            [UIView performWithoutAnimation:^{
                [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
                [m_btnStartStop layoutIfNeeded];
            }];
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
    
    int tag_count = (int)[zt_InventoryData getUniqueCount:_tags];
    [self setLabelTextToFit:[NSString stringWithFormat:@"%d", tag_count] forLabel:m_lblUniqueTagsData withMaxFontSize:19.0];
    
    /* total tags */
    int totalTagCount = [zt_InventoryData getTotalCount:_tags];
    [self setLabelTextToFit:[NSString stringWithFormat:@"%d", totalTagCount] forLabel:m_lblTotalTagsData withMaxFontSize:19.0];
    
    
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
        batchModeLabel.hidden = YES;
        [m_tblTags reloadData];
    }
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
        m_ExpandedCellIdx = -1;
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
            [self updateOperationDataUI];
            batchModeLabel.hidden=YES;
            m_tblTags.hidden = NO;
        }
        else if([[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateGetTagsOperationInProgress])
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


/* ###################################################################### */
/* ########## Action Sheet Delegate Protocol implementation ############# */
/* ###################################################################### */
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 5)
    {
        // its hide button
        return;
    }
    if (buttonIndex < [m_InventoryOptions count])
    {
        m_SelectedInventoryOption = [m_Mapper getEnumByIndx:(int)buttonIndex];
        [m_btnOptions setTitle:[m_InventoryOptions objectAtIndex:buttonIndex]];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setSelectedInventoryMemoryBankUI:m_SelectedInventoryOption];
    }
}

/* ###################################################################### */
/* ########## Text Field Delegate Protocol implementation ############### */
/* ###################################################################### */

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    /* clear selection due to upcoming ui update */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
    m_ExpandedCellIdx = -1;
    
    /* clear search criteria */
    [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagSearchCriteria:@""];
    
    /* clear tags array to perform full UI update */
    [m_Tags removeAllObjects];
    
    /* update UI */
    [self updateOperationDataUI];
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* just to hide keyboard */
    [textField resignFirstResponder];

    return YES;
}

- (BOOL) textField: (UITextField *)theTextField shouldChangeCharactersInRange: (NSRange)range replacementString: (NSString *)string {
    
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
    return [m_Tags count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
 
    BOOL expanded = ((m_ExpandedCellIdx == [indexPath row]) ? YES : NO);
    
    if(YES == expanded || m_standartCellHeight < 0)
    {
        [self configureTagCell:m_OffscreenTagCell forRow:(int)[indexPath row] isExpanded:expanded];

        [m_OffscreenTagCell setNeedsUpdateConstraints];
        [m_OffscreenTagCell updateConstraintsIfNeeded];

        //m_OffscreenTagCell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(m_tblTags.bounds), CGRectGetHeight(m_OffscreenTagCell.bounds));

        [m_OffscreenTagCell setNeedsLayout];
        [m_OffscreenTagCell layoutIfNeeded];

        height = [m_OffscreenTagCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1.0;
        
        if(m_standartCellHeight < 0 && NO == expanded)
		{      
			m_standartCellHeight = height;
		}
    }
    else
	{
        height = m_standartCellHeight;
	}
    
    return height;
}
// From here get the tag...
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RFIDTagCellIdentifier = ZT_CELL_ID_TAG_DATA;
    
    zt_RFIDTagCellView *tag_cell = [tableView dequeueReusableCellWithIdentifier:RFIDTagCellIdentifier forIndexPath:indexPath];
    
    if (tag_cell == nil)
    {
        tag_cell = [[zt_RFIDTagCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RFIDTagCellIdentifier];
    }
    
    BOOL expanded = ((m_ExpandedCellIdx == [indexPath row]) ? YES : NO);
    
    [self configureTagCell:tag_cell forRow:(int)[indexPath row] isExpanded:expanded];
    
    [tag_cell setNeedsUpdateConstraints];
    [tag_cell updateConstraintsIfNeeded];
    return tag_cell;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // condition check if cell is opened
    if (m_ExpandedCellIdx != [indexPath row])
    {
        int row_to_collapse = m_ExpandedCellIdx;
        m_ExpandedCellIdx = (int)[indexPath row];
        
        NSMutableArray *index_paths = [[NSMutableArray alloc] init];
        
        if (-1 != row_to_collapse)
        {
            [index_paths addObject:[NSIndexPath indexPathForRow:row_to_collapse inSection:0]];
        }
        [index_paths addObject:[NSIndexPath indexPathForRow:m_ExpandedCellIdx inSection:0]];
        
        [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationFade];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [index_paths removeAllObjects];
        [index_paths release];
        
        // save data to appEngine
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setSelectedInventoryItem:(zt_InventoryItem *)[m_Tags objectAtIndex:m_ExpandedCellIdx] withIdx:m_ExpandedCellIdx];
         NSLog(@"%@ sel",m_Tags);
        /* overwrite saved tag ids for locationing and access screens */
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdAccess:[(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx] getTagId]];
        NSLog(@"%@ acc",m_Tags);
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdLocationing:[(zt_InventoryItem*)[m_Tags objectAtIndex:m_ExpandedCellIdx] getTagId]];
         NSLog(@"%@ loc",m_Tags);
    }
    else
    {
        int row_to_collapse = m_ExpandedCellIdx;
        m_ExpandedCellIdx = -1;
        
        NSMutableArray *index_paths = [[NSMutableArray alloc] init];
        
        [index_paths addObject:[NSIndexPath indexPathForRow:row_to_collapse inSection:0]];
        
        [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationFade];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [index_paths removeAllObjects];
        [index_paths release];
        
        // save data to appEngine
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdAccessGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearTagIdLocationingGracefully];
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] clearSelectedItem];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /* just to hide keyboard */
    [m_txtSearch resignFirstResponder];
}



@end
