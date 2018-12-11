//
//  UIView+Addition.m
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (UIViewController *)css_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)css_left {
    return self.frame.origin.x;
}

- (void)setCss_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)css_top {
    return self.frame.origin.y;
}

- (void)setCss_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)css_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setCss_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)css_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setCss_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)css_width {
    return self.frame.size.width;
}

- (void)setCss_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)css_height {
    return self.frame.size.height;
}

- (void)setCss_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)css_centerX {
    return self.center.x;
}

- (void)setCss_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)css_centerY {
    return self.center.y;
}

- (void)setCss_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)css_origin {
    return self.frame.origin;
}

- (void)setCss_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)css_size {
    return self.frame.size;
}

- (void)setCss_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
