//
//  LWViewController.m
//  LWPurchase
//
//  Created by luowei on 04/23/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <LWPurchase/LWPurchaseViewController.h>
#import "LWViewController.h"

@interface LWViewController ()

@end

@implementation LWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(UIButton *)sender {
    UINavigationController *navigation = [LWPurchaseViewController navigationViewController];
    [self presentViewController:navigation animated:YES completion:^{}];
}

@end
