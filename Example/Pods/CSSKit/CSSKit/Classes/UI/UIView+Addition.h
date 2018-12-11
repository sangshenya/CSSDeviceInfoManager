//
//  UIView+Addition.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Addition)

/**
 Returns the view's view controller (may be nil).
 */
@property (nonatomic, readonly) UIViewController *css_viewController;

@property (nonatomic) CGFloat css_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat css_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat css_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat css_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat css_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat css_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat css_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat css_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint css_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  css_size;        ///< Shortcut for frame.size.

@end

NS_ASSUME_NONNULL_END
