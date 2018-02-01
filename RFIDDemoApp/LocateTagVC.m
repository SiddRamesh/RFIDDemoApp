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
 *  Description:  LocateTagVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LocateTagVC.h"

#define ZT_LOCATIONING_TIMER_INTERVAL          0.2

@interface zt_LocateTagVC ()

@end

@implementation zt_LocateTagVC

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
    [m_txtTagIdInput release];
    [m_lblDistanceNotice release];
    [m_lblDistanceData release];
    [m_btnStartStop release];
    [m_lblIndicatorBackground release];
    [m_lblIndicatorValue release];
    if (nil != m_GestureRecognizer)
    {
        [m_GestureRecognizer release];
    }
    [m_lblTagIdInputBackground release];
    
    if(nil != m_strTagInput)
    {
        [m_strTagInput release];
    }
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [m_txtTagIdInput setDelegate:self];
    
    m_strTagInput = [[NSMutableString alloc] init];

    /* just to hide keyboard */
    m_GestureRecognizer = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(dismissKeyboard)];
    [m_GestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:m_GestureRecognizer];
    
    /* set title */
    [self.tabBarController setTitle:@"Locate Tag"];
    
    /* configure layout via constraints */
    [self.view removeConstraints:[self.view constraints]];
    
//    CGFloat tabbar_height = self.tabBarController.tabBar.bounds.size.height;
    
    /* nrv364: navigation bar height is 0 when is presented from home vc */
//    CGFloat navigationbar_height = tabbar_height; //self.tabBarController.navigationController.navigationBar.bounds.size.height;
    
//    CGFloat height = self.view.bounds.size.height - tabbar_height - navigationbar_height;
    
    CGFloat width = self.view.bounds.size.width;
    
/*
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblTagId attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblTagId attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c20];
    
    NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblTagId attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c30];
    
    NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblTagId attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.00 constant:35.0];
    [self.view addConstraint:c40];
*/
    NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c50];
    
    NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c60];
    
    NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c70];
    
    NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0 constant:35.0];
    [self.view addConstraint:c80];
    
    NSLayoutConstraint *c90 = [NSLayoutConstraint constraintWithItem:m_txtTagIdInput attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c90];
    
    NSLayoutConstraint *c100 = [NSLayoutConstraint constraintWithItem:m_txtTagIdInput attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c100];
    
    NSLayoutConstraint *c110 = [NSLayoutConstraint constraintWithItem:m_txtTagIdInput attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c110];
    
    NSLayoutConstraint *c120 = [NSLayoutConstraint constraintWithItem:m_txtTagIdInput attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblTagIdInputBackground attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:c120];
    
    NSLayoutConstraint *c130 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c130];
    
    NSLayoutConstraint *c140 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_txtTagIdInput attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c140];
    
    NSLayoutConstraint *c150 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorBackground attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.25 constant:0.0];
    [self.view addConstraint:c150];
    
    NSLayoutConstraint *c160 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorBackground attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.4*width];
    [self.view addConstraint:c160];
    
    NSLayoutConstraint *c170 = [NSLayoutConstraint constraintWithItem:m_lblDistanceData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3*ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c170];
    
    NSLayoutConstraint *c180 = [NSLayoutConstraint constraintWithItem:m_lblDistanceData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c180];
    
    NSLayoutConstraint *c190 = [NSLayoutConstraint constraintWithItem:m_lblDistanceData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c190];
    
    NSLayoutConstraint *c200 = [NSLayoutConstraint constraintWithItem:m_lblDistanceData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.09 constant:0.0];
    [self.view addConstraint:c200];
    
    NSLayoutConstraint *c210 = [NSLayoutConstraint constraintWithItem:m_lblDistanceNotice attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.view addConstraint:c210];
    
    NSLayoutConstraint *c220 = [NSLayoutConstraint constraintWithItem:m_lblDistanceNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.view addConstraint:c220];
    
    NSLayoutConstraint *c230 = [NSLayoutConstraint constraintWithItem:m_lblDistanceNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.view addConstraint:c230];
    
    NSLayoutConstraint *c240 = [NSLayoutConstraint constraintWithItem:m_lblDistanceNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeHeight multiplier:0.5 constant:0.0];
    [self.view addConstraint:c240];

    NSLayoutConstraint *c250 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:4*ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c250];
    
    NSLayoutConstraint *c260 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblDistanceData attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:c260];
    
    NSLayoutConstraint *c270 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c270];
    
    NSLayoutConstraint *c280 = [NSLayoutConstraint constraintWithItem:m_btnStartStop attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_LOCATE_TAG_INDENT_EXT];
    [self.view addConstraint:c280];
    
    NSLayoutConstraint *c370 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorValue attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0];
    [self.view addConstraint:c370];
    
    NSLayoutConstraint *c380 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorValue attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-2.0];
    [self.view addConstraint:c380];
    
    NSLayoutConstraint *c390 = [NSLayoutConstraint constraintWithItem:m_lblIndicatorValue attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeLeading multiplier:1.0 constant:2.0];
    [self.view addConstraint:c390];
    
    m_IndicatorHeightConstraint = [NSLayoutConstraint constraintWithItem:m_lblIndicatorValue attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeHeight multiplier:0.1 constant:0.0];
    [self.view addConstraint:m_IndicatorHeightConstraint];

    [self configureAppearance];
}

