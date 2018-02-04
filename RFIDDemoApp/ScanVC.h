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

@interface ScanVC : BaseDpoVC <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,NSURLSessionTaskDelegate, NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSXMLParserDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener> {
    
//    NSString *serialLbl;
//    NSString *iecLbl;
//    NSString *billLbl;
//    NSString *truckLbl;
//    NSString *codebl;
//    NSString *portLbl;
//    NSString *dateLbl;
//    NSString *timeLbl;
//    NSString *enteryByLbl;
//    NSString *esealLbl;
    
     UITableView *tableView;
    
  //   UITableView *m_tblTags;
     IBOutlet UIButton *m_btnStartStop;
     NSTimer *m_ViewUpdateTimer;
    
     zt_RFIDTagCellView *m_OffscreenTagCell;
     zt_EnumMapper *m_Mapper;
    
     SRFID_MEMORYBANK m_SelectedInventoryOption;
     NSMutableArray *m_Tags;
    
    UILabel *batchModeLabel;
    UIBarButtonItem *m_btnOptions;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

//@property(nonatomic, retain) IBOutlet UITableView *m_tblTags;


@end
