//
//  CircularProgressView.m
//  CircularProgressView
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://nijino.cn

#import "CircularProgressView.h"
#import "CircleShadowImageView.h"
#import "GBPathImageView.h"
@interface CircularProgressView ()<AVAudioPlayerDelegate>

@property (nonatomic) NSTimer *timer;
@property (nonatomic) AVAudioPlayer *player;//an AVAudioPlayer instance
@property (nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CAShapeLayer *imageViewLayer;
@property (assign, nonatomic) float progress;
@property (assign, nonatomic) CGFloat angle;//angle between two lines
@property (nonatomic ,retain) CircleShadowImageView *centerBackGroundImageView;
@property (nonatomic ,retain) GBPathImageView *centerImageView;
@property BOOL isAnimationPlaying;
@end

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
          audioPath:(NSURL *)path {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
        _backColor = backColor;
        _progressColor = progressColor;
        self.lineWidth = lineWidth;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
        _player.delegate = self;
        [_player prepareToPlay];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}


- (void)setImagePicture:(UIImage *)im{
//    _centerImageView.image = im;

}


- (void)setUp{
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    CAShapeLayer *backgroundLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.backColor];
    _lineWidth = lineWidth;
    [self.layer addSublayer:backgroundLayer];
    _progressLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.progressColor];
    _progressLayer.strokeEnd = 0;
    
    [self.layer addSublayer:_progressLayer];

    _centerBackGroundImageView = [[CircleShadowImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame)-20, CGRectGetWidth(self.frame)-20)];
    [_centerBackGroundImageView setCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    [_centerBackGroundImageView setImage:[UIImage imageNamed:@"LPBackground.png"]];
    [_centerBackGroundImageView setShadow:[UIColor colorWithRed:0.1f green:0.2f blue:0.4f alpha:1.0f]
                         shadowOffset:CGSizeMake(7.0f, 7.0f)
                        shadowOpacity:0.8f
                         shadowRadius:15.0f];
    [self addSubview:_centerBackGroundImageView];

//    _centerImageView = [[CircleShadowImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame)-60, CGRectGetWidth(self.frame)-60)];
//    [_centerImageView setCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
//    [_centerImageView setImage:[UIImage imageNamed:@"saber.jpg"]];
//
//    [self addSubview:_centerImageView];
    
    
    _centerImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame)-60, CGRectGetWidth(self.frame)-60)
                                                        image:[UIImage imageNamed:@"saber.jpg"]
                                                     pathType:GBPathImageViewTypeCircle
                                                    pathColor:[UIColor clearColor]
                                                  borderColor:[UIColor clearColor]
                                                    pathWidth:0.0];

    [_centerImageView setCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    [self addSubview:_centerImageView];
    
    
     CircleShadowImageView * lpCenterImageView = [[CircleShadowImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame)-180, CGRectGetWidth(self.frame)-180)];
    [lpCenterImageView setCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    [lpCenterImageView setImage:[UIImage imageNamed:@"LPBackground.png"]];
    [lpCenterImageView setShadow:[UIColor clearColor]
                             shadowOffset:CGSizeMake(0.0f, 0.0f)
                            shadowOpacity:0.0f
                             shadowRadius:0.0f];
    [self addSubview:lpCenterImageView];
    	
}

- (void)setAudioPath:(NSURL *)audioPath{
    if (audioPath) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
        self.player.delegate = self;
        self.duration = self.player.duration;
        [self.player prepareToPlay];
    }
}

- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

- (void)setProgress:(float)progress{
    if (progress == 0) {
        self.progressLayer.hidden = YES;
            //self.progressLayer.affineTransform = CGAffineTransformMakeScale(0.8, 0.8);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressLayer.strokeEnd = 0;

        });
    }else {
        self.progressLayer.hidden = NO;
            //self.progressLayer.affineTransform = CGAffineTransformIdentity;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressLayer.strokeEnd = progress;
            
//        });
    }
}

- (void)updateProgressCircle:(NSTimer *)timer{
    //update progress value
    self.progress = (float) (self.player.currentTime / self.player.duration);
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
        [self.delegate updateProgressViewWithPlayer:self.player];
    }
}

- (void)play{
    if (!self.player.playing) {
            //alloc timer,interval:0.1 second
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgressCircle:) userInfo:nil repeats:YES];
        if (_isAnimationPlaying) {
            [self resumeLayer:_centerImageView.layer];
        }
        else{
            [self rostedImageView:_centerImageView withDurtion:32760000];
 
        }
        [self.player play];
    }
}

- (void)pause{
    if (self.player.playing) {
        [self pauseLayer:_centerImageView.layer];
        [self.timer invalidate];
        self.timer = nil;
        [self.player pause];
        
        
    }
}

- (void)stop{
    [self.player stop];
    self.player.currentTime = 0;
    [self rostedImageView:_centerImageView withDurtion:32760000];
    [self pauseLayer:_centerImageView.layer];
    [self.timer invalidate];
    self.timer = nil;
    [self updateProgressCircle:nil];
    
}



- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}


//继续layer上面的动画
- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}


-(void)rostedImageView:(CircleShadowImageView *)rotateView withDurtion:(int)durtion{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.duration = 20;
    rotationAnimation.RepeatCount = durtion;//你可以设置到最大的整数值
        rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [rotateView.layer addAnimation:rotationAnimation forKey:@"Rotation"];
    _isAnimationPlaying = YES;
}

#pragma mark AVAudioPlayerDelegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        //invalid timer
        [self.timer invalidate];
        self.timer = nil;
        //restore progress value
        self.progress = 0;
        [self.delegate playerDidFinishPlaying];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self];
    self.angle = [self angleFromStartToPoint:point];
    self.player.currentTime = self.player.duration * (self.angle / (2 * M_PI));
    [self updateProgressCircle:nil];
    if (!self.player.playing) {
        [self play];
    }
    [self.delegate updatePlayOrPauseButton];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.timer invalidate];
        self.timer = nil;
        CGPoint point = [recognizer locationInView:self];
        self.angle = [self angleFromStartToPoint:point];
        self.progress = self.angle/(M_PI * 2);
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
            [self.delegate updateProgressViewWithPlayer:self.player];
        }
    }

    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.player.currentTime = self.player.duration * (self.angle / (2 * M_PI));
        if (!self.player.playing) [self play];
        else self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgressCircle:) userInfo:nil repeats:YES];
        [self.delegate updatePlayOrPauseButton];
    }
}

//calculate angle between start to point
- (CGFloat)angleFromStartToPoint:(CGPoint)point{
    CGFloat angle = [self angleBetweenLinesWithLine1Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line1End:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2 - 1)
                                               Line2Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line2End:point];
    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), point)) {
        angle = 2 * M_PI - angle;
    }
    return angle;
}

//calculate angle between 2 lines
- (CGFloat)angleBetweenLinesWithLine1Start:(CGPoint)line1Start
                                  Line1End:(CGPoint)line1End
                                Line2Start:(CGPoint)line2Start
                                  Line2End:(CGPoint)line2End{
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    return acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
}

@end
