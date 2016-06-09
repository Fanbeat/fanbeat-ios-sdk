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

@interface FBDeepLinker() {
    BOOL isLive;
}
@end

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
    [self getBranchUrl:partnerId forUser:userId WithCallback:^(NSString *url, NSError *error) {
        if (error) {
            [self finalizeDelegate:NO];
            return;
        }
        
        [self openUrl: url];
    }];
}

-(BOOL)canOpenFanbeat
{
    NSURL *fanbeatUrl = [NSURL URLWithString: FANBEAT_APP_URI_SCHEME];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
}

-(void)getBranchUrl:(NSString *)partnerId forUser:(NSString * _Nullable)userId WithCallback:(callbackWithUrl)callback
{
    Branch *branch = [Branch getInstance: isLive ? FANBEAT_BRANCH_LIVE_KEY : FANBEAT_BRANCH_TEST_KEY];
    
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:partnerId];
    branchUniversalObject.title = @"FanBeat";
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.channel = partnerId;
    linkProperties.feature = @"SDK";
    [linkProperties addControlParam:@"partner_id" withValue:partnerId];
    
    if (userId) {
        [linkProperties addControlParam:@"partner_user_id" withValue:userId];
    }
    
    if (self.config) {
        NSString *deepLinkPath = [self.config getDeepLinkPath];
        if (deepLinkPath != nil && [deepLinkPath length] > 0) {
            [linkProperties addControlParam:@"$deeplink_path" withValue:deepLinkPath];
        }
    }
    
    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:callback];
}

-(void)openUrl:(NSURL *)url
{
    [self finalizeDelegate:YES];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
}

-(void)finalizeDelegate:(BOOL)success
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deepLinkerDidFinish:)]) {
        [self.delegate deepLinkerDidFinish:success];
    }
}

@end
