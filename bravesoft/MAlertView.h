//
//  MAlertView.h
//  bravesoft
//
//  Created by And.He on 13-1-30.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAlertView : UIAlertView
{
    UITextField *passwordField;
    NSInteger textFieldCount;
}

- (void)addTextField:(UITextField *)aTextField placeHolder:(NSString *)placeHolder;
@end
