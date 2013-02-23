//
//  MAlertView.m
//  bravesoft
//
//  Created by And.He on 13-1-30.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import "MAlertView.h"

#define kMAlertViewTextFieldHeight 30
#define kMAlertViewTextFieldMargin 10

@implementation MAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    return self;
}

- (void)addTextField:(UITextField *)aTextField placeHolder:(NSString *)placeHolder
{
    if (aTextField) {
        textFieldCount++;
        aTextField.frame = CGRectZero;
        aTextField.borderStyle = UITextBorderStyleRoundedRect;
        aTextField.placeholder = placeHolder;
        [self addSubview:aTextField];
    }
}

- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    rect.size.height += textFieldCount * (kMAlertViewTextFieldHeight + kMAlertViewTextFieldMargin);
    self.bounds = rect;
    float maxLabelY = 0.f;
    int textFieldIndex = 0;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            
        }
        else if ([view isKindOfClass:[UILabel class]]) {
            rect = view.frame;
            maxLabelY = rect.origin.y + rect.size.height;
        }
        else if ([view isKindOfClass:[UITextField class]]) {
            rect = view.frame;
            rect.size.width = self.bounds.size.width - 2*kMAlertViewTextFieldMargin;
            rect.size.height = kMAlertViewTextFieldHeight;
            rect.origin.x = kMAlertViewTextFieldMargin;
            rect.origin.y = maxLabelY + kMAlertViewTextFieldMargin*(textFieldIndex+1) + kMAlertViewTextFieldHeight*textFieldIndex;
            view.frame = rect;
            textFieldIndex++;
        }
        else {
            rect = view.frame;
            rect.origin.y = self.bounds.size.height - 65.0;
            view.frame = rect;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
