//
//  AnimPoint.h
//  TestAnimation
//
//  Created by 银星智能 on 2021/1/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimPoint : NSObject

@property(nonatomic,assign,readonly)CGPoint point;
@property(nonatomic,assign,readonly)CGFloat radiu;
@property(nonatomic,assign,readonly)CGFloat speed;
@property(nonatomic,assign,readonly)CGFloat direction;
@property(nonatomic,strong,readonly)UIColor * color;
@property(nonatomic,assign,readonly)NSInteger life;
@property(nonatomic,assign,readonly)NSInteger maxLife;
@property(nonatomic,assign,readonly)BOOL isCatched;
@property(nonatomic,assign,readonly)CGFloat touchLineAlpha;

-(instancetype)initWithSuperSize:(CGSize)superSize;

-(void)next:(CGFloat)max_w max_h:(CGFloat)max_h touchPoint:(CGPoint)touchPoint catchLength:(CGFloat)catchLength;

-(BOOL)isDead;

+(CGFloat)distanceP1:(CGPoint)p1 p2:(CGPoint)p2;

@end

NS_ASSUME_NONNULL_END
