//
//  LTColumnGridView.h
//  LTGridView
//
//  Created by Yusuke Ito on 12/01/17.
//  Copyright 2012-13 Yusuke Ito
//  http://www.opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import "LTGridViewBase.h"

@interface LTColumnGridView : LTGridViewBase

@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSUInteger columnCount;
@property (nonatomic) CGFloat xSpace;
@property (nonatomic) CGFloat ySpace;

@end
