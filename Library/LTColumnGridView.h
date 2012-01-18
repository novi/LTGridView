//
//  LTColumnGridView.h
//  YomimonoApp1
//
//  Created by 伊藤 祐輔 on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTGridViewBase.h"

@interface LTColumnGridView : LTGridViewBase

@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSUInteger columnCount;
@property (nonatomic) CGFloat xSpace;
@property (nonatomic) CGFloat ySpace;

@end
