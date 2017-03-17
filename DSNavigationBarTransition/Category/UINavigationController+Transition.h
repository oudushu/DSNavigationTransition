//
//  UINavigationController+Transition.h
//  DSNavigationBarTransition
//
//  Created by 欧杜书 on 16/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Transition)

@property (nonatomic, assign) CGFloat navigationBarAlpha;
@property (nonatomic, strong) UIColor *navigationBarTintColor;

@end

@interface UINavigationController (Transition) <UINavigationControllerDelegate, UINavigationBarDelegate>

@end
