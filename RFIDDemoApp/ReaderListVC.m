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
 *  Description:  ReaderListVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ReaderListVC.h"
#import "ui_config.h"
#import "RfidAppKeys.h"
#import "AppConfiguration.h"
#import "RFIDDeviceCellView.h"

#define ZT_CELL_ID_READER_INFO                    @"ID_CELL_READER_INFO"
#define ZT_CELL_ID_NO_READER                      @"NO_READER"

@interface zt_ReaderListVC ()
{
    zt_RFIDDeviceCellView *m_OffScreenTagCell;
    NSTimer *indicatorTimer;
}
@property (retain, nonatomic) IBOutlet UIButton *locateReaderButton;
@property (retain, nonatomic) IBOutlet UIView *locatingIndicator;
@property (retain, nonatomic) IBOutlet UIView *locatingHeader;

@end

@implementation zt_ReaderListVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ReaderList = [[NSMutableArray alloc] init];
        
        m_OffScreenTagCell = [[zt_RFIDDeviceCellView alloc] init];

        
        m_ActiveReaderIdx = -1;
        m_ActiveReaderId = -1;
        m_EmptyDevList = YES;
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_ReaderList)
    {
        [m_ReaderList removeAllObjects];
        [m_ReaderList release];
    }
    
    if (m_OffScreenTagCell != nil)
    {
        [m_OffScreenTagCell release];
    }

    [m_tblReaderList release];
    [_locateReaderButton release];
    [_locatingIndicator release];
    [_locatingHeader release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_tblReaderList setDelegate:self];
    [m_tblReaderList setDataSource:self];
    [m_tblReaderList registerClass:[zt_RFIDDeviceCellView class] forCellReuseIdentifier:ZT_CELL_ID_READER_INFO];
    [m_tblReaderList registerClass:[UITableViewCell class] forCellReuseIdentifier:ZT_CELL_ID_NO_READER];
    
    /* prevent table view from showing empty not-required cells or extra separators */
    [m_tblReaderList setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
    
    /* set title */
    [self setTitle:@"Readers List"];
    self.locatingIndicator.layer.cornerRadius = 10;
    self.locatingIndicator.backgroundColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    //indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(animateLocatorIndicator) userInfo:nil repeats:YES];
    
}
    
- (void)startTimer{
    if (!indicatorTimer) {
        indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(animateLocatorIndicator) userInfo:nil repeats:YES];
    
    }
}
    
