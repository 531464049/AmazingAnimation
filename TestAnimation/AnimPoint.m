//
//  AnimPoint.m
//  TestAnimation
//
//  Created by 银星智能 on 2021/1/12.
//

#import "AnimPoint.h"

@interface AnimPoint ()

@end

@implementation AnimPoint

-(instancetype)initWithSuperSize:(CGSize)superSize
{
    self = [super init];
    if (self) {
        int x = arc4random() % (int)superSize.width;
        int y = arc4random() % (int)superSize.height;
        _point = CGPointMake(x, y);
        _radiu = arc4random() % 3 + 2;
        _speed = arc4random() % 3 + 1;
        _direction = arc4random() % 360;
        _maxLife = arc4random() % 300 + 100;
        _life = 0;
        _color = [AnimPoint randomColor];
    }
    return self;
}
-(void)next:(CGFloat)max_w max_h:(CGFloat)max_h touchPoint:(CGPoint)touchPoint catchLength:(CGFloat)catchLength
{
    _life += 1;
    CGFloat tempX = _point.x + cos(_direction*2*M_PI/360.f)*_speed;
    CGFloat tempY = _point.y + sin(_direction*2*M_PI/360.f)*_speed;
    CGFloat tempDirection = _direction;
    if (tempX >= max_w) {
        tempX = max_w;
        tempDirection = 180 - _direction;
    } else if (tempX <= 0) {
        tempX = 0;
        tempDirection = 180 - _direction;
    }
    if (tempY >= max_h) {
        tempY = max_h;
        tempDirection = 360 - _direction;
    } else if (tempY <= 0) {
        tempY = 0;
        tempDirection = 360 - _direction;
    }
    if (touchPoint.x < 0 || touchPoint.y < 0) {
        //无手指点
        _point = CGPointMake(tempX, tempY);
        _direction = tempDirection;
        _isCatched = NO;
        _touchLineAlpha = 0.f;
        return;
    }
    
    CGFloat distance = k_distance(tempX, tempY, touchPoint.x, touchPoint.y);
    if (_isCatched) {
        if (distance < catchLength) {
            _point = CGPointMake(tempX, tempY);
            _touchLineAlpha = (1.f - distance/catchLength)*0.5 + 0.1;
        } else {
            //挣脱几率
            NSInteger ss = arc4random() % 300;
            if (ss == 0) {
                //挣脱
                _point = CGPointMake(tempX, tempY);
                _touchLineAlpha = (1.f - distance/catchLength)*0.5 + 0.1;
                _isCatched = NO;
            }else {
                CGFloat angle = atan2(touchPoint.x - tempX, touchPoint.y - tempY);
                CGFloat rx = sin(angle) * catchLength;
                rx = touchPoint.x - tempX - rx;
                CGFloat ry = cos(angle) * catchLength;
                ry = touchPoint.y - tempY - ry;
                _point = CGPointMake(tempX + rx, tempY + ry);
                _touchLineAlpha = 0.1;
            }
        }
    }else{
        if (distance <= catchLength) {
            _isCatched = YES;
            _touchLineAlpha = (1.f - distance/catchLength)*0.5 + 0.1;
        }
        _point = CGPointMake(tempX, tempY);
    }
}
-(BOOL)isDead
{
    if (_life >= _maxLife) {
        return YES;
    }
    return NO;
}
CGFloat k_distance(double x1, double y1, double x2, double y2)
{
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}
+(UIColor *)randomColor
{
    CGFloat r = arc4random() % 256 / 255.0;
    CGFloat g = arc4random() % 256 / 255.0;
    CGFloat b = arc4random() % 256 / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}
+(CGFloat)distanceP1:(CGPoint)p1 p2:(CGPoint)p2
{
    return k_distance(p1.x, p1.y, p2.x, p2.y);
}
@end