- (BOOL)onNewProximityEvent:(int)value
{
    [self setRelativeDistance:value];
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTagIdChanged:) name:UITextFieldTextDidChangeNotification object:m_txtTagIdInput];
    
    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] addOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] addTriggerEventDelegate:self];

     /* set title */
    [self.tabBarController setTitle:@"Locate Tag"];
    
    /* add dpo button to the title bar */
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    [right_items addObject:barButtonDpo];
    
    self.tabBarController.navigationItem.rightBarButtonItems = right_items;
    
    [right_items removeAllObjects];
    [right_items release];
    
    BOOL is_locationing = (ZT_RADIO_OPERATION_LOCATIONING == [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationType]);
    
    [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdLocationing]];
    
    if (NO == is_locationing)
    {
        [[[zt_RfidAppEngine sharedAppEngine] operationEngine] clearLocationingStatistics];
        [self radioStateChangedOperationRequested:NO aType:ZT_RADIO_OPERATION_LOCATIONING];
    }
    else
    {
        BOOL requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];

        if (NO == requested)
        {
            [[[zt_RfidAppEngine sharedAppEngine] operationEngine] clearLocationingStatistics];
        }
        else
        {
            [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLocationingTagId]];
        }
        
        [self radioStateChangedOperationRequested:requested aType:ZT_RADIO_OPERATION_LOCATIONING];
        [self radioStateChangedOperationInProgress:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateOperationInProgress] aType:ZT_RADIO_OPERATION_LOCATIONING];
    }
    
     [m_txtTagIdInput setText:m_strTagInput];
      NSLog(@"%@ tagID is",m_txtTagIdInput);
      NSLog(@"%@ tag is 1",m_strTagInput); // Here is tag
   
}

-(void)getTag{
    
     [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdLocationing]];
     NSLog(@"%@ AppFunc tag is 1",m_strTagInput);
    
     [m_strTagInput setString:[[[zt_RfidAppEngine sharedAppEngine] operationEngine] getLocationingTagId]];
     NSLog(@"%@ OpFunc tag is 1",m_strTagInput); // Here is tag
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:m_txtTagIdInput];

    [[[zt_RfidAppEngine sharedAppEngine] operationEngine] removeOperationListener:self];
    [[zt_RfidAppEngine sharedAppEngine] removeTriggerEventDelegate:self];
    
    /* stop timer */
    if (m_ViewUpdateTimer != nil)
    {
        [m_ViewUpdateTimer invalidate];
        m_ViewUpdateTimer = nil;
    }
}

