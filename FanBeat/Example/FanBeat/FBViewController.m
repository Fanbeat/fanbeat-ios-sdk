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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToFanBeat:(id)sender {
    [fanbeat open];
}

@end
