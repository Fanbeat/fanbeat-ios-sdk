//
//  FBAnalytics.m
//  Pods
//
//  Created by Tony Sullivan on 9/14/16.
//
//

#import "FBAnalytics.h"
#import "FBConstants.h"

@implementation FBAnalytics

static NSString *const VIEW_PROMO_EVENT = @"activation";
static NSString *const INSTALLED_EVENT = @"installed";


+(instancetype)getInstance
{
    static FBAnalytics *analytics = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analytics = [[FBAnalytics alloc]init];
    });
    return analytics;
}

-(void)didViewPromoScreen:(NSString *)partnerId
{
    [self logEvent:VIEW_PROMO_EVENT forPartnerId:partnerId];
}

-(void)didInstallFanBeat:(NSString *)partnerId
{
    [self logEvent:INSTALLED_EVENT forPartnerId:partnerId];
}

-(void)logEvent:(NSString *)event forPartnerId:(NSString *)partnerId
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@sdk/%@/%@", _isLive ? FANBEAT_BASE_ANALYTICS_URL : FANBEAT_DEV_BASE_ANALYTICS_URL, partnerId, event]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:nil];
}

@end
