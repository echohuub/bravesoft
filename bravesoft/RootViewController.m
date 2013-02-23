//
//  RootViewController.m
//  bravesoft
//
//  Created by And.He on 13-1-27.
//  Copyright (c) 2013年 And.He. All rights reserved.
//

#import "RootViewController.h"
#import "ParseOperation.h"
#import "Photo.h"
#import "IconDownloader.h"
#import "FGalleryPhoto.h"
#import "FGalleryPhotoView.h"
#import "MAlertView.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#define kCustomRowHeight 60

static NSString *urlPath = @"http://cd.dev.vc/ios/photo.xml";

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize tableView=_tableView;
@synthesize arrays=_arrays;
@synthesize conn=_conn;
@synthesize data=_data;
@synthesize queue=_queue;
@synthesize imageDownloadsInProgress=_imageDownloadsInProgress;
@synthesize detailViewController=_detailViewController;
@synthesize thumbsView=_thumbsView;
@synthesize isThumbViewShowing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Bravesoft";
    }
    return self;
}

- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    baseView.backgroundColor = [UIColor orangeColor];
    self.view = baseView;
    [baseView release];
    
    // add tableview
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // add thumb view
    _thumbsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    _thumbsView.backgroundColor = [UIColor whiteColor];
    _thumbsView.hidden = YES;
    _thumbsView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    [self.view addSubview:_thumbsView];
    
    // thumb data
    _photoThumbnailViews = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.arrays = [NSMutableArray array];
    
    [self appStart];
}

- (void)dealloc
{
    self.tableView = nil;
    self.arrays = nil;
    self.conn = nil;
    self.data = nil;
    self.queue = nil;
    self.imageDownloadsInProgress = nil;
    self.detailViewController = nil;
    self.thumbsView = nil;
    [_noConnectionView release];
    [super dealloc];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int size = _arrays.count;
    if (size == 0) {
        return 1;
    }
    return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *LoadingCellIdentifier = @"LoadingCell";
    int count = self.arrays.count;
    if (count == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadingCellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        cell.textLabel.text = @"Loading...";
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Photo *photo = [self.arrays objectAtIndex:indexPath.row];
    cell.textLabel.text = photo.photoTitle;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", photo.photoId];
    
    if (photo.photoIcon) {
        cell.imageView.image = photo.photoIcon;
    } else {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self startDownloadIcon:indexPath];
        }
        cell.imageView.image = [UIImage imageNamed:@"Placeholder"];
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCustomRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrays.count == 0) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toTheDetailController:indexPath.row];
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *cred = [[[NSURLCredential alloc] initWithUser:@"bravesoft" password:@"bravesoft" persistence: NSURLCredentialPersistenceForSession] autorelease];
        [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Invalid Credentials" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    MBProgressHUD *HUD = (MBProgressHUD *)[self.navigationController.view viewWithTag:111];
    [HUD hide:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorTimedOut) {
        MBProgressHUD *timeOutHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        timeOutHUD.mode = MBProgressHUDModeText;
        timeOutHUD.labelText = @"The request time out";
        [timeOutHUD hide:YES afterDelay:3];
        timeOutHUD.margin = 10.f;
        timeOutHUD.yOffset = 150.f;
        timeOutHUD.removeFromSuperViewOnHide = YES;
    } else if ([error code] == kCFURLErrorNotConnectedToInternet) {
        MBProgressHUD *timeOutHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        timeOutHUD.mode = MBProgressHUDModeText;
        timeOutHUD.labelText = @"No Connection Error";
        [timeOutHUD hide:YES afterDelay:3];
        timeOutHUD.margin = 10.f;
        timeOutHUD.yOffset = 150.f;
        timeOutHUD.removeFromSuperViewOnHide = YES;
    }
    
    self.conn = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    ParseOperation *operaton = [[ParseOperation alloc] initWithData:self.data completionHandler:^(NSMutableArray *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.arrays addObjectsFromArray:array];
            [self.tableView reloadData];
            // thumb
            [self buildThumbsViewPhotos];
            // remove HUD
            MBProgressHUD *HUD = (MBProgressHUD *)[self.navigationController.view viewWithTag:111];
            [HUD hide:YES];
            
            UIBarButtonItem *btnThumb = [[[UIBarButtonItem alloc] initWithTitle:@"缩略图" style:UIBarButtonItemStyleBordered target:self action:@selector(handleThumbTouch:)] autorelease];
            self.navigationItem.rightBarButtonItem = btnThumb;
        });
    }];
    [self.queue addOperation:operaton];
    [operaton release];
    
    self.data = nil;
    self.conn = nil;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // cancel
        _noConnectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
        _noConnectionView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 40)];
        label.center = self.view.center;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"当前网络不可用";
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_noConnectionView addSubview:label];
        [_noConnectionView setHidden:YES];
        [label release];
        [self.view addSubview:_noConnectionView];
        
        
        [UIView beginAnimations:@"noconnection" context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationDelay:2];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_noConnectionView cache:YES];
        [_noConnectionView setHidden:NO];
        [UIView commitAnimations];
        
    } else {
        // restart
        [self appStart];
    }
}

