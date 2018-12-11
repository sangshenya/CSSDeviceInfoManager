//
//  CSSCGUtilities.h
//  CSSKit
//
//  Created by 陈坤 on 2018/12/3.
//

#import <UIKit/UIKit.h>

/// 屏幕缩放比
CGFloat CSSScreenScale(void);

/// 屏幕尺寸 (始终竖屏方向大小, height永远大于width)
CGSize CSSScreenSize(void);

/// 角度转弧度
static inline CGFloat CSSDegressToRadians(CGFloat degress) {
    return degress * M_PI / 180;
}

/// 弧度转角度
static inline CGFloat CSSRadiansToDegress(CGFloat radians) {
    return radians * 180 / M_PI;
}

/// 返回矩形的中心点
static inline CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// 返回矩形的区域面积
static inline CGFloat CGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// 返回两点之间的距离
static inline CGFloat CGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// 返回一个point距离矩形最短的距离
static inline CGFloat CGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    
    if (distH > 0 && distV > 0) {
        return sqrt(distH * distH + distV + distV);
    }
    return MAX(distV, distH);
}

/**
 Returns a rectangle to fit the param "rect" with specified content mode.
 
 @param rect The constrant rect
 @param size The content size
 @param mode The content mode
 @discussion UIViewContentModeRedraw is same as UIViewContentModeScaleToFill.
 */
CGRect CSSCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

// main screen's scale
#ifndef kScreenScale
#define kScreenScale CSSScreenScale()
#endif

// main screen's size (portrait)
#ifndef kScreenSize
#define kScreenSize CSSScreenSize()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth CSSScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight CSSScreenSize().height
#endif
