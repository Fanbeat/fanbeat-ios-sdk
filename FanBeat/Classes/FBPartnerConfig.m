//
//  FBPartnerConfig.m
//  Pods
//
//  Created by Tony Sullivan on 6/9/16.
//
//

#import "FBPartnerConfig.h"

@implementation FBPartnerConfig

-(NSString *)getDeepLinkPath
{
    // channel is required for all deep links
    if (!self.channel)
        return nil;
    
    // priority:
    // 1. team/[channel]/[team]
    // 2. channel/[channel]
    if (self.team != nil && [self.team length] > 0) {
        return [NSString stringWithFormat:@"team/%@/%@", self.channel, self.team];
    } else {
        return [NSString stringWithFormat:@"channel/%@", self.channel];
    }
}

+ (FBPartnerConfig *)getDefault
{
    FBPartnerConfig *config = [[FBPartnerConfig alloc]init];
    config.name = @"Golf Channel FanBeat";
    config.channel = @"golfchannel";
    config.team = @"golf__rydercup";
    config.promoBackground = @"promo_background";
    config.promoText = @"With FanBeat, compete to win awesome prizes by answering predict-the-action and trivia questions during the 2016 Ryder Cup. It's fun and free to play!";
    
    FBPromoPrize *golfBag = [[FBPromoPrize alloc]init];
    golfBag.icon = @"ping_bag_stand";
    
    FBPromoPrize *callowayWedge = [[FBPromoPrize alloc]init];
    callowayWedge.icon = @"calloway_wedge";
    
    FBPromoPrize *titleistBalls = [[FBPromoPrize alloc]init];
    titleistBalls.icon = @"titleist_balls";
    
    config.promoPrizes = @[golfBag, callowayWedge, titleistBalls];
    
    return config;
}

@end