//
//  LTGridView.h
//  YomimonoApp1
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LTGridViewBase;

typedef UIView* (^LTGridViewViewDataBlock)(LTGridViewBase* selfView, NSUInteger itemIndex);

@interface LTGridViewBase : UIScrollView

@property (nonatomic) NSUInteger itemCount;
@property (nonatomic, copy) LTGridViewViewDataBlock viewData;
@property (nonatomic, assign) Class viewClass;

-(UIView*)dequeueReuseableView;

- (void)gridViewInit;
- (CGSize)gridViewContentSize;
- (CGRect)gridViewFrameWithIndex:(NSUInteger)index;
- (NSArray*)gridViewToShowIndexes;
- (NSUInteger)gridViewReuseableViewMaxCount;

@end