- (void)stopTimer{
    if ([indicatorTimer isValid]) {
        [indicatorTimer invalidate];
    }
    indicatorTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    /* just to reload data from app engine */
    
    [self deviceListHasBeenUpdated];
    
    
    NSMutableArray *right_items = [[NSMutableArray alloc] init];
    
    
    if ([right_items count] == 0)
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = right_items;
    }
    
    [right_items removeAllObjects];
    [right_items release];
    
}
- (void) animateLocatorIndicator{
    
    CGFloat newR;
    CGFloat newX;
    CGFloat newY;


    if (self.locatingIndicator.frame.size.height == 20) {
        newR = 15;
        newX = self.locatingIndicator.frame.origin.x + 3;
        newY = self.locatingIndicator.frame.origin.y + 3;

    }
    else if (self.locatingIndicator.frame.size.height == 17){
        newR = 20;
        newX = self.locatingIndicator.frame.origin.x - 2;
        newY = self.locatingIndicator.frame.origin.y - 2;
        
    }
    else if (self.locatingIndicator.frame.size.height == 15){
        newR = 17;
        newX = self.locatingIndicator.frame.origin.x - 1;
        newY = self.locatingIndicator.frame.origin.y - 1;
    }
    
    self.locatingIndicator.frame = CGRectMake(newX, newY, newR, newR);

}
- (void) setLocateReaderButtonState{
    if (m_ActiveReaderIdx == -1) {
        self.locateReaderButton.hidden = YES;
        self.locatingHeader.hidden = YES;
    }
    else{
        self.locateReaderButton.hidden = NO;
        if ([zt_RfidAppEngine sharedAppEngine].isLocatingDevice) {
            [self.locateReaderButton setTitle:@"STOP LOCATING" forState:UIControlStateNormal];
            [self startTimer];
            self.locatingHeader.hidden = NO;
        }
        else{
            [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
            self.locatingHeader.hidden = YES;
            [self stopTimer];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];
    [self stopLocatingReaderIfAny];
    
}
- (void)stopLocatingReaderIfAny{
    SRFID_RESULT conn_result;
    if (-1 != m_ActiveReaderId)
    {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:NO message:nil];
        }
    }

    if (conn_result == SRFID_RESULT_SUCCESS) {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            {
                [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
                [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
                [self stopTimer];
            }
        }
    }
}

/* ###################################################################### */
/* ########## zt_IRfidAppEngineDevListDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)deviceListHasBeenUpdated
{
    /* TBD: check whether we still have reader that was active */

    if ([[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count] > 0)
    {
        /* determine actual status of previously active scanner */
        NSArray *lst = [[zt_RfidAppEngine sharedAppEngine] getActualDeviceList];
        BOOL found = NO;
        
        srfidReaderInfo *info = nil;
        for (int i = 0; i < [lst count]; i++)
        {
            info = (srfidReaderInfo*)[lst objectAtIndex:i];
            if (m_ActiveReaderId != -1)
            {
                if ([info getReaderID] == m_ActiveReaderId)
                {
                    m_ActiveReaderIdx = i;
                    found = YES;
                    break;
                }
            }
            else
            {
                if (YES == [info isActive])
                {
                    m_ActiveReaderId = [info getReaderID];
                    m_ActiveReaderIdx = i;
                    found = YES;
                    break;
                }
            }
        }
        
        if (NO == found)
        {
            m_ActiveReaderId = -1;
            m_ActiveReaderIdx = -1;
        }
    }
    
    [m_tblReaderList reloadData];
    [self setLocateReaderButtonState];
    
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
    int count = (int)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] count];
    if (0 == count)
    {
        m_ActiveReaderIdx = -1;
        m_ActiveReaderId = -1;
        m_EmptyDevList = YES;
        count = 1;
    }
    else
    {
        m_EmptyDevList = NO;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!m_EmptyDevList)
    {
        return [self deviceInfoCellAtIndexPath:indexPath];
    }
    else
    {
        return [self noDeviceCellAtIndexPath:indexPath];
    }
}

- (zt_RFIDDeviceCellView *)deviceInfoCellAtIndexPath:indexPath
{
    zt_RFIDDeviceCellView *cell = [m_tblReaderList dequeueReusableCellWithIdentifier:ZT_CELL_ID_READER_INFO forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[zt_RFIDDeviceCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ZT_CELL_ID_READER_INFO];
    }
    
    int idx = (int)[indexPath row];
    
    srfidReaderInfo *info = (srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:idx];
    [cell setDataWithReaderInfo:info widthIndex:idx];
    
    if (idx == m_ActiveReaderIdx)
    {
        zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
        
        if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
        {
            [cell setActiveWithNoValues];
        }
        else if (sled.readerModel != nil)
        {
            [cell setActiveWithModel:[sled readerModel] withSerial:[sled readerSerialNumber] withBTAddress:[sled readerBTAddress]];
        }
        else
        {
            [cell setActiveWithModel:@"Unknown" withSerial:@"Unknown" withBTAddress:@"Unknown"];
        }
    }
    else
    {
        [cell setUnactive];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    
    return cell;
}

- (UITableViewCell *)noDeviceCellAtIndexPath:indexPath
{
    UITableViewCell *cell = [m_tblReaderList dequeueReusableCellWithIdentifier:ZT_CELL_ID_NO_READER forIndexPath:indexPath];
    [cell.textLabel setText:@"NO available readers"];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    return cell;
}

/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!m_EmptyDevList)
    {
        return [self heightForDeviceInfoCellAtIndexPath:indexPath];
    }
    else
    {
        return [self heightForNoDeviceCellAtIndexPath:indexPath];
    }
}

