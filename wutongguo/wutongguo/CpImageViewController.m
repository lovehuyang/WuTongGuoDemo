//
//  CpImageViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpImageViewController.h"
#import "CompanyViewController.h"
#import "CpBrandViewController.h"
#import "VideoViewController.h"
#import "CommonFunc.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "UIImageView+WebCache.h"
#import "PopupView.h"

@interface CpImageViewController ()<NetWebServiceRequestDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrVideoData;
@property (nonatomic, strong) NSArray *arrVisualData;
@property (nonatomic, strong) NSArray *arrOtherCompanyData;
@property (nonatomic, strong) NSDictionary *cpBrandData;

@property (strong, nonatomic) UILabel *lbCompany;
@property (strong, nonatomic) UIScrollView *scrollVisual;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) float viewHeight;
@end

@implementation CpImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpImageByCpMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"cpMainID", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillData {
    self.title = [self.cpBrandData objectForKey:@"CpName"];
    self.viewHeight = 0;
    if (self.arrVisualData.count > 0) {
        [self fillVisual];
    }
    if (self.arrVideoData.count > 0) {
        [self fillVideo];
    }
    if (self.arrOtherCompanyData.count > 0) {
        [self fillOtherCompany];
    }
    [self.companyCtrl.arrayViewHeight replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:self.viewHeight + 10]];
}

- (void)fillVisual {
    UIView *viewVisual = [[UIView alloc] initWithFrame:CGRectMake(-0.5, self.viewHeight + 10, SCREEN_WIDTH + 1, 100)];
    [viewVisual setBackgroundColor:[UIColor whiteColor]];
    [viewVisual.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewVisual.layer setBorderWidth:0.5];
    [self.view addSubview:viewVisual];
    CustomLabel *lbVisualTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 10, VIEW_W(viewVisual), 20) content:@"环境照片" size:16 color:nil];
    [lbVisualTitle setTextAlignment:NSTextAlignmentCenter];
    [viewVisual addSubview:lbVisualTitle];
    self.scrollVisual = [[UIScrollView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbVisualTitle) + 10, SCREEN_WIDTH, 500)];
    [self.scrollVisual setBounces:NO];
    [self.scrollVisual setShowsHorizontalScrollIndicator:NO];
    [self.scrollVisual setShowsVerticalScrollIndicator:NO];
    [self.scrollVisual setPagingEnabled:YES];
    [self.scrollVisual setDelegate:self];
    [viewVisual addSubview:self.scrollVisual];
    for (NSInteger index = 0; index < self.arrVisualData.count; index++) {
        NSDictionary *visualData = [self.arrVisualData objectAtIndex:index];
        //照片
        UIImageView *imgVisual = [[UIImageView alloc] initWithFrame:CGRectMake(index * SCREEN_WIDTH + 10, 0, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20) * 0.6)];
        NSString *path = [NSString stringWithFormat:@"%d",([[visualData objectForKey:@"CpMainID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CP/Visual/%@/%@",path,[visualData objectForKey:@"Url"]];
        [imgVisual sd_setImageWithURL:[NSURL URLWithString:path]];
        [self.scrollVisual addSubview:imgVisual];
        //备注
        CustomLabel *lbVisualRemark = [[CustomLabel alloc] initWithFrame:CGRectMake(index * SCREEN_WIDTH, VIEW_BY(imgVisual) + 10, VIEW_W(viewVisual), 20) content:[visualData objectForKey:@"ContentText"] size:14 color:nil];
        [lbVisualRemark setTextAlignment:NSTextAlignmentCenter];
        [self.scrollVisual addSubview:lbVisualRemark];
        if (index == 0) {
            CGRect frameVisual = self.scrollVisual.frame;
            frameVisual.size.height = VIEW_BY(lbVisualRemark) + 10;
            [self.scrollVisual setFrame:frameVisual];
            [self.scrollVisual setContentSize:CGSizeMake(SCREEN_WIDTH * self.arrVisualData.count, VIEW_H(self.scrollVisual))];
            
            if (self.arrVisualData.count > 1) {
                UIButton *btnImagePrev = [[UIButton alloc] initWithFrame:CGRectMake(20, VIEW_Y(self.scrollVisual) + (VIEW_H(imgVisual) - 51) / 2, 21, 51)];
                [btnImagePrev setImage:[UIImage imageNamed:@"coImgPrev.png"] forState:UIControlStateNormal];
                [btnImagePrev setTag:0];
                [btnImagePrev addTarget:self action:@selector(visualScroll:) forControlEvents:UIControlEventTouchUpInside];
                [viewVisual addSubview:btnImagePrev];
                
                UIButton *btnImageNext = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewVisual) - 20 - VIEW_W(btnImagePrev), VIEW_Y(btnImagePrev), VIEW_W(btnImagePrev), VIEW_H(btnImagePrev))];
                [btnImageNext setImage:[UIImage imageNamed:@"coImgNext.png"] forState:UIControlStateNormal];
                [btnImageNext setTag:1];
                [btnImageNext addTarget:self action:@selector(visualScroll:) forControlEvents:UIControlEventTouchUpInside];
                [viewVisual addSubview:btnImageNext];
                
                self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgVisual), 200, 20)];
                [self.pageControl setSelected:NO];
                [self.pageControl setNumberOfPages:self.arrVisualData.count];
                [self.pageControl setCurrentPage:0];
                [self.pageControl setCurrentPageIndicatorTintColor:NAVBARCOLOR];
                [self.pageControl setPageIndicatorTintColor:[UIColor blackColor]];
                [self.pageControl setCenter:CGPointMake(imgVisual.center.x, self.pageControl.center.y)];
                [viewVisual addSubview:self.pageControl];
            }
        }
    }
    CGRect frameVisual = viewVisual.frame;
    frameVisual.size.height = VIEW_BY(self.scrollVisual);
    [viewVisual setFrame:frameVisual];
    self.viewHeight = VIEW_BY(viewVisual);
}

