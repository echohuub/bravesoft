//
//  RootViewController.h
//  bravesoft
//
//  Created by And.He on 13-1-27.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"
#import "FGalleryViewController.h"

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, IconDownloaderDelegate, UIScrollViewDelegate, FGalleryViewControllerDelegate, FGalleryPhotoDelegate, UIAlertViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_arrays;
    
    NSURLConnection *_conn;
    NSMutableData *_data;
    NSOperationQueue *_queue;
    NSMutableDictionary *_imageDownloadsInProgress;
    
    FGalleryViewController *_detailViewController;
    UIScrollView *_thumbsView;
    BOOL _isThumbViewShowing;
    NSMutableArray *_photoThumbnailViews;
    NSMutableDictionary *_photoLoaders;
    NSMutableArray *_photoViews;
    
    UIView *_noConnectionView;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *arrays;
@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) FGalleryViewController *detailViewController;
@property (nonatomic, retain) UIScrollView *thumbsView;
@property (nonatomic, assign) BOOL isThumbViewShowing;

@end
