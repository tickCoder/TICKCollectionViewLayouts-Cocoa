//
//  TICKCollectionViewPagedLayout.h
//  TICKCollectionViewLayouts
//
//  Created by Claris on 2016.10.02.
//  Copyright © 2016 Claris. All rights reserved.
//

//TODO: 支持多个section(目前仅支持一个section)
//TODO: 支持DecorationView、SupplementaryView
//TODO: 支持重排序(附带拖放效果)

#import <UIKit/UIKit.h>

@class TICKCollectionViewPagedLayout;
@protocol TICKCollectionViewPagedLayoutDelegate <NSObject>
@required
/**
 *  每页中多少行，默认为1
 */
- (NSInteger)numberOfRowsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;

/**
 *  每页中多少列，默认为1
 */
- (NSInteger)numberOfColumnsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;

@optional
/**
 *  行间距，默认为0
 */
- (CGFloat)marginBetweenRowsInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;

/**
 *  列间距，默认为0
 */
- (CGFloat)marginBetweenColumnsInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;

/**
 *  每页上下左右空白，默认均为0
 */
- (UIEdgeInsets)edgeInsetsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;

/**
 *  滚动方向，默认为UICollectionViewScrollDirectionHorizontal
 */
- (UICollectionViewScrollDirection)scrollDriectionOfCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout;
@end

/**
 *  每页固定数目的item。目前仅支持一个section。
 */
@interface TICKCollectionViewPagedLayout : UICollectionViewLayout
@property (nonatomic, weak) id<TICKCollectionViewPagedLayoutDelegate> delegate;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;/**<默认为Horizontal*/
@property (nonatomic, assign) UIEdgeInsets edgeInsetsOfPerPage;/**<默认为(0,0,0,0)*/
@property (nonatomic, assign) CGFloat marginBetweenRows;/**<默认为0*/
@property (nonatomic, assign) CGFloat marginBetweenColumns;/**<默认为0*/
@property (nonatomic, assign) NSInteger numberOfRowsPerPage;/**<每页行数，默认1*/
@property (nonatomic, assign) NSInteger numberOfColumnsPerPage;/**<每页列数，默认1*/
@property (nonatomic, assign) BOOL pagingEnabled;/**<默认为YES*/
@property (nonatomic, assign) BOOL reloadAfterChange;/**<是否正设置属性后刷新，默认NO*/

@property (nonatomic, assign, readonly) NSInteger numberOfItems;/**<所有item个数，为CollectionView的DataSource的第0个section的item个数*/
@property (nonatomic, assign, readonly) CGSize contentSize;/**<根据其它因素计算而来*/
@property (nonatomic, assign, readonly) CGSize itemSize;/**<根据其它因素计算而来*/
@property (nonatomic, assign, readonly) NSInteger numberOfPages;/**<根据其它因素计算而来*/

/**
 *  刷新layout和CollectionView
 */
- (void)reloadLayoutAndView;
@end
