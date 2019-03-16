//
//  UIApplication+Tracker.m
//  CSSDeviceInfoManager
//
//  Created by 陈坤 on 2019/3/16.
//

#import "UIApplication+Tracker.h"
#import <CSSKit/NSObject+Addition.h>
#import <objc/runtime.h>
#import <CSSKit/UIView+Addition.h>
#import <CSSDeviceInfoTool/CSSDeviceInfoTool.h>
#import "CSSTrackerEventModel.h"
#import <CSSKit/CSSMacros.h>
#import "CSSTrackerPersistence.h"

@interface CSSTrackerTouchObject : NSObject

@property (nonatomic, copy) NSString *screenVC;
@property (nonatomic, copy) NSString *screenView;
@property (nonatomic, assign) CGPoint touchPointInWindow;
@property (nonatomic, copy) NSString *dateString;

@end

@implementation CSSTrackerTouchObject

@end

@implementation UIApplication (Tracker)

+ (void)startTracker {
    [self swizzleInstanceMethod:@selector(sendEvent:) with:@selector(css_trackerSendEvent:)];
}

static const int touchObj_key;
- (void)css_trackerSendEvent:(UIEvent *)event {
    [self css_trackerSendEvent:event];
    
    UITouch *touch = event.allTouches.anyObject;
    
    if (touch.phase == UITouchPhaseBegan) {
        CSSTrackerTouchObject *touchBeganObj = objc_getAssociatedObject(self, &touchObj_key);
        
        if (!touchBeganObj) {
            touchBeganObj = [CSSTrackerTouchObject new];
            objc_setAssociatedObject(self, &touchObj_key, touchBeganObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            // reset
            touchBeganObj.screenVC = nil;
            touchBeganObj.screenView = nil;
            touchBeganObj.touchPointInWindow = CGPointZero;
            touchBeganObj.dateString = nil;
        }
        
        touchBeganObj.screenVC = touch.view.css_viewController ? NSStringFromClass([touch.view.css_viewController class]):@"";
        touchBeganObj.screenView = [NSString stringWithFormat:@"%@", touch.view ? :@""];
        touchBeganObj.touchPointInWindow = [touch locationInView:touch.window];
        touchBeganObj.dateString = KCSSTDateString([NSDate date], @"yyyy-MM-dd HH:mm:ss.SSS");
    }
    
    if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) {
        CSSTrackerTouchObject *touchBeganObj = objc_getAssociatedObject(self, &touchObj_key);
        if (!touchBeganObj) {
            return;
        }
        
        NSString *touchEndVC = touch.view.css_viewController ? NSStringFromClass([touch.view.css_viewController class]):@"";
        NSString *touchEndView = [NSString stringWithFormat:@"%@", touch.view ? : @""];
        CGPoint touchEndPointInWindow = [touch locationInView:touch.window];
        NSString *touchEndDateString = KCSSTDateString([NSDate date], @"yyyy-MM-dd HH:mm:ss.SSS");
        
        NSString *screenVC = kStringIsEmpty(touchBeganObj.screenVC) ? touchEndVC : touchBeganObj.screenVC;
        NSString *screenView = kStringIsEmpty(touchBeganObj.screenView) ? touchEndView : touchBeganObj.screenView;
        CGFloat distanceX = fabs(touchEndPointInWindow.x - touchBeganObj.touchPointInWindow.x);
        CGFloat distanceY = fabs(touchEndPointInWindow.y - touchBeganObj.touchPointInWindow.y);
        
        NSString *operationType = (distanceX >= 10 || distanceY >= 10) ? @"SLIDE" : @"CLICK";
        NSString *scheme = [NSString stringWithFormat:@"%@://%@", screenVC, screenView];
        
        CSSTrackerEventModel *eventModel = [[CSSTrackerEventModel alloc] init];
        eventModel.operationType = operationType;
        eventModel.scheme = scheme;
        eventModel.startCooX = touchBeganObj.touchPointInWindow.x;
        eventModel.startCooY = touchBeganObj.touchPointInWindow.y;
        eventModel.endCooX = touchEndPointInWindow.x;
        eventModel.endCooY = touchEndPointInWindow.y;
        eventModel.startTime = touchBeganObj.dateString;
        eventModel.endTime = touchEndDateString;
        
        [[CSSTrackerPersistence sharedInstance] persistCustomEvent:eventModel];
//        [[MCTracker sharedInstance]->_persistence persistCustomEvent:eventModel];
    }
    
}

@end
