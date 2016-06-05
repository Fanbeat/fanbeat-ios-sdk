//
//  FanBeat.m
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import "FanBeat.h"
#import "BranchUniversalObject.h"

static const NSString *FANBEAT_PLIST_KEY = @"fanbeat_id";
static const NSString *FANBEAT_BASE_URI = @"ingame://";
static const int FANBEAT_STORE_ID = 966632826;

typedef void (^callbackWithUrl) (NSString *url, NSError *error);

@interface FanBeat() {
    NSString *identity;
    NSString *partnerId;
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

-(void)setup
{
    NSDictionary *plist = [NSBundle mainBundle].infoDictionary;
    
    if (!plist) {
        NSLog(@"Main bundle plist not found!");
        return;
    }
    
    partnerId = plist[FANBEAT_PLIST_KEY];
    if (!partnerId) {
        NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
    }
}

-(void)setIdentity:(NSString *)userId
{
    identity = userId;
}

-(void)openWithResult:(void(^)(BOOL, NSError * _Nullable))onResult
{
    [self getBranchUrlWithCallback:^(NSString *url, NSError *error) {
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
            // TODO: show marketing view controller
        }
    }];
}

-(BOOL)canOpenFanbeat
{
    NSURL *fanbeatUrl = [NSURL URLWithString:FANBEAT_BASE_URI];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
}

-(void)getBranchUrlWithCallback:(callbackWithUrl)callback
{
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithTitle:@"FanBeat"];
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc]init];
    linkProperties.stage = @"production";
    linkProperties.feature = @"SDK";
    linkProperties.channel = partnerId;
    [linkProperties addControlParam:@"partner_id" withValue:partnerId];
    
    if (identity) {
        [linkProperties addControlParam:@"partner_user_id" withValue:identity];
    }
    
    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:callback];
}

-(void)openUrl:(NSURL *)url
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
}

-(void)openStore:(NSNumber *)storeId withCallback:(void(^)(BOOL, NSError * _Nullable))callback
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: [NSNumber numberWithInteger:FANBEAT_STORE_ID]};
    
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            if (callback) {
                callback(result, error);
            }
            return;
        }
        
        if (result) {
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController: storeViewController
                                     animated:YES
                                   completion:nil];
        } else {
            if (callback) {
                callback(result, error);
            }
        }
    }];
}

@end
