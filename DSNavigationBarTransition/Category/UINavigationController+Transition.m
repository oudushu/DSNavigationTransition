//
//  UINavigationController+Transition.m
//  DSNavigationBarTransition
//
//  Created by 欧杜书 on 16/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "UINavigationController+Transition.h"
#import <objc/runtime.h>

const static NSTimeInterval animateTimeInterval = 0.25;

@implementation UINavigationController (Transition)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

#pragma mark - Method Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UINavigationController swizzleMethodOriginalSelector:NSSelectorFromString(@"_updateInteractiveTransition:") swizzledSelector:@selector(ds__updateInteractiveTransition:)];
        [UINavigationController swizzleMethodOriginalSelector:@selector(popToRootViewControllerAnimated:) swizzledSelector:@selector(ds_popToRootViewControllerAnimated:)];
        [UINavigationController swizzleMethodOriginalSelector:@selector(popToViewController:animated:) swizzledSelector:@selector(ds_popToViewController:animated:)];
    });
}

+ (void)swizzleMethodOriginalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel {
    Class class = [self class];
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

- (void)ds__updateInteractiveTransition:(CGFloat)persentComplete {
    [self ds__updateInteractiveTransition:persentComplete];
    if (self.topViewController) {
        id <UIViewControllerTransitionCoordinator> coordinator = self.topViewController.transitionCoordinator;
        if (coordinator) {
            CGFloat fromAlpha = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey].navigationBarAlpha;
            CGFloat toAlpha = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey].navigationBarAlpha;
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * persentComplete;
            [self setNeedsNavigationBackground:nowAlpha];
            
            UIColor *fromColor = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey].navigationBarTintColor;
            UIColor *toColor = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey].navigationBarTintColor;
            UIColor *nowColor = [self averageColorFromColor:fromColor toColor:toColor percent:persentComplete];
            self.navigationBar.tintColor = nowColor;
        }
    }
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    UIView *barBackgroundView = self.navigationBar.subviews.firstObject;
    if (!barBackgroundView) return;
    
    UIView *shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    if (shadowView) {
        shadowView.alpha = alpha;
    }
    
    if (self.navigationBar.isTranslucent) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
            UIView *backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            [UIView animateWithDuration:animateTimeInterval animations:^{
                backgroundEffectView.alpha = alpha;
            }];
            return;
        } else {
            UIView *adaptiveBackdrop = [barBackgroundView valueForKey:@"_adaptiveBackdrop"];
            UIView *backdropEffectView = [adaptiveBackdrop valueForKey:@"_backdropEffectView"];
            [UIView animateWithDuration:animateTimeInterval animations:^{
                backdropEffectView.alpha = alpha;
            }];
            return;
        }
    } else {
        barBackgroundView.alpha = alpha;
    }
}

- (UIColor *)averageColorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(CGFloat)percent  {
    CGFloat fromRed = 0, fromGreen = 0, fromBlue = 0, fromAlpha = 0;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0, toGreen = 0, toBlue = 0, toAlpha = 0;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat nowRed = fromRed + (toRed - fromRed) * percent;
    CGFloat nowGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat nowBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    
    return [UIColor colorWithRed:nowRed green:nowGreen blue:nowBlue alpha:nowAlpha];
}

- (NSArray<UIViewController *> *)ds_popToRootViewControllerAnimated:(BOOL)animated {
    UIViewController *firstViewController = self.viewControllers.firstObject;
    [self setNeedsNavigationBackground:firstViewController.navigationBarAlpha];
    self.navigationBar.tintColor = firstViewController.navigationBarTintColor;
    return [self ds_popToRootViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)ds_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self setNeedsNavigationBackground:viewController.navigationBarAlpha];
    self.navigationBar.tintColor = viewController.navigationBarTintColor;
    return [self ds_popToViewController:viewController animated:animated];
}

#pragma mark - delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topViewController = navigationController.topViewController;
    id <UIViewControllerTransitionCoordinator> coordinator = topViewController.transitionCoordinator;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self dealInteractionChanges:context];
        }];
    } else {
        [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self dealInteractionChanges:context];
        }];
    }
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if (context.isCancelled) {
        NSTimeInterval timeInterval = context.transitionDuration * context.percentComplete;
        [UIView animateWithDuration:timeInterval animations:^{
            CGFloat fromAlpha = [context viewControllerForKey:UITransitionContextFromViewControllerKey].navigationBarAlpha;
            UIColor *fromColor = [context viewControllerForKey:UITransitionContextFromViewControllerKey].navigationBarTintColor;
            [self setNeedsNavigationBackground:fromAlpha];
            self.navigationBar.tintColor = fromColor;
        }];
    } else {
        NSTimeInterval timeInterval = context.transitionDuration * (1 - context.percentComplete);
        [UIView animateWithDuration:timeInterval animations:^{
            CGFloat toAlpha = [context viewControllerForKey:UITransitionContextToViewControllerKey].navigationBarAlpha;
            UIColor *toColor = [context viewControllerForKey:UITransitionContextToViewControllerKey].navigationBarTintColor;
            [self setNeedsNavigationBackground:toAlpha];
            self.navigationBar.tintColor = toColor;
        }];
    }
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *topViewController = self.topViewController;
    if (topViewController) {
        id <UIViewControllerTransitionCoordinator> coordinator = topViewController.transitionCoordinator;
        if (coordinator.initiallyInteractive) {
            return YES;
        }
    }
    UIViewController *popToViewController = nil;
    if (self.viewControllers.count >= navigationBar.items.count) {
        popToViewController = self.viewControllers[self.viewControllers.count - 2];
    } else {
        popToViewController = self.viewControllers[self.viewControllers.count - 1];
    }
    
    if (popToViewController) {
        [self popToViewController:popToViewController animated:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    [self setNeedsNavigationBackground:self.topViewController.navigationBarAlpha];
    navigationBar.tintColor = self.topViewController.navigationBarTintColor;
    return YES;
}

@end

#pragma mark -
static char kNavigationBarAlphaKey;
static char kNavigationBarTintColorKey;

@implementation UIViewController (Transition)

- (CGFloat)navigationBarAlpha {
    NSNumber *alpha = objc_getAssociatedObject(self, &kNavigationBarAlphaKey);
    if (!alpha) {
        return 1;
    } else {
        return alpha.floatValue;
    }
}

- (void)setNavigationBarAlpha:(CGFloat)navigationBarAlpha {
    CGFloat alpha = navigationBarAlpha;
    if (alpha > 1) {
        alpha = 1;
    }
    if (alpha < 0) {
        alpha = 0;
    }
    [self.navigationController setNeedsNavigationBackground:navigationBarAlpha];
    objc_setAssociatedObject(self, &kNavigationBarAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)navigationBarTintColor {
    UIColor *color = objc_getAssociatedObject(self, &kNavigationBarTintColorKey);
    if (!color) {
        return [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1.0];
    } else {
        return color;
    }
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor {
    self.navigationController.navigationBar.tintColor = navigationBarTintColor;
    objc_setAssociatedObject(self, &kNavigationBarTintColorKey, navigationBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
