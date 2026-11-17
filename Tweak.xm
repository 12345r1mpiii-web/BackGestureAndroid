#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface BGAEdgeView : UIView
@property(nonatomic, strong) CAShapeLayer *dropLayer;
@end

@implementation BGAEdgeView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = UIColor.clearColor;
        _dropLayer = [CAShapeLayer layer];
        _dropLayer.fillColor = UIColor.blackColor.CGColor;
        [self.layer addSublayer:_dropLayer];
    }
    return self;
}
- (void)drawDropAtY:(CGFloat)y progress:(CGFloat)p fromRight:(BOOL)right {
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat w = 34.0 + 28.0 * p;
    CGFloat cy = MIN(MAX(y, 50.0), h - 50.0);
    CGFloat dir = right ? -1.0 : 1.0;
    CGFloat edge = right ? CGRectGetWidth(self.bounds) : 0.0;
    CGFloat depth = w * (0.65 + 0.35 * p);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(edge, cy - 39.0 - 12.0*p)];
    [path addCurveToPoint:CGPointMake(edge + dir*depth, cy)
            controlPoint1:CGPointMake(edge + dir*(depth*0.05), cy - 24.0 - 15.0*p)
            controlPoint2:CGPointMake(edge + dir*(depth*1.25), cy - 20.0*p)];
    [path addCurveToPoint:CGPointMake(edge, cy + 39.0 + 12.0*p)
            controlPoint1:CGPointMake(edge + dir*(depth*1.25), cy + 20.0*p)
            controlPoint2:CGPointMake(edge + dir*(depth*0.05), cy + 24.0 + 15.0*p)];
    [path closePath];
    self.dropLayer.path = path.CGPath;
    self.dropLayer.opacity = 0.35 + 0.65*p;
}
@end

@interface BGAGestureTarget : NSObject <UIGestureRecognizerDelegate>
@property(nonatomic, weak) UIWindow *window;
@property(nonatomic, strong) BGAEdgeView *indicator;
@property(nonatomic) BOOL fromRight;
@end

@implementation BGAGestureTarget
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.window];
    CGFloat edgeWidth = 26.0;
    BOOL left = p.x <= edgeWidth;
    BOOL right = p.x >= CGRectGetWidth(self.window.bounds) - edgeWidth;
    if (!left && !right) return NO;
    self.fromRight = right;
    CGPoint v = [gesture velocityInView:self.window];
    return fabs(v.x) > fabs(v.y) * 1.15 && (right ? v.x < 0 : v.x > 0);
}
- (void)handle:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.window];
    CGPoint translation = [gesture translationInView:self.window];
    CGFloat width = CGRectGetWidth(self.window.bounds);
    CGFloat progress = MIN(1.0, MAX(0.0, fabs(translation.x) / MAX(1.0, width*0.42)));
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.indicator.hidden = NO;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self.indicator drawDropAtY:point.y progress:progress fromRight:self.fromRight];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        BOOL commit = progress > 0.30 || fabs([gesture velocityInView:self.window].x) > 850.0;
        [UIView animateWithDuration:0.22 animations:^{
            self.indicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.indicator.hidden = YES;
            self.indicator.alpha = 1.0;
        }];
        if (commit) {
            UIViewController *top = self.window.rootViewController;
            while (top.presentedViewController && !top.presentedViewController.isBeingDismissed) {
                top = top.presentedViewController;
            }
            if (top.navigationController.viewControllers.count > 1) {
                [top.navigationController popViewControllerAnimated:YES];
            } else if (top.presentingViewController) {
                [top dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}
@end

static const void *kBGATargetKey = &kBGATargetKey;

%group BackGestureAndroid
%hook UIWindow
- (void)makeKeyAndVisible {
    %orig;
    if (!self.rootViewController || objc_getAssociatedObject(self, kBGATargetKey)) return;
    BGAGestureTarget *target = [BGAGestureTarget new];
    target.window = self;
    target.indicator = [[BGAEdgeView alloc] initWithFrame:self.bounds];
    target.indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    target.indicator.hidden = YES;
    [self addSubview:target.indicator];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handle:)];
    pan.delegate = target;
    pan.maximumNumberOfTouches = 1;
    pan.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pan];
    objc_setAssociatedObject(self, kBGATargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end
%end

%ctor {
    @autoreleasepool {
        %init(BackGestureAndroid);
    }
}