- (void)handleTagIdChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[m_txtTagIdInput text] uppercaseString]];
    NSLog(@"%@ tag is 2",_input);
    
    if ([self checkHexPattern:_input] == YES)
    {
        [m_strTagInput setString:_input];
        if ([m_strTagInput isEqualToString:[m_txtTagIdInput text]] == NO)
        {
            [m_txtTagIdInput setText:m_strTagInput];
        }
        /* maintain edited tag id */
        [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] setTagIdLocationing:m_strTagInput];
    }
    else
    {
        /* restore previous one */
        [m_txtTagIdInput setText:m_strTagInput];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[m_txtTagIdInput undoManager] removeAllActions];
    }
    
    [_input release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWarning:(NSString *)message
{
    [zt_AlertView showInfoMessage:self.view withHeader:ZT_RFID_APP_NAME withDetails:message withDuration:3];
}

- (IBAction)btnStartStopPressed:(id)sender
{
    [self getTag];
    
    NSLog(@"%@ tag is 3",m_txtTagIdInput);
    BOOL locationing_requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
    SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
    NSLog(@"%u tag is 4",rfid_res);
    
    if (NO == locationing_requested)
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] startTagLocationing:m_txtTagIdInput.text message:nil];
        NSLog(@"%u tag is 5",rfid_res);
    }
    else
    {
        rfid_res = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] stopTagLocationing:nil];
    }
}

- (void)configureAppearance
{
    /* background colors & corners */
    float bgnd_color = (float)ZT_UI_LOCATE_TAG_COLOR_BACKGROUND / 255.0;
    UIColor *bgnd_ui_color = [UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0];
    [m_txtTagIdInput setBackgroundColor:bgnd_ui_color];
    [m_lblDistanceData setBackgroundColor:bgnd_ui_color];
    [m_lblIndicatorBackground setBackgroundColor:bgnd_ui_color];
    [m_lblTagIdInputBackground setBackgroundColor:bgnd_ui_color];
    
    bgnd_ui_color = [UIColor colorWithRed:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_RED/255.0 green:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_GREEN/255.0 blue:(float)ZT_UI_LOCATE_TAG_COLOR_LEVEL_BLUE/255.0 alpha:1.0];
    [m_lblIndicatorValue setBackgroundColor:bgnd_ui_color];
    
    [[m_lblIndicatorValue layer] setCornerRadius:ZT_UI_LOCATE_TAG_INDICATOR_CORNER_RADIUS];
    [[m_lblIndicatorBackground layer] setCornerRadius:ZT_UI_LOCATE_TAG_INDICATOR_CORNER_RADIUS];
    
    
    /* configure tag id text field */
    [m_txtTagIdInput setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_txtTagIdInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_txtTagIdInput setKeyboardType:UIKeyboardTypeDefault];
    [m_txtTagIdInput setReturnKeyType:UIReturnKeySearch];
    [m_txtTagIdInput setClearButtonMode:UITextFieldViewModeAlways];
    [m_txtTagIdInput setBorderStyle:UITextBorderStyleNone];
    [m_txtTagIdInput setText:@""];
    NSLog(@"%@ tag is 6",m_txtTagIdInput);
    [m_txtTagIdInput setPlaceholder:@"Tag Pattern"];
      NSLog(@"%@ tag is 7",m_txtTagIdInput);
    /* text color */
    [m_txtTagIdInput setTextColor:[UIColor blackColor]];
    [m_lblDistanceData setTextColor:[UIColor blackColor]];
    [m_lblDistanceNotice setTextColor:[UIColor blackColor]];
    
    /* text */
    //[m_lblTagId setText:@"Tag ID"];
    [m_lblDistanceNotice setText:@"Relative Distance"];
    [m_lblIndicatorBackground setText:@""];
    [m_lblIndicatorValue setText:@""];
    [m_lblDistanceData setText:@""];
    [m_lblTagIdInputBackground setText:@""];
    
    /* text alignment */
    [m_lblDistanceNotice setTextAlignment:NSTextAlignmentCenter];
    [m_lblDistanceData setTextAlignment:NSTextAlignmentCenter];
 
    
    /* font size */
    [m_txtTagIdInput setFont:[UIFont systemFontOfSize:ZT_UI_LOCATE_TAG_FONT_SZ_MEDIUM]];
    [m_lblDistanceNotice setFont:[UIFont systemFontOfSize:ZT_UI_LOCATE_TAG_FONT_SZ_SMALL]];
    [m_lblDistanceData setFont:[UIFont systemFontOfSize:ZT_UI_LOCATE_TAG_FONT_SZ_BIG]];
    [m_btnStartStop.titleLabel setFont:[UIFont systemFontOfSize:ZT_UI_LOCATE_TAG_FONT_SZ_BUTTON]];
}

