//
//  Photos.m
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import "Photo.h"

@implementation Photo
@synthesize photoId=_photoId;
@synthesize photoUrl=_photoUrl;
@synthesize photoTitle=_photoTitle;
@synthesize photoAuthor=_photoAuthor;
@synthesize photoIcon=_photoIcon;

- (id)initWithId:(NSInteger)photoId url:(NSString *)photoUrl title:(NSString *)photoTitle author:(NSString *)photoAuthor
{
    self = [super init];
    if (self) {
        self.photoId = photoId;
        self.photoUrl = photoUrl;
        self.photoTitle = photoTitle;
        self.photoAuthor = photoAuthor;
    }
    return self;
}

- (void)dealloc
{
    self.photoUrl = nil;
    self.photoTitle = nil;
    self.photoAuthor = nil;
    self.photoIcon = nil;
    [super dealloc];
}
@end
