//
//  FBAnalytics.h
//  Pods
//
//  Created by Tony Sullivan on 9/14/16.
//
//

#import <Foundation/Foundation.h>

@interface FBAnalytics : NSObject

@property (nonatomic, assign) BOOL isLive;

+(instancetype)getInstance;
-(void)didViewPromoScreen:(NSString *)partnerId;
-(void)didInstallFanBeat:(NSString *)partnerId;

@end
