//
//  FBPartnerConfig.h
//  Pods
//
//  Created by Tony Sullivan on 6/9/16.
//
//

#import <Foundation/Foundation.h>
#import "FBPromoPrize.h"

@interface FBPartnerConfig : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) NSString *promoBackground;
@property (nonatomic, strong) NSArray<FBPromoPrize*> *promoPrizes;
@property (nonatomic, strong) NSString *promoText;
@property (nonatomic, strong) NSString *promoLogo;

-(NSString *)getDeepLinkPath;

+ (FBPartnerConfig*)getDefault;

@end