- (CGFloat)heightForDeviceInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.5;
    
    srfidReaderInfo *info = (srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:(int)[indexPath row]];
    [m_OffScreenTagCell setDataWithReaderInfo:info widthIndex:(int)[indexPath row]];
    
    zt_SledConfiguration * sled = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
    
    int idx = (int)[indexPath row];
    if (idx == m_ActiveReaderIdx)
    {
        if(![[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive] && [[[zt_RfidAppEngine sharedAppEngine] activeReader] getBatchModeStatus])
        {
            [m_OffScreenTagCell setActiveWithNoValues];
        }
        else if (sled.readerModel != nil)
        {
            [m_OffScreenTagCell setActiveWithModel:[sled readerModel] withSerial:[sled readerSerialNumber] withBTAddress:[sled readerBTAddress]];
        }
        else
        {
            [m_OffScreenTagCell setActiveWithModel:@"Unknown" withSerial:@"Unknown" withBTAddress:@"Unknown"];
        }
    }
    else
    {
        [m_OffScreenTagCell setUnactive];

    }
    
    [m_OffScreenTagCell setNeedsUpdateConstraints];
    [m_OffScreenTagCell updateConstraintsIfNeeded];
        
        //m_OffscreenTagCell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(m_tblTags.bounds), CGRectGetHeight(m_OffscreenTagCell.bounds));
        
    [m_OffScreenTagCell setNeedsLayout];
    [m_OffScreenTagCell layoutIfNeeded];
        
    height = [m_OffScreenTagCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1.0;
    
    return height;

}

- (CGFloat)heightForNoDeviceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] init] autorelease];
    return cell.frame.size.height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (NO == m_EmptyDevList)
    {
        int idx = (int)[indexPath row];
        
        NSMutableArray *index_paths = [[NSMutableArray alloc] init];
        
        if (-1 != m_ActiveReaderIdx)
        {
            [index_paths addObject:[NSIndexPath indexPathForRow:m_ActiveReaderIdx inSection:0]];
        }
        
        if (idx == m_ActiveReaderIdx)
        {
            m_ActiveReaderIdx = -1; /* emulate disconnection */
            int _id = m_ActiveReaderId;
            m_ActiveReaderId = -1;
            [[zt_RfidAppEngine sharedAppEngine] disconnect:_id];
        }
        else
        {
            if (-1 != m_ActiveReaderId)
            {
                int _id = m_ActiveReaderId;
                m_ActiveReaderIdx = -1;
                m_ActiveReaderId = -1;
                [[zt_RfidAppEngine sharedAppEngine] disconnect:_id];
            }
            
            //m_ActiveReaderIdx = idx; /* emulate connection */
            //m_ActiveReaderId = [(srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:idx] getReaderID];
           
            [[zt_RfidAppEngine sharedAppEngine] connect:[(srfidReaderInfo*)[[[zt_RfidAppEngine sharedAppEngine] getActualDeviceList] objectAtIndex:idx] getReaderID]];
            [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
            //[index_paths addObject:[NSIndexPath indexPathForRow:m_ActiveReaderIdx inSection:0]];
        }
        
        [tableView reloadRowsAtIndexPaths:index_paths withRowAnimation:UITableViewRowAnimationFade];
        
        [index_paths removeAllObjects];
        [index_paths release];
    }

}
- (IBAction)locateReaderAction:(id)sender {
    SRFID_RESULT conn_result;
    if (-1 != m_ActiveReaderId)
    {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"LOCATE READER"]) {
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:YES message:nil];
            //[self.locateReaderButton setTitle:@"Stop Locating" forState:UIControlStateNormal];

        }
        else if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            conn_result = [[zt_RfidAppEngine sharedAppEngine] locateReader:NO message:nil];
            //[self.locateReaderButton setTitle:@"Locate Connected Device" forState:UIControlStateNormal];


        }
    }

    if (conn_result == SRFID_RESULT_SUCCESS) {
        if ([self.locateReaderButton.titleLabel.text isEqualToString:@"LOCATE READER"])
        {
            [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = YES;
            [self.locateReaderButton setTitle:@"STOP LOCATING" forState:UIControlStateNormal];
            [self startTimer];
            self.locatingHeader.hidden = NO;
        }
        else if ([self.locateReaderButton.titleLabel.text isEqualToString:@"STOP LOCATING"]){
            {
                [zt_RfidAppEngine sharedAppEngine].isLocatingDevice = NO;
                [self.locateReaderButton setTitle:@"LOCATE READER" forState:UIControlStateNormal];
                self.locatingHeader.hidden = YES;
                [self stopTimer];

            }
        }
    }
}

@end
