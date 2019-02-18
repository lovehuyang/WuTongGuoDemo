//
//  CommonFunc.h
//  wutongguo
//
//  Created by Lucifer on 15-5-19.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatedGif.h"

@interface LoadingAnimationView : UIView {
	NSMutableArray *_gifs;
}

@property(nonatomic, strong) NSMutableArray *gifs;
@property(nonatomic, strong) UIImageView *viewLoading;
- (id)initLoading;
- (void)startAnimating;
- (void)stopAnimating;
@end
