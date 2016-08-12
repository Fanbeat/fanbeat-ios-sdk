//
//  FanBeat.h
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import <Foundation/Foundation.h>
#import "FBPromoViewController.h"
#import "FBDeepLinker.h"

@protocol FanBeatDelegate;

@interface FanBeat : NSObject <FBPromoViewControllerDelegate, FBDeepLinkerDelegate>

@property (nonatomic, weak) id<FanBeatDelegate> delegate;

+(instancetype)getInstance;
-(void)initSession;
-(void)initSession:(NSString*)partnerId;
-(void)setDebug;
-(void)open;
-(void)openForUser:(NSString *)userId;

@end

@protocol FanBeatDelegate <NSObject>

-(void)presentMarketingViewController:(FBPromoViewController *)viewController onInstallFanBeat:(void(^)(void))onInstallFanBeat;
-(void)fanbeatDidFinish:(BOOL)didLaunch;

@end