//
//  LTGridView.h
//  LTGridView
//
//  Created by Yusuke Ito on 12/01/17.
//  Copyright 2012-13 Yusuke Ito
//  http://www.opensource.org/licenses/MIT
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
- (void)gridView:(LTGridViewBase*)gridView deleteButtonTappedWithIndex:(NSUInteger)index;

@end

@interface LTGridViewBase : UIScrollView

@property (nonatomic, assign) Class viewClass; // you can not use UIButton and its subclass
@property (nonatomic) BOOL layoutSubviewsEnabled;
@property (nonatomic, assign) id<LTGridViewDelegate> gridViewDelegate;
@property (nonatomic, readonly) NSUInteger itemCount;
@property (nonatomic) BOOL editing;

- (void)reloadData;
- (UIView*)dequeueReuseableView;
- (NSArray*)visibleViews;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)reloadDataWithIndex:(NSUInteger)index;

// for subclass overriding
- (void)gridViewInit;
- (CGSize)gridViewContentSize;
- (CGRect)gridViewFrameWithIndex:(NSUInteger)index;
- (NSArray*)gridViewToShowIndexes;
- (NSUInteger)gridViewReuseableViewMaxCount;

@end
