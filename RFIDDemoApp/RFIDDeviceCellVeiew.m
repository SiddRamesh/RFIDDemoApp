//
//  RFIDDeviceCellViewTableViewCell.m
//  RFIDDemoApp
//
//  Created by SST on 11/03/15.
//  Copyright (c) 2015 Motorola Solutions. All rights reserved.
//

#import "RFIDDeviceCellView.h"
#import "ui_config.h"
#import "RfidSdkDefs.h"

@interface zt_RFIDDeviceCellView()
{
    UILabel *m_lblDeviceName;
    UILabel *m_lblBluetoothAddress;
    
    UILabel *m_lblSerialNotice;
    UILabel *m_lblSerialData;
    UILabel *m_lblModelNotice;
    UILabel *m_lblModelData;
    
    BOOL m_AutoLayoutIsPerformed;
    BOOL m_ShowActive;
}
@end

@implementation zt_RFIDDeviceCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        m_lblDeviceName = [[UILabel alloc] init];
        m_lblBluetoothAddress = [[UILabel alloc] init];
        
        m_lblSerialNotice = [[UILabel alloc] init];
        m_lblSerialData = [[UILabel alloc] init];
        m_lblModelNotice = [[UILabel alloc] init];
        m_lblModelData = [[UILabel alloc] init];


        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_lblDeviceName) {
        [m_lblDeviceName release];
    }
    
    if (nil != m_lblBluetoothAddress)
    {
        [m_lblBluetoothAddress release];
    }
    
    if (nil != m_lblSerialData)
    {
        [m_lblSerialData release];
    }
    
    if (nil != m_lblSerialNotice)
    {
        [m_lblSerialNotice release];
    }
    
    if (nil != m_lblModelNotice)
    {
        [m_lblModelNotice release];
    }
    
    if (nil != m_lblModelData)
    {
        [m_lblModelData release];
    }
    [super dealloc];
}

- (void)updateConstraints
{
    [super updateConstraints];

    
    [self.contentView removeConstraints:[self.contentView constraints]];
    
    // fix to connect view and content view
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self addConstraint:c2];
    
    NSDictionary *labelsDictionary = @{@"name":m_lblDeviceName, @"btName":m_lblBluetoothAddress, @"serialNotice":m_lblSerialNotice, @"serialData":m_lblSerialData, @"modelNotice":m_lblModelNotice, @"modelData":m_lblModelData};
    
    NSNumber *margin = [NSNumber numberWithInt:ZT_UI_CELL_TAG_INDENT_INT_BIG];
    NSDictionary *metrics = @{@"space": margin,@"spaceS": @0};
    
    if(m_ShowActive)
    {
        NSArray *constraint_POS_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[name]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[btName]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_H3 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[serialNotice]-space-[serialData]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_H4 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[modelNotice]-space-[modelData]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        [self.contentView addConstraints:constraint_POS_H1];
        [self.contentView addConstraints:constraint_POS_H2];
        [self.contentView addConstraints:constraint_POS_H3];
        [self.contentView addConstraints:constraint_POS_H4];
        
        NSArray *constraint_WIDTH1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[serialNotice(==modelNotice)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        [self.contentView addConstraints:constraint_WIDTH1];
        
        NSArray *constraint_POS_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[name]-spaceS-[btName]-space-[serialData]-spaceS-[modelData]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_V2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[btName]-space-[serialNotice]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_V3 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[serialData]-spaceS-[modelNotice]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
        NSArray *constraint_POS_V4 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[modelData(>=serialData)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        [self.contentView addConstraints:constraint_POS_V1];
        [self.contentView addConstraints:constraint_POS_V2];
        [self.contentView addConstraints:constraint_POS_V3];
        [self.contentView addConstraints:constraint_POS_V4];
        
        NSLayoutConstraint *c3 =  [NSLayoutConstraint constraintWithItem:m_lblSerialNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.2 constant:0.0];
        [self.contentView addConstraint:c3];
        
        NSLayoutConstraint *c4 =  [NSLayoutConstraint constraintWithItem:m_lblModelNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.2 constant:0.0];
        [self.contentView addConstraint:c4];
    }
    else
    {
        if([[m_lblBluetoothAddress text] length]>0)
        {
            
            NSArray *constraint_POS_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[name]-space-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:labelsDictionary];
            
            NSArray *constraint_POS_H2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[btName]-space-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:labelsDictionary];
            
            [self.contentView addConstraints:constraint_POS_H1];
            [self.contentView addConstraints:constraint_POS_H2];
            
            NSArray *constraint_POS_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[name]-spaceS-[btName]-space-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:labelsDictionary];
            
            NSArray *constraint_POS_V2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[btName]-space-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:labelsDictionary];
            
            [self.contentView addConstraints:constraint_POS_V1];
            [self.contentView addConstraints:constraint_POS_V2];
            
            
        }
        else
        {
            NSArray *constraint_POS_H1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[name]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
            [self.contentView addConstraints:constraint_POS_H1];

            NSArray *constraint_POS_V1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-space-[name]-space-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:labelsDictionary];
        
            [self.contentView addConstraints:constraint_POS_V1];
        }

    }
    m_AutoLayoutIsPerformed = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    m_lblBluetoothAddress.preferredMaxLayoutWidth = CGRectGetWidth(m_lblBluetoothAddress.frame);
    m_lblSerialNotice.preferredMaxLayoutWidth = CGRectGetWidth(m_lblSerialNotice.frame);
    m_lblSerialData.preferredMaxLayoutWidth = CGRectGetWidth(m_lblSerialData.frame);
    m_lblModelNotice.preferredMaxLayoutWidth = CGRectGetWidth(m_lblModelNotice.frame);
    m_lblModelData.preferredMaxLayoutWidth = CGRectGetWidth(m_lblModelData.frame);
}

