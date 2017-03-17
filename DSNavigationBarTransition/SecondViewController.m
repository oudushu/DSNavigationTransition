//
//  SecondViewController.m
//  DSNavigationBarTransition
//
//  Created by 欧杜书 on 16/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "SecondViewController.h"
#import "UINavigationController+Transition.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarAlpha = arc4random() % 2;
    self.navigationItem.title = [NSString stringWithFormat:@"SubVC %lu", self.navigationController.viewControllers.count];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    self.view.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.view addSubview:button];
    button.center = self.view.center;
    [button addTarget:self action:@selector(pushButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pushButtonClick:(id)sender {
    SecondViewController *vc = [[SecondViewController alloc] init];
    [self showViewController:vc sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
