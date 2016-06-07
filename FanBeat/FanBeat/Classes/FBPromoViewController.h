//
//  FBPromoViewController.h
//  Pods
//
//  Created by Tony Sullivan on 6/6/16.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@protocol FBPromoViewControllerDelegate;

@interface FBPromoViewController : UIViewController <SKStoreProductViewControllerDelegate>

@property (nonatomic, weak) id<FBPromoViewControllerDelegate> delegate;

@end

@protocol FBPromoViewControllerDelegate <NSObject>

-(void)promoViewControllerDidFinish:(FBPromoViewController *)viewController;

@end