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
 *  Description:  LabelInputFieldCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "LabelInputFieldCellView.h"
#import "ui_config.h"

@implementation zt_LabelInputFieldCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_txtDataField = [[UITextField alloc] init];
        [m_txtDataField setDelegate:self];
        m_lblInfoNotice = [[UILabel alloc] init];
        m_InputFieldWidthConstraint = nil;
        
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_txtDataField)
    {
        [m_txtDataField release];
    }
    if (nil != m_lblInfoNotice)
    {
        [m_lblInfoNotice release];
    }
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* workaround: in some cases the super implementation does NOT call layoutSubviews
     on the content view of UITableViewCell*/
    
    [self.contentView layoutSubviews];
}


- (void)updateConstraints
{
    [super updateConstraints];
    if (NO == m_AutoLayoutIsPerformed)
    {
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        if (nil == m_InputFieldWidthConstraint)
        {
            m_InputFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:(float)m_InputFieldWidth / 100.0 constant:0.0];
        }
        [self.contentView addConstraint:m_InputFieldWidthConstraint];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_txtDataField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c70];

        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    m_InputFieldWidth = 40;
    
    [m_txtDataField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_txtDataField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_txtDataField setKeyboardType:UIKeyboardTypeDefault];
    [m_txtDataField setReturnKeyType:UIReturnKeyDone];
    [m_txtDataField setClearButtonMode:UITextFieldViewModeAlways];
    [m_txtDataField setBorderStyle:UITextBorderStyleRoundedRect];
    [m_txtDataField setBackgroundColor:[UIColor whiteColor]];
    [m_txtDataField setText:@""];
    
    
    [m_txtDataField setTextColor:[UIColor blackColor]];
    [m_txtDataField setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_TEXT_FIELD]];
    
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblInfoNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblInfoNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoNotice setText:@""];
    
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [m_txtDataField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_txtDataField];
}

- (void)setData:(NSString*)data
{
    [m_txtDataField setText:[NSString stringWithFormat:@"%@", data]];
}

- (NSString*)getCellData
{
    return [m_txtDataField text];
}

- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:[NSString stringWithFormat:@"%@", notice]];
}

- (void)setDataFieldWidth:(int)width
{
    m_InputFieldWidth = width;
    if (m_InputFieldWidthConstraint != nil)
    {
        [self.contentView removeConstraint:m_InputFieldWidthConstraint];
    }
    
    m_InputFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:m_txtDataField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:(float)m_InputFieldWidth / 100.0 constant:0.0];
    [self.contentView addConstraint:m_InputFieldWidthConstraint];
}

- (void)setKeyboardType:(UIKeyboardType)type
{
    [m_txtDataField setKeyboardType:type];
}

- (UITextField *)getTextField
{
    return m_txtDataField;
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}

@end
