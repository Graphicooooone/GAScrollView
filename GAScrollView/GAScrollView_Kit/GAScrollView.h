//
//  GAScrollView.h
//  GAScrollView
//
//  Created by Graphic-one on 17/3/12.
//  Copyright © 2017年 Graphic-one. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GAScrollView,GAScrollViewConfiguration;

NS_ASSUME_NONNULL_BEGIN

/** BannerScrollView cycle show the way */
typedef NS_ENUM(NSInteger,GAScrollViewrRunStyle){
    GAScrollViewrRunStyleAutoAndSpringback  = 0, //Automatic cycle display pictures and springback
    GAScrollViewrRunStyleAuto               = 1, //Single direction automatically round
    GAScrollViewrRunStyleNone               = -1,//Manual sliding banner
};

/** The GAScrollView transform style of animation Built in three styles at present */
typedef NS_ENUM(NSUInteger,GAScrollViewTransformStyle){
    GAScrollViewTransformStyleDefault       = 0,
    GAScrollViewTransformStyleTranslation   = 1,//is supporting ...
    GAScrollViewTransformStyleRotating      = 2,//is supporting ...
};

#pragma mark -

@protocol GAScrollViewDelegate <NSObject>
@optional
- (void)scrollView:(GAScrollView* )scrollView currentClickIndex:(NSUInteger)index;

- (void)scrollView:(GAScrollView* )scrollView willScrollFrom:(NSUInteger)from to:(NSUInteger)to;

- (void)scrollView:(GAScrollView* )scrollView didScrollFrom:(NSUInteger)from to:(NSUInteger)to;

@end

@interface GAScrollView : UIView

+ (instancetype)scrollViewWithFrame:(CGRect)frame
                      configuration:(GAScrollViewConfiguration* )config
                             titles:(nullable NSArray* )titles
                        localImages:(nullable NSArray* )images
                    netWorkIMGPaths:(nullable NSArray* )paths;

@property (nonnull,nonatomic,strong) GAScrollViewConfiguration* config;

@property (nullable,nonatomic,strong) NSArray* titles;

@property (nullable,nonatomic,strong) NSArray* images;

@property (nullable,nonatomic,strong) NSArray* paths;

@property (nonatomic,weak) id<GAScrollViewDelegate> delegate;

@end



typedef NS_ENUM(NSUInteger,GACacheImageScheme){
    GACacheImageScheme_YYImage      = 1,    ///< https://github.com/ibireme/YYImage
    GACacheImageScheme_SDWebImage   = 2,    ///< https://github.com/rs/SDWebImage
    GACacheImageScheme_AFNetworking = 3,    ///< https://github.com/AFNetworking/AFNetworking
    GACacheImageScheme_GAScrollView = 4,
    
    GACacheImageScheme_Auto         = 0,
    ///< According to the actual situation of your project choose ...
    ///< priority: YYImage > SDWebImage > AFNetworking > GAScrollView
    ///< Choose the reason is the decoding speed ...
};

#pragma mark -

/**
 *  BannerScrollViewConfiguration is in the service of "BannerScrollView" configuration model object .
 *  Use BannerScrollViewConfiguration (quickConfigurationTitleFontSize:) method can realize rapid configuration .
 *  Use BannerScrollViewConfiguration (instanceBannerConfigurationPlaceholderImage:) method implement a custom configuration .
 */

@interface GAScrollViewConfiguration : NSObject

+ (instancetype)quickConfigurationTitleFontSize:(CGFloat)fontSize
                                     titleColor:(UIColor* )titleColor
                              pageSelectedColor:(UIColor* )pageColor
                                          style:(GAScrollViewrRunStyle)style
                                 transformStyle:(GAScrollViewTransformStyle)transformStyle;


+ (instancetype)instanceBannerConfigurationPlaceholderImage:(nullable UIImage* ) placeholderImage
                                                    orColor:(nullable NSArray<UIColor* >* )colors
                                                  needTitle:(BOOL)isNeedTitle
                                                titleHeight:(CGFloat)titleHeight
                                             titleAlignment:(NSTextAlignment)titleAlignment
                                                 titleFrame:(CGRect)titleFrame
                                           andTitleFontName:(nullable NSString* )fontName
                                           andTitleFontSize:(CGFloat)fontSize
                                              andTitleColor:(nullable UIColor* )titleColor
                                                   needPage:(BOOL)isNeedPage
                                             whenOnlyHidden:(BOOL)whenOnlyHidden
                                              pageAlignment:(UIControlContentHorizontalAlignment)pageAlignment///< Cannot be designated as 'UIControlContentHorizontalAlignmentFill'
                                                  pageFrame:(CGRect)pageFrame
                                        andPageDefaultColor:(nullable UIColor* )defaultColor
                                       andPageSelectedColor:(UIColor* )selectedColor
                                              needDiskCache:(BOOL)isNeedDiskCache
                                                      style:(GAScrollViewrRunStyle)style
                                             transformStyle:(GAScrollViewTransformStyle)transformStyle
                                                cacheScheme:(GACacheImageScheme)cacheScheme
                                               timeInterval:(NSTimeInterval)timeInterval
                                                openBounces:(BOOL)isOpenBounces;

@property (nonatomic,assign) GAScrollViewTransformStyle transformStyle;

@property (nonatomic,assign) GAScrollViewrRunStyle style;

//@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;///< Default UIEdgeInsetsZero

@property (nonatomic,assign) GACacheImageScheme cacheScheme;///< Default is GACacheImageScheme_Auto

@property (nonatomic,assign) NSTimeInterval timeInterval;///< default is 1.0

@property (nonatomic,assign,getter=isOpenBounces) BOOL openBounces;///< default is YES

/** when value is nil using the "color" property as a gradient color */
@property (nonatomic,strong,nullable) UIImage* placeholderImage;///< default is nil
/** Priority is lower than "placeholderImage" property , Direction: from top to bottom */
@property (nonatomic,strong,nullable) NSArray<UIColor* >* colors;///< default is nil , used as a placeholder gradient background

///< title UI setting ...
@property (nonatomic,assign,getter=isNeedTitleLabel) BOOL needTitle;///< default is YES
@property (nonatomic,assign) CGRect titleFrame;///< default is CGRectZero, If the built-in titleHeight can't meet you can use this property to the custom
@property (nonatomic,assign) CGFloat titleHeight;///< default is 50px
@property (nonatomic,assign) NSTextAlignment titleAlignment;///< default is NSTextAlignmentLeft
@property (nonatomic,strong,nullable) NSString* fontName;///< default is nil , using System font
@property (nonatomic,assign) NSLineBreakMode lineBreakMode;///< default is NSLineBreakByTruncatingTail. used for single and multiple lines of text
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,strong) UIColor* titleColor;

///< pageController UI setting ...
@property (nonatomic,assign,getter=isNeedPageController) BOOL needPage;///< default is YES
@property (nonatomic,assign) BOOL whenOnlyHidden;///< default is YES
@property (nonatomic,assign) UIControlContentHorizontalAlignment pageAlignment;///< default is UIControlContentHorizontalAlignmentRight, Cannot UIControlContentHorizontalAlignmentFill assignment
@property (nonatomic,assign) CGRect pageFrame;///< default is CGRectZero, If the built-in alignment can't meet you can use this property to the custom
@property (nonatomic,strong,nullable) UIColor* defaultColor;///< default is white
@property (nonatomic,strong) UIColor* selectedColor;

@property (nonatomic,assign,getter=isNeedDiskCache) BOOL needDiskCache;///< default is YES

@end

NS_ASSUME_NONNULL_END

