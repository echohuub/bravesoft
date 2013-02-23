//
//  Photos.h
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject
{
    NSInteger _photoId;
    NSString *_photoUrl;
    NSString *_photoTitle;
    NSString *_photoAuthor;
    UIImage *_photoIcon;
}

@property (nonatomic, assign) NSInteger photoId;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, copy) NSString *photoTitle;
@property (nonatomic, copy) NSString *photoAuthor;
@property (nonatomic, retain) UIImage *photoIcon;

- (id)initWithId:(NSInteger)photoId url:(NSString *)photoUrl title:(NSString *)photoTitle author:(NSString *)photoAuthor;
@end
