//
//  FanBeat.h
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface FanBeat : NSObject

+(instancetype)getInstance;
-(void)setup;
-(void)openForUser:(NSString *)userId withResult:(void(^)(BOOL, NSError * _Nullable))onResult;
-(void)openWithResult:(void(^)(BOOL, NSError * _Nullable))onResult;

@end
