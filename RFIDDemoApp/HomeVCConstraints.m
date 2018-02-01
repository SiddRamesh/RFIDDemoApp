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
 *  Description:  HomeVCConstraints.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "HomeVCConstraints.h"

@interface zt_HomeVCConstraints ()

@property (nonatomic, strong) UIButton *m_btnScan;
@property (nonatomic, strong) UIButton *m_btnRapidRead;
@property (nonatomic, strong) UIButton *m_btnInventory;
@property (nonatomic, strong) UIButton *m_btnSettings;
@property (nonatomic, strong) UIButton *m_btnLocateTag;
@property (nonatomic, strong) UIButton *m_btnFilter;
@property (nonatomic, strong) UIButton *m_btnAccess;

@property (nonatomic, strong) NSNumber *m_padding;
@property (nonatomic) BOOL filterWasOpened;
@end

@implementation zt_HomeVCConstraints

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
       
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        // for IOS 8 or later
        // set buttons size with constr
        
        [self initButtonsNoSize];
        [self addConstraintsSizePosition];
        
    } else {
        // for early version of IOS
        [self initButtonsWithSize];
        [self addConstraintsPosition];
    }
    
    // Setup the About button
    UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(btnScanPressed:)];
    
    self.navigationItem.leftBarButtonItem = barButtonScan;
    
    // Setup the About button
    UIBarButtonItem *barButtonAbout = [[UIBarButtonItem alloc]initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(btnAboutPressed:)];
    
    self.navigationItem.rightBarButtonItem = barButtonAbout;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_filterWasOpened) {
        _filterWasOpened = NO;
        
        zt_SledConfiguration *localSled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        
        if (![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
        {
            //zt_AlertView *alert = [[zt_AlertView alloc] init];
            //[alert showWarningText:self.view withString:ZT_WARNING_NO_READER];
            return;
        }
        
        
        if ((localSled.applyFirstFilter &&
             ![zt_SledConfiguration isPrefilterEqual:localSled.currentPrefilters[0] withPrefilter:sled.currentPrefilters[0]]) ||
            (localSled.applySecondFilter &&
             ![zt_SledConfiguration isPrefilterEqual:localSled.currentPrefilters[1] withPrefilter:sled.currentPrefilters[1]]) ||
            (localSled.applyFirstFilter != sled.applyFirstFilter || localSled.applySecondFilter != sled.applySecondFilter)
            )

        {
            BOOL valid = true;
    
            if (YES == localSled.applyFirstFilter)
            {
                valid = [localSled isPrefilterValid:localSled.currentPrefilters[0]];
            }
            if (YES == valid)
            {
                if (YES == localSled.applySecondFilter)
                {
                    valid = [localSled isPrefilterValid:localSled.currentPrefilters[1]];
                }
            }
            
            if (YES == valid)
            {
                [self applyNewSetting:@"Saving filter settings"];
                return;
            }
            else
            {
                [self showInvalidParamsWarning];
            }
        }
        else
        {
            return;
        }
        
        // if we get here, that means some parameters are invalid
        // restore values if need
        [[zt_RfidAppEngine sharedAppEngine] restorePrefilters];
    }
}
                   
- (void)showWarning:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        zt_AlertView *alertView = [[zt_AlertView alloc]init];
        [alertView showSuccessFailureWithText:self.view isSuccess:NO aSuccessMessage:@"" aFailureMessage:message];
    });
}
           
                   
- (void)applyNewSetting:(NSString *)message
{
    zt_AlertView *alertView = [[zt_AlertView alloc]init];
    [alertView showAlertWithView:self.view withTarget:self withMethod:@selector(updateFilters) withObject:nil withString:message];
}

- (void)updateFilters
{
    NSString *response;
    SRFID_RESULT result = [[zt_RfidAppEngine sharedAppEngine] setPrefilters:&response];
    
    [self handleCommandResult:result withStatusMessage:response];
    
//    sleep(1);
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        zt_AlertView *alertView = [[zt_AlertView alloc]init];
//        [alertView showSuccessFailure:self.view isSuccess:result];
//    });
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    NSString *horiz = @"horizontal";
    if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        horiz = @"compact";
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        horiz = @"regular";
    } else if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassUnspecified) {
        horiz = @"unspicified";
    }
    
    NSString *vert = @"vertical";
    if(self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        vert = @"compact";
    } else if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        vert = @"regular";
    } else if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassUnspecified) {
        vert = @"unspecified";
    }

}

