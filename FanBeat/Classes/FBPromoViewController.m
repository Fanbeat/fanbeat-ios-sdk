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

@end

@implementation FBPromoViewController

static NSString *const kPromoDefaultBackgroundName = @"promo-background";
static NSString *const kPromoBackgroundFormat = @"%@-promo-background";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FanBeatPod" ofType:@"bundle"];
    sdkBundle = [NSBundle bundleWithPath:bundlePath];
    
    partnerConfig = [FBDeepLinker getInstance].config;
    
    [self loadImages];
    
    _scrollView.delegate = self;
    
    _promoTextLabel.text = partnerConfig ? partnerConfig.promoText : @"";
    
    [self stylizeLogo];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    CGFloat currentIndex = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    
    [_pageControl setCurrentPage:currentIndex];
}

- (IBAction)onPageControlValueChanged:(id)sender {
    CGFloat width = _scrollView.frame.size.width;
    [_scrollView setContentOffset:CGPointMake(width * _pageControl.currentPage, 0) animated:YES];
}

- (void)loadImages
{
    [_backgroundImage setImage:[self getBackgroundImage]];
    
    NSMutableArray *prizeImages = [[NSMutableArray alloc] init];
    _pageControl.numberOfPages = 0;
    
    if (partnerConfig.promoPrizes) {
        
        CGFloat width = _scrollView.bounds.size.width - 48.0f;
        CGFloat height = _scrollView.bounds.size.height - 48.0f;
        CGFloat x = 0;
        
        for(FBPromoPrize *prize in partnerConfig.promoPrizes) {
            UIImage *prizeImage = [self getImageNamed:prize.icon];
            if (prizeImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
                imageView.image = prizeImage;
                imageView.contentMode = UIViewContentModeBottom;
                [_scrollView addSubview:imageView];
                
                x = x + width;
                _pageControl.numberOfPages += 1;
            }
        }
        
        _scrollView.contentSize = CGSizeMake(x, height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)getBackgroundImage
{
    UIImage *image;
    
    // if the partner app defines a promo background, check for that image first
    if (partnerConfig.promoBackground) {
        image = [self getImageNamed:partnerConfig.promoBackground];
    }
    
    // fallback to default image
    if (!image) {
        image = [self getImageNamed:kPromoDefaultBackgroundName];
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

- (void)stylizeLogo
{
    _logoImage.image = [self getImageNamed:@"logo-fanbeat"];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self onDone:NO];
}

-(void)onDone:(BOOL)animated
{
    [self dismissViewControllerAnimated:animated completion:nil];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(promoViewControllerDidFinish:)]) {
        [self.delegate promoViewControllerDidFinish:self];
    }
}

@end