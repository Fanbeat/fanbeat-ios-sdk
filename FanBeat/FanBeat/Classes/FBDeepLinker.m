//
//  FBDeepLinker.m
//  Pods
//
//  Created by Tony Sullivan on 6/7/16.
//
//

#import "FBDeepLinker.h"
#import "Branch.h"

static const NSString *FANBEAT_BASE_URI = @"ingame://";
static const NSString *FANBEAT_LIVE_KEY = @"key_live_oam5GSs8U81sJ8TvPo8v6bbpDudyMBQN";
static const NSString *FANBEAT_TEST_KEY = @"key_test_mbo9SGq4LZXBQ9HvTj89lgcgzvnwJDN0";

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
            return;
        }
        
        [self openUrl: url];
    }];
}

-(BOOL)canOpenFanbeat
{
    NSURL *fanbeatUrl = [NSURL URLWithString:FANBEAT_BASE_URI];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
}

-(void)getBranchUrl:(NSString *)partnerId forUser:(NSString * _Nullable)userId WithCallback:(callbackWithUrl)callback
{
    Branch *branch = [Branch getInstance: isLive ? FANBEAT_LIVE_KEY : FANBEAT_TEST_KEY];
    
    NSDictionary *params = @{
                             @"partner_id" : partnerId
                             };
    
    if (userId) {
        [params setValue:userId forKey:@"partner_user_id"];
    }
    
    [branch getShortURLWithParams:params andChannel:partnerId andFeature:@"SDK" andCallback:callback];
}

-(void)openUrl:(NSURL *)url
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
}

@end
