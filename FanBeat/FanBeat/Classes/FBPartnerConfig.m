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
    if (!self.channel)
        return nil;
    
    if (self.team != nil && [self.team length] > 0) {
        return [NSString stringWithFormat:@"team/%@/%@", self.channel, self.team];
    } else {
        return [NSString stringWithFormat:@"channel/%@", self.channel];
    }
}

@end
