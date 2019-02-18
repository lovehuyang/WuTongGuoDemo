//
//  CommonFunc.h
//  wutongguo
//
//  Created by Lucifer on 15-5-19.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "LoadingAnimationView.h"
#import "CommonMacro.h"

@implementation LoadingAnimationView
- (id)initLoading {
//    self = [super initWithFrame:CGRectMake(0, 0, 80, 98)];
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        self.viewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.5, SCREEN_WIDTH * 0.5)];
		self.viewLoading.backgroundColor = [UIColor clearColor];
		AnimatedGif *aniGif = [[AnimatedGif alloc] init];
		NSString *gifName = @"loading";
		NSString *path = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
		[aniGif decodeGIF:[NSData dataWithContentsOfFile:path]];
	
		_gifs = [[aniGif frames] mutableCopy];
		self.viewLoading.animationImages = _gifs;
		self.viewLoading.animationDuration = 0.05f*[_gifs count];
		self.viewLoading.animationRepeatCount = 9999;
//        self.backgroundColor = UIColorWithRGBA(0, 0, 0, 0.5);
        self.backgroundColor = UIColorWithRGBA(255, 255, 255, 0.5);
        self.viewLoading.center = self.center;
        [self addSubview:self.viewLoading];
        [self setHidden:true];
    }
    return self;
}

- (void)startAnimating
{
    if (self.hidden) {
        self.hidden = NO;
    }
    [self.viewLoading startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(stopAnimating) userInfo:nil repeats:NO];
}

- (void)stopAnimating
{
    self.hidden = YES;
    [self.viewLoading stopAnimating];
}

@end
