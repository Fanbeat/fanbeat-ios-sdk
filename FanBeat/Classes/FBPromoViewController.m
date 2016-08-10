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

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *promoTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *promoTextTopConstraint;
@property (nonatomic) CGFloat prizeHeight;
@property (nonatomic) BOOL is4sRatio;
@property (nonatomic) NSInteger prizeIndex;

@end

@implementation FBPromoViewController

static NSString *const kPromoDefaultBackgroundName = @"promo_background";
static NSString *const kPromoLandscapeNameFormat = @"%@_landscape";
static CGFloat const kMaxPrizeImageHeight = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [UIScreen mainScreen].nativeBounds;
    //self.is4sRatio = (screenRect.size.width / screenRect.size.height) > 0.65;
    self.is4sRatio = screenRect.size.width <= 640;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FanBeatPod" ofType:@"bundle"];
    sdkBundle = [NSBundle bundleWithPath:bundlePath];
    
    [self setPartnerConfig:[FBDeepLinker getInstance].config];
    [self updateConstraints];
    
    _scrollView.delegate = self;
}

- (void)viewWillLayoutSubviews
{
    CGFloat height = _scrollView.bounds.size.height;
    
    if (height != _prizeHeight) {
        [self loadImages];
    }
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
    
    [self updateConstraints];
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
        _prizeHeight = height;
    }
}

- (void)updateConstraints
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (_is4sRatio) {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            _promoTextTopConstraint.constant = 10;
            _logoTopConstraint.constant = 20;
            _promoTextLabel.numberOfLines = 2;
        } else {
            _promoTextTopConstraint.constant = 20;
            _logoTopConstraint.constant = 40;
            _promoTextLabel.numberOfLines = 3;
        }
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