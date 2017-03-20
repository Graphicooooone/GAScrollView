//
//  ViewController.m
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import "ViewController.h"
#import "GAScrollView.h"

@interface ViewController () <GAScrollViewDelegate>
@property (nonatomic,strong) NSArray* titles;
@property (nonatomic,strong) NSArray* images;
@property (nonatomic,strong) NSArray*  paths;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     Do any additional setup after loading the view, typically from a nib.
    
    GAScrollViewConfiguration* q_config = [GAScrollViewConfiguration quickConfigurationTitleFontSize:14 titleColor:[UIColor whiteColor] pageSelectedColor:[UIColor orangeColor] style:GAScrollViewrRunStyleAutoAndSpringback transformStyle:GAScrollViewTransformStyleDefault];
    GAScrollView* q_scrollView = [GAScrollView scrollViewWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,200}} configuration:q_config titles:self.titles localImages:self.images netWorkIMGPaths:self.paths];
    [self.view addSubview:q_scrollView];

    
    GAScrollViewConfiguration* a_config = [GAScrollViewConfiguration instanceBannerConfigurationPlaceholderImage:nil orColor:@[[UIColor blackColor],[UIColor whiteColor]] needTitle:YES titleHeight:40 titleAlignment:NSTextAlignmentLeft titleFrame:CGRectZero andTitleFontName:nil andTitleFontSize:17 andTitleColor:[UIColor blackColor] needPage:YES whenOnlyHidden:YES pageAlignment:UIControlContentHorizontalAlignmentLeft pageFrame:CGRectZero andPageDefaultColor:[UIColor whiteColor] andPageSelectedColor:[UIColor orangeColor] needDiskCache:YES style:GAScrollViewrRunStyleAuto transformStyle:GAScrollViewTransformStyleDefault cacheScheme:GACacheImageScheme_AFNetworking timeInterval:5.0 openBounces:YES];
    GAScrollView* a_scrollView = [[GAScrollView alloc] initWithFrame:(CGRect){{0,self.view.bounds.size.height - 400},{self.view.bounds.size.width,400}}];
    a_scrollView.config = a_config;
    a_scrollView.titles = self.titles;
    a_scrollView.images = self.images;
    a_scrollView.paths  = self.paths;
    a_scrollView.delegate = self;
    [self.view addSubview:a_scrollView];
}

#pragma mark - GAScrollViewDelegate
- (void)scrollView:(GAScrollView *)scrollView willScrollFrom:(NSUInteger)from to:(NSUInteger)to{
    NSLog(@"%@ from:%lu,to:%lu",NSStringFromSelector(_cmd),(unsigned long)from,(unsigned long)to);
}
- (void)scrollView:(GAScrollView *)scrollView didScrollFrom:(NSUInteger)from to:(NSUInteger)to{
    NSLog(@"%@ from:%lu,to:%lu",NSStringFromSelector(_cmd),(unsigned long)from,(unsigned long)to);
}
- (void)scrollView:(GAScrollView *)scrollView currentClickIndex:(NSUInteger)index{
    NSLog(@"%@,%lu",NSStringFromSelector(_cmd),index);
}


#pragma mark - lazy load
- (NSArray *)titles{
    if (!_titles) {
        _titles = @[@"Adventure may hurt you, but monotony will kill you.",
                    @"No man or woman is worth your tears, and the one who is, won't make you cry.",
                    @"I am looking for the missing glass-shoes who has picked it up .",
                    @"If you weeped for the missing sunset,you would miss all the shining stars .",
                    ];
    }
    return _titles;
}
- (NSArray *)images{
    if (!_images) {
        _images = @[];
    }
    return _images;
}
- (NSArray *)paths{
    if (!_paths) {
        _paths = @[
                   @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1489663599898&di=c265b1369aed122d496d3e2a461e04b9&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201605%2F20160514004.jpg",
                   @"http://a1967.phobos.apple.com/us/r30/Purple2/v4/2e/39/a6/2e39a633-adfc-bbeb-061f-cc3c2771742b/mzl.zuvpuuhz.png",
                   @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=839485767,3294787873&fm=21&gp=0.jpg",
                   @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490409790&di=c08f6149f552253e81ff5b7d16cab171&imgtype=jpg&er=1&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201509%2F30%2F20150930182734_8Phmw.jpeg",
                   ];
    }
    return _paths;
}
@end
