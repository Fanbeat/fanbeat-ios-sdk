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

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *logoTopSpacerConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *logoBottomSpacerConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *promoTextWidthConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *prizeScrollerHeightConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *pagerTopSpacerConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *pagerBottomSpacerConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomSpacerConstraint;

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
    CGFloat ratio = width / height;
    
    if (ratio < .6) { // iPhone 5/6/6+/SE portrait
        _promoTextLabel.numberOfLines = 4;
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.01];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.01];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.1];
    }
    else if (ratio < .7) { // iPhone 4/4S portrait
        _promoTextLabel.numberOfLines = 4;
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.03];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.01];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.05];
    }
    else if (ratio < 1) { // iPad portrait
        _promoTextLabel.numberOfLines = 3;
        _logoTopSpacerConstraint = [self changeConstraint:_logoTopSpacerConstraint multiplier:0.2];
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.05];
        _promoTextWidthConstraint = [self changeConstraint:_promoTextWidthConstraint multiplier:0.6];
        _pagerTopSpacerConstraint = [self changeConstraint:_pagerTopSpacerConstraint multiplier:0.02];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.05];
        _buttonWidthConstraint = [self changeConstraint:_buttonWidthConstraint multiplier:0.4];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.15];
    }
    else if (ratio < 1.4) { // iPad landscape
        _promoTextLabel.numberOfLines = 2;
        _logoTopSpacerConstraint = [self changeConstraint:_logoTopSpacerConstraint multiplier:0.15];
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.05];
        _promoTextWidthConstraint = [self changeConstraint:_promoTextWidthConstraint multiplier:0.6];
        _pagerTopSpacerConstraint = [self changeConstraint:_pagerTopSpacerConstraint multiplier:0.01];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.05];
        _buttonWidthConstraint = [self changeConstraint:_buttonWidthConstraint multiplier:0.4];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.1];
    }
    else if (ratio < 1.7) { // iPhone 4/4S landscape
        _promoTextLabel.numberOfLines = 2;
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.001];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.001];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.05];
    }
    else { // iPhone 5/6/6+/SE portrait
        _promoTextLabel.numberOfLines = 2;
        _logoBottomSpacerConstraint = [self changeConstraint:_logoBottomSpacerConstraint multiplier:0.001];
        _pagerBottomSpacerConstraint = [self changeConstraint:_pagerBottomSpacerConstraint multiplier:0.001];
        _buttonBottomSpacerConstraint = [self changeConstraint:_buttonBottomSpacerConstraint multiplier:0.05];
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

- (NSLayoutConstraint*)changeConstraint:(NSLayoutConstraint*)constraint multiplier:(CGFloat)multiplier
{
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:multiplier constant:constraint.constant];
    
    newConstraint.priority = constraint.priority;
    
    [self.view removeConstraint:constraint];
    [self.view addConstraint:newConstraint];
    
    return newConstraint;
}

@end