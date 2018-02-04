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
@property (nonatomic, strong) UIButton *m_btnSettings;
@property (nonatomic, strong) UIButton *m_btnGenerate;


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
    //    [self addConstraintsSizePosition];
        
    } else {
        // for early version of IOS
        [self initButtonsWithSize];
     //   [self addConstraintsPosition];
    }
    
    // Setup the About button
//    UIBarButtonItem *barButtonScan = [[UIBarButtonItem alloc]initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(btnScanPressed:)];
    
//    self.navigationItem.leftBarButtonItem = barButtonScan;
    
    // Setup the About button
//    UIBarButtonItem *barButtonAbout = [[UIBarButtonItem alloc]initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(btnAboutPressed:)];
    
 //   self.navigationItem.rightBarButtonItem = barButtonAbout;
    
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
  
    [self.m_btnSettings addTarget:self action:@selector(btnSettingsPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    
  //  [self.view addSubview:self.m_btnScan];
 
    [self.view addSubview:self.m_btnSettings];
 
    
 //   [UIButton alignHomeButtonContent:self.m_btnScan];
//    [UIButton alignHomeButtonContent:self.m_btnSettings];

}

- (void)initButtonsNoSize;
{
    
    CGRect homeFrame = self.view.bounds;
    float width = homeFrame.size.width;
    self.m_padding = [NSNumber numberWithDouble:width * 0.03125];
    
  //  self.m_btnScan = [UIButton buttonForHomeScreen:ZT_BUTTON_SCAN];
    self.m_btnScan.translatesAutoresizingMaskIntoConstraints = NO;
    
    
 //   self.m_btnSettings = [UIButton buttonForHomeScreen:ZT_BUTTON_SETTINGS];
    self.m_btnSettings.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [self.m_btnScan addTarget:self action:@selector(btnScanPressed:)
//                  forControlEvents:UIControlEventTouchUpInside];
  
    [self.m_btnSettings addTarget:self action:@selector(btnSettingsPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.m_btnScan];
    [self.view addSubview:self.m_btnSettings];
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

- (IBAction)btnGeneratePressed:(id)sender
{
    ScanVC *gen_vc = (ScanVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_GENE_VC"];
    
    if (nil != gen_vc)
    {
        // _filterWasOpened = YES;
        [[self navigationController] pushViewController:gen_vc animated:YES];
    }
}

- (IBAction)btnSettingsPressed:(id)sender
{
    zt_SettingsVC*settings_vc = (zt_SettingsVC*)[[UIStoryboard storyboardWithName:@"RFIDDemoApp" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SETTINGS_VC"];
    
    if (nil != settings_vc)
    {
        [[self navigationController] pushViewController:settings_vc animated:YES];
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
