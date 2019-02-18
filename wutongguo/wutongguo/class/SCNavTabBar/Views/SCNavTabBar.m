//
//  SCNavTabBar.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBar.h"
#import "CommonMacro.h"

@interface SCNavTabBar ()
{
    UIScrollView    *_navgationTabBar;      // all items on this scroll view
    UIView          *_line;                 // underscore show which item selected
    NSMutableArray  *_items;                // SCNavTabBar pressed item
    NSArray         *_itemsWidth;           // an array of items' width
    BOOL            _popItemMenu;           // is needed pop item menu
}

@end

@implementation SCNavTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initConfig];
    }
    return self;
}

#pragma mark - Private Methods
- (void)initConfig
{
    _items = [@[] mutableCopy];
    [self viewConfig];
}

- (void)viewConfig
{
    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    _navgationTabBar.backgroundColor = UIColorWithRGBA(240.0f, 245.0f, 245.0f, 1.0f);
    UIView *viewBottomSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(_navgationTabBar), VIEW_W(_navgationTabBar), 0.5)];
    [viewBottomSeperate setBackgroundColor:SEPARATECOLOR];
    [self addSubview:_navgationTabBar];
    [self addSubview:viewBottomSeperate];
}

- (void)showLineWithButtonWidth:(CGFloat)width
{
    _line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, NAVIGATION_BAR_HEIGHT - 3.0f, width - 0.0f, 3.0f)];
    _line.backgroundColor = NAVBARCOLOR;
    [_navgationTabBar addSubview:_line];
}

- (CGFloat)contentWidthAndAddNavTabBarItemsWithButtonsWidth:(NSArray *)widths
{
    CGFloat buttonX = DOT_COORDINATE;
    for (NSInteger index = 0; index < [_itemTitles count]; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonX, DOT_COORDINATE, [widths[index] floatValue], NAVIGATION_BAR_HEIGHT);
        [button setTitle:_itemTitles[index] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        if (index == 0) {
            [button setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        }
        else {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button setTag:index];
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_navgationTabBar addSubview:button];
        
        [_items addObject:button];
        buttonX += [widths[index] floatValue];
    }
    
    [self showLineWithButtonWidth:[widths[0] floatValue]];
    return buttonX;
}

- (void)itemPressed:(UIButton *)button
{
    NSInteger index = [_items indexOfObject:button];
    [_delegate itemDidSelectedWithIndex:index button:button];
}

- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles;
{
    NSMutableArray *widths = [@[] mutableCopy];
    for (NSInteger i = 0; i < titles.count; i++) {
        NSNumber *width = [NSNumber numberWithFloat:SCREEN_WIDTH / titles.count];
        [widths addObject:width];
    }
    return widths;
}

#pragma mark - Public Methods
- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    _currentItemIndex = currentItemIndex;
    UIButton *button = _items[currentItemIndex];
    [_navgationTabBar setContentOffset:CGPointMake(DOT_COORDINATE, DOT_COORDINATE) animated:YES];
    [self setTabBarItemColor:button];
    [UIView animateWithDuration:0.2f animations:^{
        _line.frame = CGRectMake(button.frame.origin.x + 0.0f, _line.frame.origin.y, [_itemsWidth[currentItemIndex] floatValue] - 0.0f, _line.frame.size.height);
    }];
}

- (void)updateData
{
    _itemsWidth = [self getButtonsWidthWithTitles:_itemTitles];
    if (_itemsWidth.count)
    {
        CGFloat contentWidth = [self contentWidthAndAddNavTabBarItemsWithButtonsWidth:_itemsWidth];
        _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
    }
}

- (void)setTabBarItemColor:(UIButton *)button {
    NSArray *_subviews = [_navgationTabBar subviews];
    for (UIView *childView in _subviews) {
        if ([childView isKindOfClass:[UIButton class]]) {
            [(UIButton *)childView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    [button setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