- (void)updateOperationDataUI
{
    int distance = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getProximityPercent];
    [self setRelativeDistance:distance];
}

- (void)setRelativeDistance:(int)distance
{
    [m_lblDistanceData setText:[NSString stringWithFormat:@"%d %%", distance]];
    [self.view removeConstraint:m_IndicatorHeightConstraint];
    m_IndicatorHeightConstraint = [NSLayoutConstraint constraintWithItem:m_lblIndicatorValue attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblIndicatorBackground attribute:NSLayoutAttributeHeight multiplier:((float)distance / 100.0) constant:0.0];
    [self.view addConstraint:m_IndicatorHeightConstraint];
}

- (void)dismissKeyboard
{
    /* just to hide keyboard */
    [m_txtTagIdInput resignFirstResponder];
}

- (void)radioStateChangedOperationRequested:(BOOL)requested aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_LOCATIONING != operation_type)
    {
        return;
    }
    
    if (YES == requested)
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setTitle:@"STOP" forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_txtTagIdInput setUserInteractionEnabled:NO];
        
        [self updateOperationDataUI];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [m_btnStartStop setTitle:@"START" forState:UIControlStateNormal];
            [m_btnStartStop layoutIfNeeded];
        }];
        
        [m_txtTagIdInput setUserInteractionEnabled:YES];
        
        /* stop timer */
        if (m_ViewUpdateTimer != nil)
        {
            [m_ViewUpdateTimer invalidate];
            m_ViewUpdateTimer = nil;
        }
        
        /* update statictics */
        [self updateOperationDataUI];
    }
}

- (void)radioStateChangedOperationInProgress:(BOOL)in_progress aType:(int)operation_type
{
    if (ZT_RADIO_OPERATION_LOCATIONING != operation_type)
    {
        return;
    }
    
    if (YES == in_progress)
    {
        /* start timer */
        m_ViewUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ZT_LOCATIONING_TIMER_INTERVAL target:self selector:@selector(updateOperationDataUI) userInfo:nil repeats:true];
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


- (BOOL)onNewTriggerEvent:(BOOL)pressed
{
    __block zt_LocateTagVC *__weak_self = self;
    
    bool requested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateLocationingRequested];
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
                /* operation is already in progress or has been requested (case of periodic start trigger */
                
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   [__weak_self btnStartStopPressed:nil];
                               });
            }
        }
    }
    return YES;
    
//    /* nrv364: process only on trigger press
//     root cause:
//     - suppose that start trigger is HH press and stop is immediate
//     - command issued
//     - trigger pressed
//     - trigger PRESS notification from RFID
//     - operation START notification from RFID
//     - trigger released
//     - trigger RELEASE notification from RFID
//     - we abort ongoing operation */
//    if (YES == pressed)
//    {
//        /* nrv364:
//         with periodic start trigger operation start/stop notifications indicate
//         inventory "loops" and abort cmd is required to stop the on going operation */
//        if ((YES == [[zt_RfidAppEngine sharedAppEngine] isRadioOperationInProgress]) ||
//            ((YES == m_OperationRequested) && (YES == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerPeriodic])))
//        {
//            /* op in progress -> shall stop */
//            
//            if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStopTriggerHandheld])
//            {
//                /* if stop trigger is HH than we have no reason to perform a stop action manually */
//                dispatch_async(dispatch_get_main_queue(),
//                               ^{
//                                   [__weak_self btnStartStopPressed:nil];
//                               });
//            }
//        }
//        else
//        {
//            /* op not in progress -> shall start */
//            if (NO == m_OperationRequested)
//            {
//                if (NO == [[[zt_RfidAppEngine sharedAppEngine] sledConfiguration] isStartTriggerHandheld])
//                {
//                    /* if start trigger is HH than we have no reason to perform a start action manually */
//                    dispatch_async(dispatch_get_main_queue(),
//                                   ^{
//                                       [__weak_self btnStartStopPressed:nil];
//                                   });
//                }
//            }
//        }
//        
//    }
//    return YES;
}


/* ###################################################################### */
/* ########## Text Field Delegate Protocol implementation ############### */
/* ###################################################################### */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /* just to hide keyboard */
    [textField resignFirstResponder];
    return YES;
}

@end
