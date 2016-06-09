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

@end
