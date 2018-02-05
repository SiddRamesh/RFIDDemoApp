//
//  VerifyVCViewController.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 04/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFIDTagCellView.h"
#import "RfidSdkDefs.h"
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

@interface VerifyVCViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, NSURLSessionTaskDelegate, NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSXMLParserDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener> {
    
    zt_RFIDTagCellView *m_OffscreenTagCell;
    zt_EnumMapper *m_Mapper;
    SRFID_MEMORYBANK m_SelectedInventoryOption;
    NSMutableArray *m_Tags;
    NSTimer *m_ViewUpdateTimer;
    UILabel *batchModeLabel;
    
    UIButton *m_btnStartStop;
    UIBarButtonItem *m_btnOptions;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
