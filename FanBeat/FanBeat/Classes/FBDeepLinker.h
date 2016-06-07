//
//  FBDeepLinker.h
//  Pods
//
//  Created by Tony Sullivan on 6/7/16.
//
//

#import <Foundation/Foundation.h>

@protocol FBDeepLinkerDelegate;

@interface FBDeepLinker : NSObject

@property (nonatomic, weak) id<FBDeepLinkerDelegate> delegate;
@property (nonatomic, assign) BOOL isLive;

+(instancetype)getInstance;
-(void)open:(NSString *)partnerId;
-(void)open:(NSString *)partnerId forUser:(NSString *)userId;
-(BOOL)canOpenFanbeat;

@end

@protocol FBDeepLinkerDelegate <NSObject>

- (void)deepLinkerDidFinish:(BOOL)success;

@end