//
//  FanBeat.m
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import "FanBeat.h"

static const NSString *FANBEAT_PLIST_KEY = @"fanbeat_id";
static const NSString *FANBEAT_BASE_URI = @"ingame://";
static const NSNumber *FANBEAT_STORE_ID = [NSNumber numberWithInteger:966632826];

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
    // create Branch link
    if ([self canOpenFanbeat]) {
        // open Branch link
        
        if (onResult) {
            onResult(YES, nil);
            return;
        }
    } else {
        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        
        storeViewController.delegate = self;
        
        NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: FANBEAT_STORE_ID};
        
        [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError * _Nullable error) {
            if (result) {
                UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
                [controller presentViewController: storeViewController
                                         animated:YES
                                       completion:nil];
            }
        }];
        
        // TODO: Handle onResult when store returns
    }
    
    if (onResult)
        onResult(NO, nil);
}

-(BOOL)canOpenFanbeat
{
    NSURL *fanbeatUrl = [NSURL URLWithString:FANBEAT_BASE_URI];
    return [[UIApplication sharedApplication]canOpenURL:fanbeatUrl];
    
}

@end
