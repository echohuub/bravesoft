//
//  IconDownloader.h
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;
@protocol IconDownloaderDelegate;
@interface IconDownloader : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<IconDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (void)startDownload;
- (void)cancelDownload;
@end

@protocol IconDownloaderDelegate <NSObject>

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
