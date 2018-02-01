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
 *  Description:  UIButton+VerticalButtonFactory.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface UIButton (HomeScreenButtonsFactory)

+(UIButton *)buttonForHomeScreenWithSize:(CGSize) size withType:(int)zt_buttonType;
+(UIButton *) buttonForHomeScreen:(int)zt_buttonType;
+(UIButton *) buttonForHomeScreenWithFrame:(CGRect)frame withButtonType:(int)zt_buttonType;
+(void) alignHomeButtonContent:(UIButton *)button;
@end