- (void)configureAppearance
{
    m_lblDeviceName.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblDeviceName.numberOfLines = 0;
    m_lblDeviceName.translatesAutoresizingMaskIntoConstraints = NO;
    
    m_lblBluetoothAddress.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblBluetoothAddress.numberOfLines = 0;
    m_lblBluetoothAddress.translatesAutoresizingMaskIntoConstraints = NO;

    m_lblSerialNotice.translatesAutoresizingMaskIntoConstraints = NO;
    
    m_lblSerialData.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblSerialData.numberOfLines = 0;
    m_lblSerialData.translatesAutoresizingMaskIntoConstraints = NO;
    
    m_lblModelNotice.translatesAutoresizingMaskIntoConstraints = NO;
    
    m_lblModelData.lineBreakMode = NSLineBreakByWordWrapping;
    m_lblModelData.numberOfLines = 0;
    m_lblModelData.translatesAutoresizingMaskIntoConstraints = NO;
    
    [m_lblDeviceName setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_BIG]];
    [m_lblBluetoothAddress setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    
    [m_lblModelNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_SMALL]];
    [m_lblModelData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_SMALL]];
    [m_lblSerialNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_SMALL]];
    [m_lblSerialData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_SMALL]];
    
    m_lblModelNotice.textColor = [UIColor grayColor];
    m_lblModelData.textColor = [UIColor grayColor];
    m_lblSerialData.textColor = [UIColor grayColor];
    m_lblSerialNotice.textColor = [UIColor grayColor];
    
    /* workaround for iOS 8.0 - see comment in updateConstraints */
    [[self contentView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblDeviceName];
    [[self contentView] addSubview:m_lblBluetoothAddress];
    [[self contentView] addSubview:m_lblModelData];
    [[self contentView] addSubview:m_lblModelNotice];
    [[self contentView] addSubview:m_lblSerialNotice];
    [[self contentView] addSubview:m_lblSerialData];
}