- (void)fillVideo {
    UIView *viewVideo = [[UIView alloc] initWithFrame:CGRectMake(-0.5, self.viewHeight + 10, SCREEN_WIDTH, 100)];
    [viewVideo setBackgroundColor:[UIColor whiteColor]];
    [viewVideo.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewVideo.layer setBorderWidth:0.5];
    [self.view addSubview:viewVideo];
    CustomLabel *lbVideoTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 10, VIEW_W(viewVideo), 20) content:@"企业视频" size:16 color:nil];
    [lbVideoTitle setTextAlignment:NSTextAlignmentCenter];
    [viewVideo addSubview:lbVideoTitle];
    float heightForVideo = VIEW_BY(lbVideoTitle);
    for (NSInteger index = 0; index < self.arrVideoData.count; index++) {
        NSDictionary *videoData = [self.arrVideoData objectAtIndex:index];
        CGRect frameBtnVideo = CGRectMake((index % 2 == 0 ? 10 : VIEW_W(viewVideo) / 2 + 5), heightForVideo + 5, (VIEW_W(viewVideo) - 30) / 2, 200);
        UIButton *btnVideo = [[UIButton alloc] initWithFrame:frameBtnVideo];
        [btnVideo setTag:index];
        [btnVideo addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnVideo setBackgroundColor:[UIColor blackColor]];
        [viewVideo addSubview:btnVideo];
        UIImageView *imgThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(btnVideo), VIEW_W(btnVideo) * 0.56)];
        [imgThumbnail sd_setImageWithURL:[NSURL URLWithString:[videoData objectForKey:@"Thumbnail"]]];
        [btnVideo addSubview:imgThumbnail];
        UIImageView *imgPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imgPlay setImage:[UIImage imageNamed:@"coVideoPlay.png"]];
        [imgPlay setCenter:imgThumbnail.center];
        [imgThumbnail addSubview:imgPlay];
        CustomLabel *lbVideoRemark = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgThumbnail), VIEW_W(btnVideo), 30) content:[videoData objectForKey:@"ContentText"] size:12 color:[UIColor whiteColor]];
        [lbVideoRemark setTextAlignment:NSTextAlignmentCenter];
        [btnVideo addSubview:lbVideoRemark];
        frameBtnVideo.size.height = VIEW_BY(lbVideoRemark);
        [btnVideo setFrame:frameBtnVideo];
        if (index + 1 == self.arrVideoData.count) {
            heightForVideo = VIEW_BY(btnVideo) + 10;
        }
        else if (index % 2 == 1) {
            heightForVideo = VIEW_BY(btnVideo);
        }
    }
    CGRect frameVideo = viewVideo.frame;
    frameVideo.size.height = heightForVideo;
    [viewVideo setFrame:frameVideo];
    self.viewHeight = VIEW_BY(viewVideo);
}