#pragma mark - Custom methods

- (void)appStart
{
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable && [Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前网络不可用" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"重试", nil];
        [alertView show];
        [alertView release];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
        self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.labelText = @"Loading";
        HUD.tag = 111;
        HUD.removeFromSuperViewOnHide = YES;
    }
}

// 开始下载Icon
- (void)startDownloadIcon:(NSIndexPath *)indexPath
{
    IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (!downloader) {
        downloader = [[IconDownloader alloc] init];
        downloader.delegate = self;
        downloader.photo = [self.arrays objectAtIndex:indexPath.row];
        downloader.indexPath = indexPath;
        [self.imageDownloadsInProgress setObject:downloader forKey:indexPath];
        [downloader startDownload];
        [downloader release];
    }
}

// 载入一屏
- (void)loadImagesForOnscreenRows
{
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleRows) {
        Photo *p = [self.arrays objectAtIndex:indexPath.row];
        if (!p.photoIcon) {
            [self startDownloadIcon:indexPath];
        }
    }
}

- (void)toTheDetailController:(NSInteger)index
{
    UIImage *trashIcon = [UIImage imageNamed:@"photo-gallery-trashcan"];
    UIImage *captionIcon = [UIImage imageNamed:@"photo-gallery-edit-caption"];
    UIBarButtonItem *trashItem = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    UIBarButtonItem *captionItem = [[UIBarButtonItem alloc] initWithImage:captionIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleEditCaptionButtonTouch:)];
    NSArray *barItems = [NSArray arrayWithObjects:trashItem, captionItem, nil];
    [trashItem release];
    [captionItem release];
    
    _detailViewController = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItems];
    _detailViewController.startingIndex = index;
    [self.navigationController pushViewController:_detailViewController animated:YES];
    [_detailViewController release];
}

#pragma mark - Custom methods for thumb view

- (void)handleThumbTouch:(id)sender
{
    // show thumb view
	[self toggleThumbnailViewWithAnimation:YES];
    
    // tell thumbs that havent loaded to load
	[self loadAllThumbViewPhotos];
}

- (void)loadAllThumbViewPhotos
{
	NSUInteger i, count = self.arrays.count;
	for (i=0; i < count; i++) {
		
		[self loadThumbnailImageWithIndex:i];
	}
}

- (void)loadThumbnailImageWithIndex:(NSUInteger)index
{
	FGalleryPhoto *photo = [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	
	[photo loadThumbnail];
}

- (FGalleryPhoto*)createGalleryPhotoForIndex:(NSUInteger)index
{
	FGalleryPhoto *photo;
	NSString *thumbPath;
	
	thumbPath = [[self.arrays objectAtIndex:index] photoUrl];
    photo = [[[FGalleryPhoto alloc] initWithThumbnailUrl:thumbPath fullsizeUrl:nil delegate:self] autorelease];
    
	// assign the photo index
	photo.tag = index;
	
	// store it
	[_photoLoaders setObject:photo forKey: [NSString stringWithFormat:@"%i", index]];
	
	return photo;
}

- (void)toggleThumbnailViewWithAnimation:(BOOL)animation
{
    if (_isThumbViewShowing) {
        [self hideThumbnailViewWithAnimation:animation];
    } else {
        [self showThumbnailViewWithAnimation:animation];
    }
}

// 隐藏缩略图
- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"缩略图", @"")];
    
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_thumbsView cache:YES];
        [_thumbsView setHidden:YES];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}

