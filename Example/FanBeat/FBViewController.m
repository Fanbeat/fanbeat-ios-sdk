//
//  FBViewController.m
//  FanBeat
//
//  Created by Tony Sullivan on 06/06/2016.
//  Copyright (c) 2016 Tony Sullivan. All rights reserved.
//


#import "FBViewController.h"
#import "FanBeat/FanBeat.h"

@interface FBViewController () {
    FanBeat *fanbeat;
}
@end

@implementation FBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    fanbeat = [FanBeat getInstance];
    fanbeat.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToFanBeat:(id)sender {
    [fanbeat open];
}

- (void)fanbeatDidFinish:(BOOL)didLaunch
{
    NSLog(@"FanBeat SDK returned, app %@ launch", didLaunch ? @"did" : @"did not");
}

- (void)presentMarketingViewController:(FBPromoViewController *)viewController onInstallFanBeat:(void (^)(void))onInstallFanBeat
{
    [viewController setShowCancelButton:YES];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