- (void)fillOtherCompany {
    UIView *viewOtherCompany = [[UIView alloc] initWithFrame:CGRectMake(-0.5, self.viewHeight + 10, SCREEN_WIDTH, 100)];
    [viewOtherCompany setBackgroundColor:[UIColor whiteColor]];
    [viewOtherCompany.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewOtherCompany.layer setBorderWidth:0.5];
    [self.view addSubview:viewOtherCompany];
    CustomLabel *lbOtherCompanyTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 10, VIEW_W(viewOtherCompany), 20) content:[NSString stringWithFormat:@"%@旗下其他企业形象展示", [self.cpBrandData objectForKey:@"CpName"]] size:16 color:NAVBARCOLOR];
    [lbOtherCompanyTitle setTextAlignment:NSTextAlignmentCenter];
    [viewOtherCompany addSubview:lbOtherCompanyTitle];
    float heightForOther = VIEW_BY(lbOtherCompanyTitle);
    float xForVideo = 0;
    for (NSInteger index = 0; index < self.arrOtherCompanyData.count; index++) {
        if (index % 3 == 0) {
            xForVideo = 0;
        }
        NSDictionary *otherCompanyData = [self.arrOtherCompanyData objectAtIndex:index];
        CGRect frameBtnOtherCompany = CGRectMake(xForVideo + 10, heightForOther + 5, (VIEW_W(viewOtherCompany) - 40) / 3, 200);
        UIButton *btnOtherCompany = [[UIButton alloc] initWithFrame:frameBtnOtherCompany];
        [btnOtherCompany setTag:index];
        [btnOtherCompany addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewOtherCompany addSubview:btnOtherCompany];
        
        UIImageView *imgVisual = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(btnOtherCompany), VIEW_W(btnOtherCompany))];
        NSString *path = [NSString stringWithFormat:@"%d",([[otherCompanyData objectForKey:@"CpMainID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CP/Visual/%@/%@",path,[otherCompanyData objectForKey:@"Url"]];
        NSLog(@"%@", path);
        [imgVisual sd_setImageWithURL:[NSURL URLWithString:path]];
        [btnOtherCompany addSubview:imgVisual];
        CustomLabel *lbCompany = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgVisual), VIEW_W(btnOtherCompany), 40) content:[otherCompanyData objectForKey:@"CpName"] size:12 color:TEXTGRAYCOLOR];
        [lbCompany setNumberOfLines:2];
        [lbCompany setTextAlignment:NSTextAlignmentCenter];
        [btnOtherCompany addSubview:lbCompany];
        frameBtnOtherCompany.size.height = VIEW_BY(lbCompany);
        [btnOtherCompany setFrame:frameBtnOtherCompany];
        xForVideo = VIEW_BX(btnOtherCompany);
        if (index + 1 == self.arrOtherCompanyData.count) {
            heightForOther = VIEW_BY(btnOtherCompany) + 10;
        }
        else if ((index + 1) % 3 == 0) {
            heightForOther = VIEW_BY(btnOtherCompany);
        }
    }
    if (self.arrOtherCompanyData.count > 0) {
        //查看更多按钮
        UIButton *btnOtherMore = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, heightForOther + 5, 100, 30)];
        [btnOtherMore setTitle:@"查看更多" forState:UIControlStateNormal];
        [btnOtherMore.titleLabel setFont:FONT(14)];
        [btnOtherMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [btnOtherMore addTarget:self action:@selector(otherCompany:) forControlEvents:UIControlEventTouchUpInside];
        [viewOtherCompany addSubview:btnOtherMore];
        heightForOther = VIEW_BY(btnOtherMore) + 5;
    }
    CGRect frameOtherCompany = viewOtherCompany.frame;
    frameOtherCompany.size.height = heightForOther;
    [viewOtherCompany setFrame:frameOtherCompany];
    self.viewHeight = VIEW_BY(viewOtherCompany);
}

- (void)videoClick:(UIButton *)sender {
    NSString *imageId = [[self.arrVideoData objectAtIndex:sender.tag] objectForKey:@"ID"];
    NSString *videoUrl = [NSString stringWithFormat:@"http://m.wutongguo.com/cpfront/video/%@?fromApp=1", imageId];
    VideoViewController *videoCtrl = [[VideoViewController alloc] init];
    videoCtrl.title = @"宣传视频";
    videoCtrl.url = videoUrl;
    [self.navigationController pushViewController:videoCtrl animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = self.scrollVisual.contentOffset.x / SCREEN_WIDTH;
    [self.pageControl setCurrentPage:page];
}

- (void)visualScroll:(UIButton *)sender {
    NSInteger page = self.scrollVisual.contentOffset.x / SCREEN_WIDTH;
    NSInteger maxPage = self.scrollVisual.contentSize.width / SCREEN_WIDTH - 1;
    if (sender.tag == 0) {
        if (page == 0) {
            return;
        }
        [self.scrollVisual setContentOffset:CGPointMake(SCREEN_WIDTH * (page - 1), 0) animated:YES];
    }
    else {
        if (page == maxPage) {
            return;
        }
        [self.scrollVisual setContentOffset:CGPointMake(SCREEN_WIDTH * (page + 1), 0) animated:YES];
    }
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *otherCompanyData = [self.arrOtherCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [otherCompanyData objectForKey:@"CpSecondID"];
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)otherCompany:(UIButton *)sender {
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [self.cpBrandData objectForKey:@"CpBrandSecondID"];
    cpBrandCtrl.title = [self.cpBrandData objectForKey:@"Column2"];
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrVideoData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        self.arrVisualData = [CommonFunc getArrayFromXml:requestData tableName:@"Table1"];
        self.cpBrandData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table2"] objectAtIndex:0];
        self.arrOtherCompanyData = [CommonFunc getArrayFromXml:requestData tableName:@"Table3"];
        [self fillData];
        [self.viewNoList popupClose];
        if (self.arrVideoData.count == 0 && self.arrVisualData.count == 0) {
            UIView *viewImage = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [self.view addSubview:viewImage];
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:viewImage tipsMsg:@"<div style=\"text-align:center\"><p>该企业未上传形象照片或视频</p><p>已罚他三天不准吃饭</p></div>"];
            }
            [viewImage addSubview:self.viewNoList];
        }
    }
}

@end