- (void)setDataWithReaderInfo:(srfidReaderInfo *)info widthIndex:(int)idx
{
    // toDo check data from info
   // [m_lblName setText:[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"RFID reader Z%d", [info getReaderID]]]];
    [m_lblDeviceName setText:[NSString stringWithFormat:@"%@",[info getReaderName]]];
    
    [m_lblModelNotice setText:@"Model:"];
    [m_lblModelData setText:@""];
    
    [m_lblSerialNotice setText:@"Serial:"];
    [m_lblSerialData setText:@""];
    
    NSString *connectionStr;
    switch ([info getConnectionType])
    {
        case SRFID_CONNTYPE_MFI:
            connectionStr = @"MFi";
            break;
        case SRFID_CONNTYPE_BTLE:
            connectionStr = @"BT LE";
            break;
        default:
            connectionStr = @"Unknown type";
    }
    
}

- (void)setActiveWithModel:(NSString *)model withSerial:(NSString *)serial withBTAddress:(NSString*)bt_address
{
    m_ShowActive = YES;
//    [m_lblName setFont:[UIFont boldSystemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];

    [m_lblDeviceName setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [m_lblBluetoothAddress setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [m_lblModelNotice setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [m_lblModelData setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [m_lblSerialNotice setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    [m_lblSerialData setTextColor:[UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f]];
    
    [m_lblModelData setText:model];
    [m_lblSerialData setText:serial];
    
    if (6*2 == [bt_address length])
    {
        NSString *_bt_address = @"";
        for (int i = 0; i < 6; i++)
        {
            _bt_address = [_bt_address stringByAppendingString:[NSString stringWithString:[bt_address substringWithRange:NSMakeRange(i*2, 2)]]];
            if (i < 5)
            {
                _bt_address = [_bt_address stringByAppendingString:@":"];
            }
        }
        [m_lblBluetoothAddress setText:_bt_address];
    }
    else
    {
        [m_lblBluetoothAddress setText:bt_address];
    }
    
    [[self contentView] addSubview:m_lblModelData];
    [[self contentView] addSubview:m_lblModelNotice];
    [[self contentView] addSubview:m_lblSerialNotice];
    [[self contentView] addSubview:m_lblSerialData];
    [[self contentView] addSubview:m_lblBluetoothAddress];
}

- (void) setActiveWithNoValues
{
    m_ShowActive = NO;
    
    m_lblDeviceName.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    m_lblBluetoothAddress.textColor = [UIColor grayColor];
    m_lblModelNotice.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    m_lblModelData.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    m_lblSerialData.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    m_lblSerialNotice.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    
     [m_lblBluetoothAddress setText:@"Reader running in Batch Mode"];
    [[self contentView] addSubview:m_lblBluetoothAddress];
    
    [m_lblModelData removeFromSuperview];
    [m_lblModelNotice removeFromSuperview];
    [m_lblSerialNotice removeFromSuperview];
    [m_lblSerialData removeFromSuperview];
   // [m_lblBluetoothAddress removeFromSuperview];

    
    
}


- (void)setUnactive
{
    m_ShowActive = NO;
    
    [m_lblBluetoothAddress setText:@""];
    
    m_lblDeviceName.textColor = [UIColor blackColor];
    m_lblBluetoothAddress.textColor = [UIColor blackColor];
    m_lblModelNotice.textColor = [UIColor grayColor];
    m_lblModelData.textColor = [UIColor grayColor];
    m_lblSerialData.textColor = [UIColor grayColor];
    m_lblSerialNotice.textColor = [UIColor grayColor];
    
    [m_lblModelData removeFromSuperview];
    [m_lblModelNotice removeFromSuperview];
    [m_lblSerialNotice removeFromSuperview];
    [m_lblSerialData removeFromSuperview];
    [m_lblBluetoothAddress removeFromSuperview];
}

@end