// 显示缩略图
- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    _isThumbViewShowing = YES;
    
    [self arrangeThumbs];
    [self.navigationItem.rightBarButtonItem setTitle:@"列表"];
    
    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_thumbsView cache:YES];
        [_thumbsView setHidden:NO];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}

- (void)arrangeThumbs
{
	float dx = 0.0;
	float dy = 0.0;
	// loop through all thumbs to size and place them
	NSUInteger i, count = [_photoThumbnailViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:i];
		[thumbView setBackgroundColor:[UIColor grayColor]];
		
		// create new frame
		thumbView.frame = CGRectMake( dx, dy, 75, 75);
		
		// increment position
		dx += 75 + 4;
		
		// check if we need to move to a different row
		if( dx + 75 + 4 > _thumbsView.frame.size.width - 4 )
		{
			dx = 0.0;
			dy += 75 + 4;
		}
	}
	
	// set the content size of the thumb scroller
	[_thumbsView setContentSize:CGSizeMake( _thumbsView.frame.size.width - ( 4*2 ), dy + 75 + 4 )];
}

- (void)buildThumbsViewPhotos
{
	NSUInteger i, count = self.arrays.count;
	for (i = 0; i < count; i++) {
		
		FGalleryPhotoView *thumbView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(handleThumbClick:)];
		[thumbView setContentMode:UIViewContentModeScaleAspectFill];
		[thumbView setClipsToBounds:YES];
		[thumbView setTag:i];
		[_thumbsView addSubview:thumbView];
		[_photoThumbnailViews addObject:thumbView];
		[thumbView release];
	}
}

- (void)handleThumbClick:(id)sender
{
	FGalleryPhotoView *photoView = (FGalleryPhotoView*)[(UIButton*)sender superview];
    _detailViewController = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [self toTheDetailController:photoView.tag];
}

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}


- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

#pragma mark - IconDownloaderDelegate methods

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (downloader) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.imageView.image = downloader.photo.photoIcon;
        [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate methods
// 已经结束拖拽，手指刚离开view的那一刻
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self loadImagesForOnscreenRows];
}

// view已经减速完成，停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - FGalleryViewControllerDelegate methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return self.arrays.count;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}

- (NSString *)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    Photo *p = [self.arrays objectAtIndex:index];
    return p.photoUrl;
}

#pragma mark - FGalleryPhotoDelegate methods

- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadThumbnail:(UIImage*)image
{
    // grab the associated image view
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	
	// if the gallery photo hasn't loaded the fullsize yet, set the thumbnail as its image.
	if( !photo.hasFullsizeLoaded )
		photoView.imageView.image = photo.thumbnail;
    
	[photoView.activity stopAnimating];
	
	// grab the thumbail view and set its image
	FGalleryPhotoView *thumbView = [_photoThumbnailViews objectAtIndex:photo.tag];
	thumbView.imageView.image = image;
	[thumbView.activity stopAnimating];
}

- (void)galleryPhoto:(FGalleryPhoto *)photo didLoadFullsize:(UIImage *)image
{
    
}

- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromUrl:(NSString*)url
{
	// show activity indicator for large photo view
	FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
	[photoView.activity startAnimating];
	
	// show activity indicator for thumbail
	if( _isThumbViewShowing ) {
		FGalleryPhotoView *thumb = [_photoThumbnailViews objectAtIndex:photo.tag];
		[thumb.activity startAnimating];
	}
}

@end
