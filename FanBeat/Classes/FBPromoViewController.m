//
//  FBPromoViewController.m
//  Pods
//
//  Created by Tony Sullivan on 6/6/16.
//
//

#import "FBPromoViewController.h"
#import "FBDeepLinker.h"
#import "FBConstants.h"
#import "FBPartnerConfig.h"
#import "FBPromoPrize.h"

@interface FBPromoViewController () {
    NSBundle *sdkBundle;
    FBPartnerConfig *partnerConfig;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *promoTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) NSInteger prizeIndex;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *promoTextTopConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *prizeScrollerHeightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *playNowBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pagerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pagerBottomConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *playNowLeftConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *playNowRightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *promoTextLeftConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *promoTextRightConstraint;

@end

@implementation FBPromoViewController

static NSString *const kPromoDefaultBackgroundName = @"promo_background";
static NSString *const kPromoLandscapeNameFormat = @"%@_landscape";
static CGFloat const kMaxPrizeImageHeight = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FanBeatPod" ofType:@"bundle"];
    sdkBundle = [NSBundle bundleWithPath:bundlePath];
    
    [self setPartnerConfig:[FBDeepLinker getInstance].config];
    
    _scrollView.delegate = self;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self adjustViewLayout:size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self adjustViewLayout:[UIScreen mainScreen].bounds.size];
}

- (void)adjustViewLayout:(CGSize) size {
    CGFloat height = size.height;
    CGFloat width = size.width;
    
    if (height == 480 && width == 320) { // iPhone 4/4S portrait
        _logoTopConstraint.constant = 40;
        _promoTextTopConstraint.constant = 8;
        _promoTextLabel.numberOfLines = 4;
        _prizeScrollerHeightConstraint.constant = 120;
        _pagerTopConstraint.constant = 8;
        _pagerBottomConstraint.constant = 8;
    }
    else if (height == 320 && width == 480) { // iPhone 4/4S landscape
        _logoTopConstraint.constant = 30;
        _promoTextTopConstraint.constant = 0;
        _promoTextLabel.numberOfLines = 3;
        _prizeScrollerHeightConstraint.constant = 60;
        _pagerTopConstraint.constant = 0;
        _pagerBottomConstraint.constant = 0;
    }
    else if (height == 568 && width == 320) { // iPhone 5 portrait
        _logoTopConstraint.constant = 60;
        _promoTextTopConstraint.constant = 20;
        _promoTextLabel.numberOfLines = 4;
        _prizeScrollerHeightConstraint.constant = 150;
        _pagerTopConstraint.constant = 8;
        _pagerBottomConstraint.constant = 8;
    }
    else if (height == 320 && width == 568) { // iPhone 5 landscape
        _logoTopConstraint.constant = 30;
        _promoTextTopConstraint.constant = 0;
        _promoTextLabel.numberOfLines = 3;
        _prizeScrollerHeightConstraint.constant = 60;
        _pagerTopConstraint.constant = 0;
        _pagerBottomConstraint.constant = 0;
    }
    else if (height == 667 && width == 375) { // iPhone 6 portrait
        _logoTopConstraint.constant = 60;
        _promoTextTopConstraint.constant = 36;
        _prizeScrollerHeightConstraint.constant = 160;
        _pagerBottomConstraint.constant = 20;
        _playNowBottomConstraint.constant = 40;
    }
    else if (height == 375 && width == 667) { // iPhone 6 landscape
        _logoTopConstraint.constant = 40;
        _promoTextTopConstraint.constant = 20;
        _prizeScrollerHeightConstraint.constant = 80;
        _pagerBottomConstraint.constant = 8;
        _playNowBottomConstraint.constant = 20;
    }
    else if (height == 736 && width == 414) { // iPhone 6+ portrait
        _logoTopConstraint.constant = 80;
        _promoTextTopConstraint.constant = 40;
        _prizeScrollerHeightConstraint.constant = 200;
        _pagerBottomConstraint.constant = 20;
        _playNowBottomConstraint.constant = 40;
    }
    else if (height == 414 && width == 736) { // iPhone 6+ landscape
        _logoTopConstraint.constant = 40;
        _promoTextTopConstraint.constant = 20;
        _prizeScrollerHeightConstraint.constant = 100;
        _pagerBottomConstraint.constant = 8;
        _playNowBottomConstraint.constant = 20;
    }
    else if (height == 1024 && width == 768) { // iPad portrait
        _logoTopConstraint.constant = 120;
        _promoTextTopConstraint.constant = 120;
        _prizeScrollerHeightConstraint.constant = 160;
        _pagerBottomConstraint.constant = 80;
        _playNowBottomConstraint.constant = 60;
        _promoTextLeftConstraint.constant = 60;
        _promoTextRightConstraint.constant = 60;
        _playNowLeftConstraint.constant = 60;
        _playNowRightConstraint.constant = 60;
    }
    else if (height == 768 && width == 1024) { // iPad landscape
        _logoTopConstraint.constant = 120;
        _promoTextTopConstraint.constant = 60;
        _prizeScrollerHeightConstraint.constant = 140;
        _pagerBottomConstraint.constant = 60;
        _playNowBottomConstraint.constant = 40;
        _promoTextLeftConstraint.constant = 120;
        _promoTextRightConstraint.constant = 120;
        _playNowLeftConstraint.constant = 120;
        _playNowRightConstraint.constant = 120;
    }
    else if (height == 1366 && width == 1024) { // iPad pro portrait
        _logoTopConstraint.constant = 200;
        _promoTextTopConstraint.constant = 120;
        _prizeScrollerHeightConstraint.constant = 200;
        _pagerBottomConstraint.constant = 120;
        _playNowBottomConstraint.constant = 300;
        _promoTextLeftConstraint.constant = 100;
        _promoTextRightConstraint.constant = 100;
        _playNowLeftConstraint.constant = 100;
        _playNowRightConstraint.constant = 100;
    }
    else if (height == 1024 && width == 1366) { // iPad pro landscape
        _logoTopConstraint.constant = 120;
        _promoTextTopConstraint.constant = 80;
        _prizeScrollerHeightConstraint.constant = 200;
        _pagerBottomConstraint.constant = 80;
        _playNowBottomConstraint.constant = 140;
        _promoTextLeftConstraint.constant = 160;
        _promoTextRightConstraint.constant = 160;
        _playNowLeftConstraint.constant = 160;
        _playNowRightConstraint.constant = 160;
    }
    
    [self loadImages];
}

