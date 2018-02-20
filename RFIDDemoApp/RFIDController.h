//
//  RFIDController.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/17/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RFIDTagCellView.h"
#import "RfidSdkDefs.h"
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

@protocol TagSearchDelegate
- (void)retrievedTagsFromSearch:(NSString *)tags :(NSError*)error;
@end

@interface RFIDController : BaseDpoVC <UITableViewDataSource,UITableViewDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener>
{
    
    IBOutlet UIButton *m_btnStartStop;
    NSTimer *m_ViewUpdateTimer;
    
    IBOutlet UITableView *m_tblTags;
    zt_EnumMapper *m_Mapper;
    
    SRFID_MEMORYBANK m_SelectedInventoryOption;
    NSMutableArray *m_Tags;
    
    UILabel *batchModeLabel;
    UIBarButtonItem *m_btnOptions;
    
    BOOL flag;
}

@property (nonatomic, copy) void (^completionHandler)(void);
-(void) searchForTags:(NSString*) query :(id<TagSearchDelegate>) delegate;

@end
