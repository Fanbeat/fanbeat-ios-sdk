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

@interface FBPromoViewController () {
    NSBundle *sdkBundle;
    FBPartnerConfig *partnerConfig;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *promoTextLabel;

@end

@implementation FBPromoViewController

static NSString *const kPromoDefaultBackgroundName = @"promo-background";
static NSString *const kPromoBackgroundFormat = @"%@-promo-background";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSBundle *podBundle = [NSBundle bundleForClass:FBPromoViewController.self];
    NSURL *url = [podBundle URLForResource:@"FanBeatPod" withExtension:@"bundle"];
    sdkBundle = [NSBundle bundleWithURL:url];
    
    partnerConfig = [FBDeepLinker getInstance].config;
    
    [self loadImages];
    
    _scrollView.delegate = self;
    
    _promoTextLabel.text = partnerConfig ? partnerConfig.promoText : @"";
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
        
        CGFloat width = _scrollView.frame.size.width - 48.0f;
        CGFloat height = _scrollView.frame.size.height;
        CGFloat x = 0;
        
        for(NSString *prize in partnerConfig.promoPrizes) {
            UIImage *prizeImage = [self getImageNamed:prize];
            if (prizeImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
                imageView.image = [self getImageNamed:prize];
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

-(void)openStore:(NSNumber *)storeId
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: storeId};
    
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            return;
        }
        
        if (result) {
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [self presentViewController: storeViewController
                                     animated:YES
                                   completion:nil];
        }
    }];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(promoViewControllerDidFinish:)]) {
        [self.delegate promoViewControllerDidFinish:self];
    }
}

@end