- (void) addConstraintsSizePosition
{
    // 1. Create a dictionary of buttons
    NSDictionary *buttonsDictionary = @{@"rapidRead":self.m_btnRapidRead, @"inventory":self.m_btnInventory, @"settings":self.m_btnSettings, @"locateTag":self.m_btnLocateTag,@"filter":self.m_btnFilter,@"access":self.m_btnAccess};
    NSDictionary *metrics = @{@"space": self.m_padding}; //@"scan":self.m_btnScan,
    // 3.2 Define the views Positions in container using options
    
//    NSArray *constraint_SIZE_H0 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[scan(==inventory)]" options:0 metrics:nil views:buttonsDictionary];
//    NSArray *constraint_SIZE_V0 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[scan(==inventory)]" options:0 metrics:nil views:buttonsDictionary];
//    [self.view addConstraints:constraint_SIZE_H0];
//    [self.view addConstraints:constraint_SIZE_V0];
    
    NSArray *constraint_SIZE_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[rapidRead(==inventory)]" options:0 metrics:nil views:buttonsDictionary];
    NSArray *constraint_SIZE_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[rapidRead(==inventory)]" options:0 metrics:nil views:buttonsDictionary];
    [self.view addConstraints:constraint_SIZE_H1];
    [self.view addConstraints:constraint_SIZE_V1];
    
    NSArray *constraint_SIZE_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[inventory(==settings)]" options:0 metrics:nil views:buttonsDictionary];
    NSArray *constraint_SIZE_V2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[inventory(==settings)]" options:0 metrics:nil views:buttonsDictionary];
    [self.view addConstraints:constraint_SIZE_H2];
    [self.view addConstraints:constraint_SIZE_V2];
    
    NSArray *constraint_SIZE_H3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[settings(==locateTag)]" options:0 metrics:nil views:buttonsDictionary];
    NSArray *constraint_SIZE_V3 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[settings(==locateTag)]" options:0 metrics:nil views:buttonsDictionary];
    [self.view addConstraints:constraint_SIZE_H3];
    [self.view addConstraints:constraint_SIZE_V3];
    
    NSArray *constraint_SIZE_H4 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[locateTag(==filter)]" options:0 metrics:nil views:buttonsDictionary];
    NSArray *constraint_SIZE_V4 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[locateTag(==filter)]" options:0 metrics:nil views:buttonsDictionary];
    [self.view addConstraints:constraint_SIZE_H4];
    [self.view addConstraints:constraint_SIZE_V4];
    
    NSArray *constraint_SIZE_H5 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[filter(==access)]" options:0 metrics:nil views:buttonsDictionary];
    NSArray *constraint_SIZE_V5 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[filter(==access)]" options:0 metrics:nil views:buttonsDictionary];
    [self.view addConstraints:constraint_SIZE_H5];
    [self.view addConstraints:constraint_SIZE_V5];
    
    
    
    NSArray *constraint_POS_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[rapidRead]-space-[inventory]-space-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[rapidRead]-space-[locateTag]-space-[access]-space-|"
                                                                         options:NSLayoutFormatAlignAllLeft
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H1];
    [self.view addConstraints:constraint_POS_V1];
    
    NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[locateTag]-space-[settings]-space-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V2= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[inventory]-space-[settings]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H2];
    [self.view addConstraints:constraint_POS_V2];
    
    
    NSArray *constraint_POS_H3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[access]-space-[filter]-space-|"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V3= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[inventory]-space-[settings]-space-[filter]-space-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H3];
    [self.view addConstraints:constraint_POS_V3];
    
    
  //  [UIButton alignHomeButtonContent:self.m_btnScan];
    [UIButton alignHomeButtonContent:self.m_btnRapidRead];
    [UIButton alignHomeButtonContent:self.m_btnInventory];
    [UIButton alignHomeButtonContent:self.m_btnSettings];
    [UIButton alignHomeButtonContent:self.m_btnLocateTag];
    [UIButton alignHomeButtonContent:self.m_btnFilter];
    [UIButton alignHomeButtonContent:self.m_btnAccess];
    
    
}

