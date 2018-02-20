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
 //    zt_RFIDTagCellView *m_OffscreenTagCell;
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

- (void)showPopupWithTagStatus:(NSString *)imageName found:(NSString *)string;


//MARK: - Properties

@property (nonatomic,copy) NSString *serialLbl;
@property (nonatomic,copy) NSString *iecLbl;
@property (nonatomic,copy) NSString *billLbl;
@property (nonatomic,copy) NSString *truckLbl;
@property (nonatomic,copy) NSString *codebl;
@property (nonatomic,copy) NSString *portLbl;
@property (nonatomic,copy) NSString *dateLbl;
@property (nonatomic,copy) NSString *timeLbl;
@property (nonatomic,copy) NSString *enteryByLbl;
@property (nonatomic,copy) NSString *esealLbl;
@property (retain, nonatomic) IBOutlet UITableViewCell *serialCellView;

@property (nonatomic, assign) NSString *tagIdStr;

@property (retain, nonatomic) IBOutlet UILabel *Serial;
@property (retain, nonatomic) IBOutlet UILabel *iec;
@property (retain, nonatomic) IBOutlet UILabel *eseal;
@property (retain, nonatomic) IBOutlet UILabel *truck;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UILabel *port;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *bill;
@property (retain, nonatomic) IBOutlet UILabel *shipDate;
@property (retain, nonatomic) IBOutlet UILabel *container;

@property(nonatomic, retain) UILabel *tag;

@property (nonatomic,copy) NSString *currentElement;
@property (nonatomic,copy) NSString *ele1;
@property (nonatomic,copy) NSMutableData *webResponseData;




@end
