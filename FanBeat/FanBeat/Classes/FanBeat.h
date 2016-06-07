//
//  FanBeat.h
//  Pods
//
//  Created by Tony Sullivan on 6/5/16.
//
//

#import <Foundation/Foundation.h>
#import "FBPromoViewController.h"

@interface FanBeat : NSObject <FBPromoViewControllerDelegate>

+(instancetype)getInstance;
-(void)open;
-(void)openForUser:(NSString *)userId;

@end
