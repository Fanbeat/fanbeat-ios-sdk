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
    NSString *_partnerId;
    NSString *_userId;
    FBPromoViewController *promoViewController;
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
        [FBDeepLinker getInstance].delegate = self;
        
        NSDictionary *plist = [NSBundle mainBundle].infoDictionary;
    
        if (!plist) {
            NSLog(@"Main bundle plist not found!");
        } else {
            _partnerId = plist[FANBEAT_PLIST_KEY];
            if (!_partnerId) {
                NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
            }
        }
    }
    
    return self;
}

-(void)initWithPartnerId:(NSString *)partnerId
{
    _partnerId = partnerId;
}

-(void)open
{
    [self openForUser:nil];
}

-(void)openForUser:(NSString *)userId
{
    if (!_partnerId) {
        NSLog(@"%@ not found in the plist!", FANBEAT_PLIST_KEY);
        [self finalizeDelegate:NO];
        return;
    }
    
    FBDeepLinker *deepLinker = [FBDeepLinker getInstance];
    
    if ([deepLinker canOpenFanbeat]) {
        [deepLinker open:_partnerId forUser:userId];
    } else {
        _userId = userId;
        
        NSBundle *bundle = [NSBundle bundleForClass:[FBPromoViewController class]];
        
        promoViewController = [[FBPromoViewController alloc] initWithNibName:@"FBPromoViewController" bundle:bundle];
        promoViewController.delegate = self;
        
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        [controller presentViewController:promoViewController
                                 animated:YES
                               completion:nil];
    }
}

-(void)promoViewControllerDidFinish:(FBPromoViewController *)viewController
{
    FBDeepLinker *deepLinker = [FBDeepLinker getInstance];
    
    if ([deepLinker canOpenFanbeat]) {
        if (_userId) {
            [deepLinker open:_partnerId forUser:_userId];
        } else {
            [deepLinker open:_partnerId];
        }
    } else {
        [self finalizeDelegate:NO];
    }
    
    
    [promoViewController dismissViewControllerAnimated:NO
                                            completion:nil];
}

-(void)deepLinkerDidFinish:(BOOL)success
{
    [self finalizeDelegate:success];
}

-(void)finalizeDelegate:(BOOL)didLaunch
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fanbeatDidFinish:)]) {
        [self.delegate fanbeatDidFinish:didLaunch];
    }
}

@end
