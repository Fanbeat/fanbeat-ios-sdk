//
//  FanBeat.h
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import <Foundation/Foundation.h>

@interface FanBeat : NSObject

+(instancetype _Nonnull)getInstance;
-(void)open;
-(void)openForUser:(NSString *)userId;

@end
