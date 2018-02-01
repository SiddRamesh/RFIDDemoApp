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
 *  Description:  PickerCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "PickerCellView.h"
#import "ui_config.h"

@implementation zt_PickerCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_PickerView = [[UIPickerView alloc] init];
        m_Choices = [[NSMutableArray alloc] init];
        m_SelectedChoice = 0;
        m_AutoLayoutIsPerformed = NO;
        
        [m_PickerView setDelegate:self];
        [m_PickerView setDataSource:self];
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_PickerView)
    {
        [m_PickerView release];
    }
    if (nil != m_Choices)
    {
        [m_Choices removeAllObjects];
        [m_Choices release];
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
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_PickerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    [m_PickerView setShowsSelectionIndicator:YES];
    
    [m_PickerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_PickerView];
}

- (void)setChoices:(NSArray*)choices
{
    [m_Choices removeAllObjects];
    [m_Choices addObjectsFromArray:choices];
    [m_PickerView reloadAllComponents];
}

- (int)getSelectedChoice
{
    return m_SelectedChoice;
}

- (void)setSelectedChoice:(int)choice
{
    m_SelectedChoice = choice;
    [m_PickerView selectRow:m_SelectedChoice inComponent:0 animated:YES];
}

/* ###################################################################### */
/* ########## UIPickerViewDataSource Protocol implementation ############ */
/* ###################################################################### */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [m_Choices count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return (NSString*)[m_Choices objectAtIndex:row];
}

/* ###################################################################### */
/* ########## UIPickerViewDelegate Protocol implementation ############## */
/* ###################################################################### */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    m_SelectedChoice = (int)row;
    if (nil != m_Delegate)
    {
        [m_Delegate didChangeValue:self];
    }
}


@end
