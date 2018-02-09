//
//  ScanVC.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 1/31/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFIDTagCellView.h"
#import "RfidSdkDefs.h"
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

#import "MaterialControls/MDButton.h"

@interface ScanVC : BaseDpoVC <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,NSURLSessionTaskDelegate, NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSXMLParserDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener, MDButtonDelegate> {
    
     IBOutlet UIButton *m_btnStartStop;
     NSTimer *m_ViewUpdateTimer;
    
     UITableView *tableView;
     UITableView *m_tblTags;
     zt_RFIDTagCellView *m_OffscreenTagCell;
     zt_EnumMapper *m_Mapper;
    
     SRFID_MEMORYBANK m_SelectedInventoryOption;
     NSMutableArray *m_Tags;
    
    UILabel *batchModeLabel;
    UIBarButtonItem *m_btnOptions;
    
    BOOL flag;
}

@property (nonatomic, retain) IBOutlet UITableView *m_tblTags;

@property (nonatomic, retain) IBOutlet MDButton *FloatingResetButton;

-(IBAction)resetData:(id)sender;


@end
