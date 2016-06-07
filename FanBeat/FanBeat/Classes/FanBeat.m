//
//  FanBeat.m
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import "FanBeat.h"
#import "Branch.h"
#import "FBPromoViewController.h"

static const NSString *FANBEAT_PLIST_KEY = @"fanbeat_id";
static const NSString *FANBEAT_BASE_URI = @"ingame://";
static const NSString *FANBEAT_LIVE_KEY = @"key_live_oam5GSs8U81sJ8TvPo8v6bbpDudyMBQN";
static const NSString *FANBEAT_TEST_KEY = @"key_test_mbo9SGq4LZXBQ9HvTj89lgcgzvnwJDN0";

typedef void (^callbackWithUrl) (NSString *url, NSError *error);

@interface FanBeat() {
    NSString *partnerId;
    BOOL isLive;
}
@end

@implementation FanBeat

+(instancetype)getInstance
{
    static FanBeat *fanbeat = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fanbeat = [[FanBeat alloc]init];
    });
    return fanbeat;
}

-(id)init
{
    if (self == [super init]) {
        isLive = NO;
        
        NSDictionary *plist = [NSBundle mainBundle].infoDictionary;
    
        if (!plist) {
            NSLog(@"Main bundle plist not found!");
        } else {
            partnerId = plist[FANBEAT_PLIST_KEY];
            if (!partnerId) {
                NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
            }
        }
    }
    
    return self;
}

-(void)open
{
    [self openWithResult:nil];
}

-(void)openWithResult:(void(^)(BOOL, NSError * _Nullable))onResult
{
    [self openForUser:nil withResult:onResult];
}

-(void)openForUser:(NSString *)userId withResult:(void(^)(BOOL, NSError * _Nullable))onResult
{
    if (!partnerId) {
        NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
        return;
    }
    
    [self getBranchUrlForUser:userId WithCallback:^(NSString *url, NSError *error) {
        if (error) {
            if (onResult) {
                onResult(NO, error);
            }
            return;
        }
        
        if ([self canOpenFanbeat]) {
            [self openUrl: url];
            if (onResult) {
                onResult(YES, nil);
                return;
            }
        } else {
            NSBundle *bundle = [NSBundle bundleForClass:[FBPromoViewController class]];
            FBPromoViewController *viewController = [[FBPromoViewController alloc] initWithNibName:@"FBPromoViewController" bundle:bundle];
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:viewController animated:YES completion:nil];
        }
    }];
}

-(BOOL)canOpenFanbeat
{
    NSURL *fanbeatUrl = [NSURL URLWithString:FANBEAT_BASE_URI];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
}

-(void)getBranchUrlForUser:(NSString * _Nullable)userId WithCallback:(callbackWithUrl)callback
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
