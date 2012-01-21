//
//  LTGridView.h
//  YomimonoApp1
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kLTGridViewBackgroundDebug (0)
#define kLTGridViewLogDebug (0)

@class LTGridViewBase;


@protocol LTGridViewDelegate <NSObject>

@required
- (NSUInteger)gridViewItemCount:(LTGridViewBase*)gridView;
- (UIView*)gridView:(LTGridViewBase*)gridView viewForItemIndex:(NSUInteger)index;

@optional
- (void)gridViewLayoutSubviews:(LTGridViewBase*)gridView;

@end

@interface LTGridViewBase : UIScrollView

@property (nonatomic, assign) Class viewClass;
@property (nonatomic) BOOL layoutSubviewsEnabled;
@property (nonatomic, assign) id<LTGridViewDelegate> gridViewDelegate;
@property (nonatomic, readonly) NSUInteger itemCount;

- (void)itemCountUpdated;
- (UIView*)dequeueReuseableView;
- (NSArray*)visibleViews;

// for subclass overriding
- (void)gridViewInit;
- (CGSize)gridViewContentSize;
- (CGRect)gridViewFrameWithIndex:(NSUInteger)index;
- (NSArray*)gridViewToShowIndexes;
- (NSUInteger)gridViewReuseableViewMaxCount;

@end
