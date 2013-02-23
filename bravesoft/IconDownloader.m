//
//  IconDownloader.m
//  bravesoft
//
//  Created by And.He on 13-1-28.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import "IconDownloader.h"
#import "Photo.h"

#define kImageSize 48

@implementation IconDownloader
@synthesize delegate=_delegate;
@synthesize conn=_conn;
@synthesize activeDownload=_activeDownload;
@synthesize photo=_photo;
@synthesize indexPath=_indexPath;


- (void)startDownload
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.photo.photoUrl]];
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancelDownload
{
    [self.conn cancel];
    self.activeDownload = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dealloc
{
    self.conn = nil;
    self.activeDownload = nil;
    self.photo = nil;
    self.indexPath = nil;
    [super dealloc];
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.activeDownload = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIImage *image = [UIImage imageWithData:self.activeDownload];
    if (image.size.height > kImageSize || image.size.width > kImageSize) {
        UIGraphicsBeginImageContext(CGSizeMake(kImageSize, kImageSize));
        [image drawInRect:CGRectMake(0, 0, kImageSize, kImageSize)];
        self.photo.photoIcon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        self.photo.photoIcon = image;
    }
    
    [self.delegate appImageDidLoad:self.indexPath];
    
    self.conn = nil;
    self.activeDownload = nil;
}

@end
