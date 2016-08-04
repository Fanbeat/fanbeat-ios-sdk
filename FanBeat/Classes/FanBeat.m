//
//  FanBeat.m
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import "FanBeat.h"
#import "FBConstants.h"
#import "FBDeepLinker.h"
#import "FBPartnerConfig.h"
#import "FBPromoViewController.h"
#import "FBPromoPrize.h"

typedef void (^callbackWithUrl) (NSString *url, NSError *error);

@interface FanBeat() {
    NSString *_partnerId;
    NSString *_userId;
    FBPromoViewController *promoViewController;
    NSMutableData *_configData;
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
        [FBDeepLinker getInstance].isLive = YES;
        [FBDeepLinker getInstance].delegate = self;
        
        // attempt to get the partner ID from the app's plist
        NSDictionary *plist = [NSBundle mainBundle].infoDictionary;
        
        if (!plist) {
            NSLog(@"Main bundle plist not found!");
        } else {
            _partnerId = plist[FANBEAT_SDK_PLIST_KEY];
            
            if (!_partnerId) {
                NSLog(@"%@ not found in the plist!", FANBEAT_SDK_PLIST_KEY);
            } else {
                // if the partner ID was provided, try to load partner config
                [self loadConfig:_partnerId];
            }
        }
    }
    
    return self;
}

-(void)initWithPartnerId:(NSString *)partnerId
{
    _partnerId = partnerId;
    [self loadConfig:partnerId];
}

-(void)open
{
    [self openForUser:nil];
}

-(void)openForUser:(NSString *)userId
{
    if (!_partnerId) {
        NSLog(@"%@ not found in the plist!", FANBEAT_SDK_PLIST_KEY);
        [self finalizeDelegate:NO];
        return;
    }
    
    FBDeepLinker *deepLinker = [FBDeepLinker getInstance];
    
    if ([deepLinker canOpenFanbeat]) {
        [deepLinker open:_partnerId forUser:userId];
    } else {
        // if FanBeat isn't installed, cache the user ID and load the promo view
        _userId = userId;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(presentMarketingViewController:onInstallFanBeat:)]) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"FanBeatPod" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FanBeat" bundle:bundle];
            promoViewController = [storyboard instantiateInitialViewController];
            promoViewController.showCancelButton = NO;
            promoViewController.delegate = self;
            
            [self.delegate presentMarketingViewController:promoViewController onInstallFanBeat:^{
                [[FBDeepLinker getInstance] openStore:[UIApplication sharedApplication].keyWindow.rootViewController];
            }];
        } else {
            [[FBDeepLinker getInstance] openStore:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
    }
}

-(void)loadConfig:(NSString *)partnerId
{
    [FBDeepLinker getInstance].config = nil;
    
    if (partnerId == nil || [partnerId length] == 0)
        return;
    
    _configData = [NSMutableData data];
    
    NSString *urlPath = [NSString stringWithFormat:@"%@%@.json", FANBEAT_BASE_S3_URL, partnerId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connect didReceiveResponse:(nonnull NSURLResponse *)response
{
    [_configData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data
{
    [_configData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error
{
    NSLog(@"Could not load FanBeat partner config");
}

-(void)connectionDidFinishLoading:(NSConnection *)connection
{
    NSError *error = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:_configData options:NSJSONReadingMutableLeaves error:&error];
    
    // parse the config and cache it in the deep linker
    FBPartnerConfig *config = [[FBPartnerConfig alloc] init];
    
    config.id = res[@"id"];
    config.name = res[@"name"];
    config.channel = res[@"channel"];
    config.team = res[@"team"];
    config.promoBackground = res[@"promoBackground"];
    config.promoPrizes = @[];
    config.promoText = res[@"promoText"];
    
    if (res[@"promoPrizes"]) {
        for (NSDictionary *prizeData in res[@"promoPrizes"]) {
            FBPromoPrize *prize = [[FBPromoPrize alloc]init];
            prize.title = prizeData[@"title"];
            prize.icon = prizeData[@"icon"];
            config.promoPrizes = [config.promoPrizes arrayByAddingObject:prize];
        }
    }
    
    [FBDeepLinker getInstance].config = config;
}

-(void)promoViewControllerDidFinish:(FBPromoViewController *)viewController
{
    [self storeDidFinish];
}

- (void)storeDidFinish
{
    FBDeepLinker *deepLinker = [FBDeepLinker getInstance];
    
    // once we get back from the promo view, check to see if the app was installed
    // Don't finalize the delegate if we can open FanBeat now, wait for the deep linker to do it's job
    if ([deepLinker canOpenFanbeat]) {
        if (_userId) {
            [deepLinker open:_partnerId forUser:_userId];
        } else {
            [deepLinker open:_partnerId];
        }
    } else {
        [self finalizeDelegate:NO];
    }
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