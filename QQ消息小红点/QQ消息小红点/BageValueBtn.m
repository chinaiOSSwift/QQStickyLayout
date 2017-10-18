//
//  BageValueBtn.m
//  QQ消息小红点
//
//  Created by 万艳勇 on 2017/10/18.
//  Copyright © 2017年 SKOrganization. All rights reserved.
//

#import "BageValueBtn.h"

@interface BageValueBtn()

@property (nonatomic, strong)UIView *smallCircle;

@property (nonatomic, strong)CAShapeLayer *shapL;

@end

@implementation BageValueBtn

- (CAShapeLayer *)shapL{
    if (!_shapL) {
        CAShapeLayer *shapL = [CAShapeLayer layer];
        shapL.fillColor = [UIColor redColor].CGColor;
        [self.superview.layer insertSublayer:shapL atIndex:0];
        _shapL = shapL;
    }
    return _shapL;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUp];
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    
}




- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)pan:(UIPanGestureRecognizer *)pan{
    //拖动
    CGPoint tranP = [pan translationInView:self];
    // transform,并没有修改center,它修改的是frame
    //self.transform = CGAffineTransformTranslate(self.transform, tranP.x, tranP.y);
    
    CGPoint centerP = self.center;
    centerP.x += tranP.x;
    centerP.y += tranP.y;
    self.center = centerP;
    // 复位
    [pan setTranslation:CGPointZero inView:self];
    
    // 两个圆距离
    CGFloat distance = [self distanceWithSmallCircl:self.smallCircle BigCircle:self];
    
    // 让小圆半径根据距离增大减小
    CGFloat smallRaduir = self.bounds.size.width * 0.5; // 小圆大小 和 大圆大小相等
    smallRaduir -= distance / 10.0;
    self.smallCircle.bounds = CGRectMake(0, 0, smallRaduir * 2, smallRaduir * 2);
    self.smallCircle.layer.cornerRadius = smallRaduir;
    
    //NSLog(@"%@,%f",NSStringFromCGPoint(self.center),distance);
    
    
    UIBezierPath *path = [self pathWithSmallCircl:self.smallCircle BigCircle:self];
    // 形状图层
    
    if (self.smallCircle.hidden == false) {
        self.shapL.path = path.CGPath;
    }
    if (distance > 60) {
        // 让小圆隐藏, 让路径隐藏
        self.smallCircle.hidden = true;
        [self.shapL removeFromSuperlayer];
    }else{
        self.smallCircle.hidden = false;
        [self.superview.layer insertSublayer:self.shapL atIndex:0];
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 判断距离是否大于 60
        if (distance < 60) { // 小于 60 复位
            // 1.移除路径
            [self.shapL removeFromSuperlayer];
            self.center = self.smallCircle.center;
            self.smallCircle.hidden = false;
        }else{ // 大于 60 让按妞消失
            // 播放一个动画,消失
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.bounds];
            NSMutableArray *animationArr = [NSMutableArray array];
            
            /* 这里添加图片
             for (int i = 0; i < 8; i ++) {
             UIImage *temImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jgp",i]];
             [animationArr addObject:temImage];
             }*/
            imageV.animationImages = animationArr;
            imageV.animationDuration = 1; // 动画时长
            imageV.animationRepeatCount = 1;// 重复次数
            [imageV startAnimating];
            [self addSubview:imageV];
            
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
    }
    
}


- (void)setUp{
    // 圆角
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.backgroundColor = [UIColor redColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.layer.masksToBounds = true;
    
    // 添加小圆
    
    UIView *smallCircle = [[UIView alloc]initWithFrame:self.frame];
    smallCircle.layer.cornerRadius = self.layer.cornerRadius;
    smallCircle.backgroundColor = [UIColor redColor];
    self.smallCircle = smallCircle;
    // 把一个UIView添加到指定位置
    [self.superview insertSubview:smallCircle belowSubview:self];
    
}
// 求两个圆的距离
- (CGFloat)distanceWithSmallCircl:(UIView *)smallCircle BigCircle:(UIView *)bigCircl{
    // X轴方向偏移量
    CGFloat offsetX = bigCircl.center.x - smallCircle.center.x;
    // Y轴方向偏移量
    CGFloat offsetY = bigCircl.center.y - smallCircle.center.y;
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}
// 给定两个圆,描述一个不规则的路径
- (UIBezierPath *)pathWithSmallCircl:(UIView *)smallCircle BigCircle:(UIView *)bigCircl{
    CGFloat x1 = smallCircle.center.x;
    CGFloat y1 = smallCircle.center.y;
    
    CGFloat x2 = bigCircl.center.x;
    CGFloat y2 = bigCircl.center.y;
    
    CGFloat d = [self distanceWithSmallCircl:smallCircle BigCircle:bigCircl];
    if (d <= 0) {
        return nil;
    }
    
    CGFloat cosθ = (y2 - y1) / d;
    CGFloat sinθ = (x2 - x1) / d;
    
    CGFloat r1 = smallCircle.bounds.size.width * 0.5; // 小圆半径
    CGFloat r2 = bigCircl.bounds.size.width * 0.5; // 大圆半径
    // 开始描述点
    // A点
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinθ, pointA.y + d * 0.5 * cosθ);
    
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinθ, pointB.y + d * 0.5 * cosθ);
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // AB
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    // BC(曲线)
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // DA(曲线)
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}


// 取消高亮状态
- (void)setHighlighted:(BOOL)highlighted{
    
}

@end


















