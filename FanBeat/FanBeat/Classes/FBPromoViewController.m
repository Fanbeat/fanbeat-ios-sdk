//
//  FBPromoViewController.m
//  Pods
//
//  Created by Tony Sullivan on 6/6/16.
//
//

#import "FBPromoViewController.h"

static const int FANBEAT_STORE_ID = 966632826;

@interface FBPromoViewController ()

@end

@implementation FBPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)playNowTapped:(id)sender {
    [self openStore: [NSNumber numberWithInteger:FANBEAT_STORE_ID]];
}

-(void)openStore:(NSNumber *)storeId
{
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: storeId};
    
    [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            return;
        }
        
        if (result) {
            UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController: storeViewController
                                     animated:YES
                                   completion:nil];
        }
    }];
}

@end
