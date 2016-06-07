//
//  FanBeat.m
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import "FanBeat.h"
#import "FBDeepLinker.h"
#import "FBPromoViewController.h"

static const NSString *FANBEAT_PLIST_KEY = @"fanbeat_id";

typedef void (^callbackWithUrl) (NSString *url, NSError *error);

@interface FanBeat() {
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

-(id)init
{
    if (self == [super init]) {
        [FBDeepLinker getInstance].isLive = NO;
        
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
    [self openForUser:nil];
}

-(void)openForUser:(NSString *)userId
{
    if (!partnerId) {
        NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
        return;
    }
    
    FBDeepLinker *deepLinker = [FBDeepLinker getInstance];
    
    if ([deepLinker canOpenFanbeat]) {
        [deepLinker open:partnerId forUser:userId];
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:[FBPromoViewController class]];
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        FBPromoViewController *promoViewController = [[FBPromoViewController alloc] initWithNibName:@"FBPromoViewController" bundle:bundle];
        [controller presentViewController:promoViewController
                                 animated:YES
                               completion:nil];
    }
}

@end
