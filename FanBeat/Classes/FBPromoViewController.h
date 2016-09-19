//
//  FBPromoViewController.h
//  Pods
//
//  Created by Tony Sullivan on 6/6/16.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "FBPartnerConfig.h"

@protocol FBPromoViewControllerDelegate;

@interface FBPromoViewController : UIViewController

@property (nonatomic, weak) id<FBPromoViewControllerDelegate> delegate;
- (void)setPartnerConfig:(FBPartnerConfig*)config;
- (void)setShowCancelButton:(BOOL)showCancelButton;
- (void)storeDidFinish;

@end

@protocol FBPromoViewControllerDelegate <NSObject>

-(void)promoViewControllerDidFinish:(FBPromoViewController *)viewController;

@end