- (void) addConstraintsPosition
{
    // 1. Create a dictionary of buttons
    NSDictionary *buttonsDictionary = @{@"rapidRead":self.m_btnRapidRead, @"inventory":self.m_btnInventory, @"settings":self.m_btnSettings, @"locateTag":self.m_btnLocateTag,@"filter":self.m_btnFilter,@"access":self.m_btnAccess};
    NSDictionary *metrics = @{@"space": self.m_padding}; //{@"scan":self.m_btnScan,
    // 3.2 Define the views Positions in container using options
    
//    NSArray *constraint_POS_H0 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[scan]-space-[inventory]"
//                                                                         options:0
//                                                                         metrics:metrics
//                                                                           views:buttonsDictionary];
//    
//    NSArray *constraint_POS_V0 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[scan]-space-[locateTag]-space-[access]"
//                                                                         options:NSLayoutFormatAlignAllLeft
//                                                                         metrics:metrics
//                                                                           views:buttonsDictionary];
//    
//    [self.view addConstraints:constraint_POS_H0];
//    [self.view addConstraints:constraint_POS_V0];
    
    NSArray *constraint_POS_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[rapidRead]-space-[inventory]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[rapidRead]-space-[locateTag]-space-[access]"
                                                                         options:NSLayoutFormatAlignAllLeft
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H1];
    [self.view addConstraints:constraint_POS_V1];
    
    NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[locateTag]-space-[settings]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V2= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[inventory]-space-[settings]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H2];
    [self.view addConstraints:constraint_POS_V2];
    
    
    NSArray *constraint_POS_H3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[access]-space-[filter]"
                                                                         options:0
                                                                         metrics:metrics
                                                                           views:buttonsDictionary];
    
    NSArray *constraint_POS_V3= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[inventory]-space-[settings]-space-[filter]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:buttonsDictionary];
    
    [self.view addConstraints:constraint_POS_H3];
    [self.view addConstraints:constraint_POS_V3];
    
    
 //   [UIButton alignHomeButtonContent:self.m_btnScan];
    [UIButton alignHomeButtonContent:self.m_btnRapidRead];
    [UIButton alignHomeButtonContent:self.m_btnInventory];
    [UIButton alignHomeButtonContent:self.m_btnSettings];
    [UIButton alignHomeButtonContent:self.m_btnLocateTag];
    [UIButton alignHomeButtonContent:self.m_btnFilter];
    [UIButton alignHomeButtonContent:self.m_btnAccess];
    
    
}

- (void)initButtonsWithSize
{
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height;
    float heightStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    height -= heightStatusBar;
    
    self.m_padding = [NSNumber numberWithDouble:width * 0.03125];
    
    float buttonWidth = ( width - 3 * self.m_padding.doubleValue ) / 2;
    float buttonHeight = ( height - 4 * self.m_padding.doubleValue) / 3;
    
    CGSize size  = CGSizeMake(buttonWidth, buttonHeight);
    
//    self.m_btnScan = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_SCAN];
//    self.m_btnScan.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnRapidRead = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_RAPID_READ];
    self.m_btnRapidRead.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnInventory = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_INVENTORY];
    self.m_btnInventory.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnSettings = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_SETTINGS];
    self.m_btnSettings.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnLocateTag = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_LOCATE_TAG];
    self.m_btnLocateTag.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnFilter = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_FILTER];
    self.m_btnFilter.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnAccess = [UIButton buttonForHomeScreenWithSize:size withType:ZT_BUTTON_ACCESS];
    self.m_btnAccess.translatesAutoresizingMaskIntoConstraints = NO;
    
    
//    [self.m_btnScan addTarget:self action:@selector(btnScanPressed:)
//                  forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnRapidRead addTarget:self action:@selector(btnRapidReadPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnInventory addTarget:self action:@selector(btnInventoryPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnSettings addTarget:self action:@selector(btnSettingsPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnLocateTag addTarget:self action:@selector(btnLocateTagPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnFilter addTarget:self action:@selector(btnFilterPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnAccess addTarget:self action:@selector(btnAccessPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    
  //  [self.view addSubview:self.m_btnScan];
    [self.view addSubview:self.m_btnRapidRead];
    [self.view addSubview:self.m_btnInventory];
    [self.view addSubview:self.m_btnSettings];
    [self.view addSubview:self.m_btnLocateTag];
    [self.view addSubview:self.m_btnFilter];
    [self.view addSubview:self.m_btnAccess];
    
 //   [UIButton alignHomeButtonContent:self.m_btnScan];
    [UIButton alignHomeButtonContent:self.m_btnRapidRead];
    [UIButton alignHomeButtonContent:self.m_btnInventory];
    [UIButton alignHomeButtonContent:self.m_btnSettings];
    [UIButton alignHomeButtonContent:self.m_btnLocateTag];
    [UIButton alignHomeButtonContent:self.m_btnFilter];
    [UIButton alignHomeButtonContent:self.m_btnAccess];
    

}

