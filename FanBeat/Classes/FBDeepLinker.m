//
//  FBDeepLinker.m
//  Pods
//
//  Created by Tony Sullivan on 6/7/16.
//
//

#import "FBDeepLinker.h"
#import "FBConstants.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"

@implementation FBDeepLinker

+(instancetype)getInstance
{
    static FBDeepLinker *deepLinker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deepLinker = [[FBDeepLinker alloc]init];
    });
    return deepLinker;  
}

-(void)open:(NSString *)partnerId
{
    [self open:partnerId forUser:nil];
}

-(void)open:(NSString *) partnerId forUser:(NSString *)userId
{
    /*
     * TODO: Disabling branch for now to avoid iOS 10 universal link issue
    [self getBranchUrl:partnerId forUser:userId WithCallback:^(NSString *url, NSError *error) {
        if (error) {
            [self finalizeDelegate:NO];
            return;
        }
        
        [self openUrl: url];
    }];
     */
    
    NSString *deepLinkPath = [self.config getDeepLinkPath];
    [self openUrl:[NSString stringWithFormat:@"%@%@", FANBEAT_APP_URI_SCHEME, deepLinkPath]];
}

-(BOOL)canOpenFanbeat
{
    // check to see if any installed apps can handle FanBeat's URI scheme
    NSURL *fanbeatUrl = [NSURL URLWithString: FANBEAT_APP_URI_SCHEME];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
}

- (void)openStore:(UIViewController *)viewController
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: @FANBEAT_STORE_ID};
    
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            return;
        }
        
        if (result) {
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [viewController presentViewController: storeViewController
                               animated:YES
                             completion:nil];
        }
    }];
}

-(void)getBranchUrl:(NSString *)partnerId forUser:(NSString * _Nullable)userId WithCallback:(callbackWithUrl)callback
{
    // get a Branch instance with FanBeat's key
    Branch *branch = [Branch getInstance: _isLive ? FANBEAT_BRANCH_LIVE_KEY : FANBEAT_BRANCH_TEST_KEY];
    
    // build a link and always include the partner ID
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:partnerId];
    branchUniversalObject.title = @"FanBeat";
    branchUniversalObject.type = @"1"; // one-time use for the context
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.channel = partnerId;
    linkProperties.feature = @"SDK";
    [linkProperties addControlParam:@"partner_id" withValue:partnerId];
    [linkProperties addControlParam:@"$ios_url" withValue:@"www.fanbeat.com"];
    
    // if the user ID was provided, include that in the link
    if (userId) {
        [linkProperties addControlParam:@"partner_user_id" withValue:userId];
    }
    
    // if we found partner config, parse it and get the deep link path
    if (self.config) {
        NSString *deepLinkPath = [self.config getDeepLinkPath];
        if (deepLinkPath != nil && [deepLinkPath length] > 0) {
            [linkProperties addControlParam:@"$deeplink_path" withValue:deepLinkPath];
        }
    }
    
    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:callback];
}

-(void)openUrl:(NSString *)url
{
    // alert the delegate of success before launching the URL
    [self finalizeDelegate:YES];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(storeDidFinish)]) {
        [self.delegate storeDidFinish];
    }
}

-(void)finalizeDelegate:(BOOL)success
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deepLinkerDidFinish:)]) {
        [self.delegate deepLinkerDidFinish:success];
    }
}

@end