- (void)viewWillLayoutSubviews
{
    [self loadImages];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pageControl setCurrentPage:0];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)orientationChanged:(NSNotification*)notification
{
    UIDevice *device = notification.object;
    
    [self loadImages];
    [self scrollToPrizeImage:self.prizeIndex animated:NO];
}

- (void)setShowCancelButton:(BOOL)showCancelButton
{
    if (_closeButton) {
        _closeButton.hidden = !showCancelButton;
    }
}

- (void)setPartnerConfig:(FBPartnerConfig *)config
{
    partnerConfig = config;
    [self loadImages];
    
    _promoTextLabel.text = partnerConfig ? partnerConfig.promoText : @"";
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    CGFloat currentIndex = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    
    [_pageControl setCurrentPage:currentIndex];
    self.prizeIndex = currentIndex;
}

- (IBAction)onPageControlValueChanged:(id)sender {
    [self scrollToPrizeImage:_pageControl.currentPage animated:YES];
    self.prizeIndex = _pageControl.currentPage;
}

- (void) scrollToPrizeImage:(NSInteger)index animated:(BOOL)animated
{
    CGFloat width = _scrollView.frame.size.width;
    [_scrollView setContentOffset:CGPointMake(width * index, 0) animated:animated];
    [_pageControl setCurrentPage:index];
}

- (void)loadImages
{
    [_backgroundImage setImage:[self getBackgroundImage]];
    
    NSMutableArray *prizeImages = [[NSMutableArray alloc] init];
    _pageControl.numberOfPages = 0;
    
    if (partnerConfig.promoPrizes) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = _scrollView.bounds.size.height;
        CGFloat x = 0;
        CGFloat y = 0;
        
        if (height > kMaxPrizeImageHeight) {
            y = height - kMaxPrizeImageHeight;
            height = kMaxPrizeImageHeight;
        }
        
        [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        for(FBPromoPrize *prize in partnerConfig.promoPrizes) {
            UIImage *prizeImage = [self getImageNamed:prize.icon];
            if (prizeImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                imageView.image = prizeImage;
                imageView.contentMode = y > 0 ? UIViewContentModeBottom : UIViewContentModeScaleAspectFit;
                
                [_scrollView addSubview:imageView];
                
                x = x + width;
                _pageControl.numberOfPages += 1;
            }
        }
        
        [_scrollView setContentSize:CGSizeMake(x, height)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)getBackgroundImage
{
    UIImage *image;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *format = UIDeviceOrientationIsPortrait(orientation) ? @"%@" : kPromoLandscapeNameFormat;
    
    // if the partner app defines a promo background, check for that image first
    if (partnerConfig.promoBackground) {
        NSString *name = [NSString stringWithFormat:format, partnerConfig.promoBackground];
        image = [self getImageNamed:name];
    }
    
    // fallback to default image
    if (!image) {
        NSString *name = [NSString stringWithFormat:format, kPromoDefaultBackgroundName];
        image = [self getImageNamed:name];
    }
    
    return image;
}

- (UIImage *)getImageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:sdkBundle compatibleWithTraitCollection:nil];
}

- (IBAction)playNowTapped:(id)sender {
    [self openStore: [NSNumber numberWithInteger:FANBEAT_STORE_ID]];
}

- (IBAction)cancelClicked:(id)sender {
    [self onDone:YES];
}

-(void)openStore:(NSNumber *)storeId
{
    [[FBDeepLinker getInstance]openStore:self];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self onDone:NO];
}

-(void)onDone:(BOOL)animated
{
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(promoViewControllerDidFinish:)]) {
        [self.delegate promoViewControllerDidFinish:self];
    }
}

@end