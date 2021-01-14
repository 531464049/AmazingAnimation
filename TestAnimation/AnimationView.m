//
//  AnimationView.m
//  TestAnimation
//
//  Created by 银星智能 on 2021/1/12.
//

#import "AnimationView.h"
#import "AnimPoint.h"

/// 使用CoreGraphics绘制大量线条CPU占用高，CAShapeLayer使用硬件加速cpu占用低
#define k_user_layer

static const CGFloat k_maxLineLength = 60;//最大连线距离
static const CGFloat k_catchLength = 120;//最大捕获半径
static const NSInteger k_mutialPointCount = 120;//平均点数量

@interface AnimationView ()

@property(nonatomic,assign)BOOL isShow;//是否在显示
@property(nonatomic,strong)NSMutableArray<AnimPoint *> * pointArr;
@property(nonatomic,assign)CGPoint touchPoint;//手指操作点

@property(nonatomic,strong)CADisplayLink * updateLink;
@property(nonatomic,assign)NSInteger reFreshTime;

@end

@implementation AnimationView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupData];
    }
    return self;
}
-(void)setupData
{
    self.isShow = YES;
    self.pointArr = [NSMutableArray arrayWithCapacity:0];
    self.touchPoint = CGPointMake(-1, -1);
    
    for (int i = 0; i < k_mutialPointCount; i ++) {
        AnimPoint * point = [[AnimPoint alloc] initWithSuperSize:self.bounds.size];
        [self.pointArr addObject:point];
    }
    
    [self startUpdateLink];
}
#pragma mark -------- 定时器 ----------
- (void)startUpdateLink
{
    if (_updateLink == nil) {
        _updateLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayRender)];
        _updateLink.preferredFramesPerSecond = 20;
        [_updateLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)stopUpdateLink
{
    if(_updateLink){
        [_updateLink invalidate];
        _updateLink = nil;
    }
}
-(void)displayRender
{
    if (self.isShow) {
        self.reFreshTime += 1;
        self.reFreshTime = self.reFreshTime % self.updateLink.preferredFramesPerSecond/2;
#ifdef k_user_layer
        [self testLayerRender];
#else
        [self setNeedsDisplay];
#endif
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * aTouch = touches.anyObject;
    self.touchPoint = [aTouch locationInView:self];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * aTouch = touches.anyObject;
    self.touchPoint = [aTouch locationInView:self];
    [super touchesMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPoint = CGPointMake(-1, -1);
    [super touchesEnded:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPoint = CGPointMake(-1, -1);
    [super touchesCancelled:touches withEvent:event];
}
-(void)updatePointNextState
{
    NSMutableArray * newArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.pointArr.count; i ++) {
        AnimPoint * point = self.pointArr[i];
        if (!point.isDead) {
            [point next:self.bounds.size.width max_h:self.bounds.size.height touchPoint:self.touchPoint catchLength:k_catchLength];
            [newArr addObject:point];
        }
    }
    if (self.reFreshTime == 0) {
        if (newArr.count < k_mutialPointCount) {
            NSInteger mutiNum = k_mutialPointCount - newArr.count;
            int add = arc4random() % mutiNum*2;
            for (int i = 0; i < add; i ++) {
                AnimPoint * point = [[AnimPoint alloc] initWithSuperSize:self.bounds.size];
                [newArr addObject:point];
            }
        }
    }
    self.pointArr = [NSMutableArray arrayWithArray:newArr];
    //NSLog(@"----- %ld",self.pointArr.count);
}
-(void)drawLines
{
    for (int i = 0; i < self.pointArr.count; i ++) {
        AnimPoint * pi = self.pointArr[i];
        for (int j = i + 1; j < self.pointArr.count; j ++) {
            AnimPoint * pj = self.pointArr[j];
            CGFloat distance = [AnimPoint distanceP1:pi.point p2:pj.point];
            if (distance <= k_maxLineLength && distance > 20) {
                CGFloat alpha = 1 - distance / k_maxLineLength;
                UIColor * lineColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextBeginPath(context);
                CGContextSetLineWidth(context, 0.5);
                CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
                CGContextMoveToPoint(context, pi.point.x, pi.point.y);
                CGContextAddLineToPoint(context, pj.point.x, pj.point.y);
                CGContextStrokePath(context);
            }
        }
        if (pi.isCatched) {
            UIColor * lineColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:pi.touchLineAlpha];
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextBeginPath(context);
            CGContextSetLineWidth(context, 0.5);
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
            CGContextMoveToPoint(context, pi.point.x, pi.point.y);
            CGContextAddLineToPoint(context, self.touchPoint.x, self.touchPoint.y);
            CGContextStrokePath(context);
        }
    }
}
-(void)drawPoints
{
    for (int i = 0; i < self.pointArr.count; i ++) {
        AnimPoint * point = self.pointArr[i];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, point.color.CGColor);
        CGContextAddArc(context, point.point.x, point.point.y, point.radiu, 0, 2 * M_PI, 1);
        CGContextFillPath(context);
    }
}
-(void)drawRect:(CGRect)rect
{
#ifdef k_user_layer
    
#else
    [self updatePointNextState];
    [self drawLines];
    [self drawPoints];
#endif

}
-(void)testLayerRender
{
    [self updatePointNextState];
    while (self.layer.sublayers.count > 0) {
        CALayer* child = self.layer.sublayers.lastObject;
        [child removeFromSuperlayer];
    }
    [self drawLayerLines];
    [self drawLayerPoints];
}
-(void)drawLayerLines
{
    for (int i = 0; i < self.pointArr.count; i ++) {
        AnimPoint * pi = self.pointArr[i];
        for (int j = i + 1; j < self.pointArr.count; j ++) {
            AnimPoint * pj = self.pointArr[j];
            CGFloat distance = [AnimPoint distanceP1:pi.point p2:pj.point];
            if (distance <= k_maxLineLength && distance > 20) {
                CGFloat alpha = 1 - distance / k_maxLineLength;
                [self drawLayerLine:pi.point end:pj.point lineWidth:0.5 lineAlpha:alpha];
            }
        }
        if (pi.isCatched) {
            [self drawLayerLine:pi.point end:self.touchPoint lineWidth:0.5 lineAlpha:pi.touchLineAlpha];
        }
    }
}
-(void)drawLayerLine:(CGPoint)start end:(CGPoint)end lineWidth:(CGFloat)lineWidth lineAlpha:(CGFloat)lineAlpha
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = lineWidth;
    lineLayer.strokeColor = [UIColor grayColor].CGColor;
    lineLayer.opacity = lineAlpha;
    lineLayer.path = path.CGPath;
    lineLayer.fillColor = nil;
    [self.layer addSublayer:lineLayer];
}
-(void)drawLayerPoints
{
    for (int i = 0; i < self.pointArr.count; i ++) {
        AnimPoint * point = self.pointArr[i];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:point.point radius:point.radiu startAngle:0 endAngle:2 * M_PI clockwise:1];
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.strokeColor = [UIColor clearColor].CGColor;
        lineLayer.path = path.CGPath;
        lineLayer.fillColor = point.color.CGColor;
        [self.layer addSublayer:lineLayer];
    }
}
@end