- (void)initButtonsNoSize;
{
    
    CGRect homeFrame = self.view.bounds;
    float width = homeFrame.size.width;
    self.m_padding = [NSNumber numberWithDouble:width * 0.03125];
    
    self.m_btnScan = [UIButton buttonForHomeScreen:ZT_BUTTON_SCAN];
    self.m_btnScan.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnRapidRead = [UIButton buttonForHomeScreen:ZT_BUTTON_RAPID_READ];
    self.m_btnRapidRead.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnInventory = [UIButton buttonForHomeScreen:ZT_BUTTON_INVENTORY];
    self.m_btnInventory.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnSettings = [UIButton buttonForHomeScreen:ZT_BUTTON_SETTINGS];
    self.m_btnSettings.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnLocateTag = [UIButton buttonForHomeScreen:ZT_BUTTON_LOCATE_TAG];
    self.m_btnLocateTag.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnFilter = [UIButton buttonForHomeScreen:ZT_BUTTON_FILTER];
    self.m_btnFilter.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.m_btnAccess = [UIButton buttonForHomeScreen:ZT_BUTTON_ACCESS];
    self.m_btnAccess.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [self.m_btnScan addTarget:self action:@selector(btnScanPressed:)
//                  forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnRapidRead addTarget:self action:@selector(btnRapidReadPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnInventory addTarget:self action:@selector(btnInventoryPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnSettings addTarget:self action:@selector(btnSettingsPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnLocateTag addTarget:self action:@selector(btnLocateTagPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnFilter addTarget:self action:@selector(btnFilterPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.m_btnAccess addTarget:self action:@selector(btnAccessPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    
  //  [self.view addSubview:self.m_btnScan];
    [self.view addSubview:self.m_btnRapidRead];
    [self.view addSubview:self.m_btnInventory];
    [self.view addSubview:self.m_btnSettings];
    [self.view addSubview:self.m_btnLocateTag];
    [self.view addSubview:self.m_btnFilter];
    [self.view addSubview:self.m_btnAccess];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnScanPressed:(id)sender
{
  //  [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_SCAN_VC_IDX];
    ScanVC *scan_vc = (ScanVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCAN_VC"];
    
    if (nil != scan_vc)
    {
       // _filterWasOpened = YES;
        [[self navigationController] pushViewController:scan_vc animated:YES];
   }
}

- (IBAction)btnRapidReadPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_RAPID_READ_VC_IDX];
}

- (IBAction)btnInventoryPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_INVENTORY_VC_IDX];
}

- (IBAction)btnSettingsPressed:(id)sender
{
    zt_SettingsVC*settings_vc = (zt_SettingsVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SETTINGS_VC"];
    
    if (nil != settings_vc)
    {
        [[self navigationController] pushViewController:settings_vc animated:YES];
    }
}

- (IBAction)btnLocateTagPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_LOCATE_TAG_VC_IDX];
}

- (IBAction)btnFilterPressed:(id)sender
{
    zt_FilterConfigVC *filter_vc = (zt_FilterConfigVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_FILTER_CONFIG_VC"];
    
    if (nil != filter_vc)
    {
        _filterWasOpened = YES;
        [[self navigationController] pushViewController:filter_vc animated:YES];
    }
}

- (IBAction)btnAccessPressed:(id)sender
{
    [self showTabInterfaceActiveView:ZT_VC_RFIDTAB_ACCESS_VC_IDX];
}

- (IBAction)btnAboutPressed:(id)sender
{
    zt_AboutVC *about_vc = (zt_AboutVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ABOUT_VC"];

    if (nil != about_vc)
    {
        [[self navigationController] pushViewController:about_vc animated:YES];
    }
}

- (void)showTabInterfaceActiveView:(int)identifier
{
    zt_RFIDTabVC *tab_vc = (zt_RFIDTabVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_RFID_TAB_VC"];
    [tab_vc setActiveView:identifier];
    
    if (nil != tab_vc)
    {
        [[self navigationController] pushViewController:tab_vc animated:YES];
    }
}

@end
