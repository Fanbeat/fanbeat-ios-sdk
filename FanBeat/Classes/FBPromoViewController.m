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
#import <CoreText/CoreText.h>

@interface FBPromoViewController () {
    NSBundle *sdkBundle;
    FBPartnerConfig *partnerConfig;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *competeLabel;
@property (weak, nonatomic) IBOutlet UILabel *funToPlayLabel;
@property (weak, nonatomic) IBOutlet UIButton *getTheGameButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorWrapper;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpacerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpacerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTopConstraint;


@end

@implementation FBPromoViewController

static NSString *const kPromoDefaultBackgroundName = @"golf_channel_background";
static NSString *const kPromoLandscapeNameFormat = @"%@_landscape";
static CGFloat const kMaxPrizeImageHeight = 200;
BOOL _showCancelButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    sdkBundle = [NSBundle bundleForClass:FBPromoViewController.self];
    
    [self setPartnerConfig:[FBDeepLinker getInstance].config];
    
    [_competeLabel setFont:[self openGCFrankBoldOfSize:17.0]];
    [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:22.0]];
    [_getTheGameButton.titleLabel setFont:[self openGCFrankBoldOfSize:19.0]];
    
    [self setIsWorking:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self adjustViewLayout:size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self adjustViewLayout:[UIScreen mainScreen].bounds.size];
    [self setShowCancelButton:_showCancelButton];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)adjustViewLayout:(CGSize) size {
    
    CGFloat height = size.height;
    CGFloat width = size.width;
    CGFloat ratio = width / height;
    
    BOOL hasNavBar = self.navigationController ? YES : NO;
    
    if (ratio < .6) { // iPhone 5/6/6+/SE portrait
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier: hasNavBar ? 0.1 : 0.13];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.00001];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:22.0]];
        _competeLabel.numberOfLines = 3;
        _buttonBottomConstraint.constant = 10;
        _buttonTopConstraint.constant = 8;
    }
    else if (ratio < .7) { // iPhone 4/4S portrait
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier: hasNavBar ? 0.075 : 0.05];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.00001];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:22.0]];
        _competeLabel.numberOfLines = 3;
        _buttonBottomConstraint.constant = 20;
        _buttonTopConstraint.constant = 8;
    }
    else if (ratio < 1) { // iPad portrait
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier:hasNavBar ? 0.15 : 0.2];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.1];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:22.0]];
        _competeLabel.numberOfLines = 3;
        _buttonBottomConstraint.constant = 0;
        _buttonTopConstraint.constant = 20;
    }
    else if (ratio < 1.4) { // iPad landscape
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier:0.05];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.2];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:22.0]];
        _competeLabel.numberOfLines = 3;
        _buttonBottomConstraint.constant = 0;
        _buttonTopConstraint.constant = 10;
    }
    else if (ratio < 1.7) { // iPhone 4/4S landscape
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier: hasNavBar ? 0.075 : 0.05];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.05];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:15.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        _competeLabel.numberOfLines = 2;
        _buttonBottomConstraint.constant = 0;
        _buttonTopConstraint.constant = 8;
    }
    else { // iPhone 5/6/6+/SE landscape
        _topSpacerHeightConstraint = [self changeConstraint:_topSpacerHeightConstraint multiplier:0.075];
        _leftSpacerWidthConstraint = [self changeConstraint:_leftSpacerWidthConstraint multiplier:0.1];
        [_competeLabel setFont:[self openGCFrankBoldOfSize:15.0]];
        [_funToPlayLabel setFont:[self openGCFrankBoldOfSize:17.0]];
        _competeLabel.numberOfLines = 2;
        _buttonBottomConstraint.constant = 0;
        _buttonTopConstraint.constant = 4;
    }
    
    [self loadImages];
}

- (void)viewWillLayoutSubviews
{
    [self loadImages];
}

- (void)orientationChanged:(NSNotification*)notification
{
    [self loadImages];
}

- (void)setShowCancelButton:(BOOL)showCancelButton
{
    if (_closeButton) {
        _closeButton.hidden = !showCancelButton;
    }
    
    _showCancelButton = showCancelButton;
}

- (void)setPartnerConfig:(FBPartnerConfig *)config
{
    partnerConfig = config;
    
    if (!partnerConfig) {
        partnerConfig = [FBPartnerConfig getDefault];
    }
    
    [self loadImages];
}

- (void)loadImages
{
    [_backgroundImage setImage:[self getBackgroundImage]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)getBackgroundImage
{
    UIImage *image;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *format = UIDeviceOrientationIsLandscape(orientation) ? kPromoLandscapeNameFormat : @"%@";
    
    image = [self getImageNamed:[NSString stringWithFormat:format, kPromoDefaultBackgroundName]];
    if (!image)
        image = [self getImageNamed:kPromoDefaultBackgroundName];
    
    return image;
}

- (UIImage *)getImageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:sdkBundle compatibleWithTraitCollection:nil];
}

- (IBAction)playNowTapped:(id)sender {
    if ([[FBDeepLinker getInstance] canOpenFanbeat]) {
        [self onDone:NO];
    } else {
        [self openStore: [NSNumber numberWithInteger:FANBEAT_STORE_ID]];
    }
}

- (IBAction)cancelClicked:(id)sender {
    [self onDone:YES];
}

-(void)openStore:(NSNumber *)storeId
{
    [self setIsWorking:YES];
    [[FBDeepLinker getInstance]openStore:self];
}

-(void)storeDidFinish
{
    [self setIsWorking:NO];
}

-(void)onDone:(BOOL)animated
{
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self finalizeDelegate];
}

- (void)finalizeDelegate
{
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

- (UIFont *)openGCFrankBoldOfSize:(CGFloat)size
{
    NSString *fontName = @"GCFrankBold";
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        [self dynamicallyLoadFontNamed:fontName];
        font = [UIFont fontWithName:fontName size:size];
        
        // safe fallback
        if (!font) font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}

- (void)dynamicallyLoadFontNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:FBPromoViewController.self];
    NSURL *url = [bundle URLForResource:name withExtension:@"ttf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            NSLog(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

- (void)setIsWorking:(BOOL)isWorking
{
    if (isWorking) {
        _activityIndicatorWrapper.hidden = NO;
        [_activityIndicatorView startAnimating];
    } else {
        _activityIndicatorWrapper.hidden = YES;
        [_activityIndicatorView stopAnimating];
    }
}

@end