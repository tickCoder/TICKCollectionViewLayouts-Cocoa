//
//  TICKCollectionViewPagedLayout.m
//  TICKCollectionViewLayouts
//
//  Created by Claris on 2016.10.02.
//  Copyright © 2016 Claris. All rights reserved.
//

#import "TICKCollectionViewPagedLayout.h"

@interface TICKCollectionViewPagedLayout ()
@property (nonatomic, assign, readwrite) NSInteger numberOfItems;
@property (nonatomic, assign, readwrite) CGSize contentSize;
@property (nonatomic, assign, readwrite) CGSize itemSize;
@property (nonatomic, assign, readwrite) NSInteger numberOfPages;

@property (nonatomic, assign) NSInteger maxNumberOfItemsPerPage;/**<每页最多有多少个item*/
@end

@implementation TICKCollectionViewPagedLayout
@synthesize pagingEnabled = _pagingEnabled;

#pragma mark - Override
- (instancetype)init {
    self = [super init];
    if (self) {
        _numberOfRowsPerPage = 1;
        _numberOfColumnsPerPage = 1;
        _edgeInsetsOfPerPage = UIEdgeInsetsMake(0, 0, 0, 0);
        _marginBetweenRows = 0;
        _marginBetweenColumns = 0;
        _scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _pagingEnabled = true;
        _reloadAfterChange = false;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSAssert(self.collectionView.dataSource, @"please set collectionView's dataSource");
    
    // 获取delegate设置的值
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfRowsPerPageInCollectionView:layout:)]) {
        _numberOfRowsPerPage = [_delegate numberOfRowsPerPageInCollectionView:self.collectionView layout:self];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfColumnsPerPageInCollectionView:layout:)]) {
        _numberOfColumnsPerPage = [_delegate numberOfColumnsPerPageInCollectionView:self.collectionView layout:self];
    }
    
    _maxNumberOfItemsPerPage = _numberOfRowsPerPage * _numberOfColumnsPerPage;
    NSAssert(_maxNumberOfItemsPerPage > 0, @"numberOfRowsPerPage and numberOfColumnsPerPage should equal or bigger than 0");
    
    _numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    _numberOfPages = (NSInteger)ceilf((float)_numberOfItems / (float)_maxNumberOfItemsPerPage);
    
    if ([_delegate respondsToSelector:@selector(edgeInsetsPerPageInCollectionView:layout:)]) {
        _edgeInsetsOfPerPage = [_delegate edgeInsetsPerPageInCollectionView:self.collectionView layout:self];
    }
    
    if ([_delegate respondsToSelector:@selector(marginBetweenRowsInCollectionView:layout:)]) {
        _marginBetweenRows = [_delegate marginBetweenRowsInCollectionView:self.collectionView layout:self];
    }
    
    if ([_delegate respondsToSelector:@selector(marginBetweenColumnsInCollectionView:layout:)]) {
        _marginBetweenColumns = [_delegate marginBetweenColumnsInCollectionView:self.collectionView layout:self];
    }
    
    // 计算每个item的大小(item大小一致)
    CGFloat pageWidthValid = self.collectionView.frame.size.width;
    pageWidthValid -= (_edgeInsetsOfPerPage.left + _edgeInsetsOfPerPage.right);
    pageWidthValid -= ((_numberOfColumnsPerPage - 1.0) * _marginBetweenColumns);
    
    CGFloat pageHeightValid = self.collectionView.frame.size.height;
    pageHeightValid -= (_edgeInsetsOfPerPage.top + _edgeInsetsOfPerPage.bottom);
    pageHeightValid -= ((_numberOfRowsPerPage - 1.0) * _marginBetweenRows);
    
    // ceil(
    CGFloat itemWidth = pageWidthValid / (CGFloat)_numberOfColumnsPerPage;
    CGFloat itemHeight = pageHeightValid / (CGFloat)_numberOfRowsPerPage;
    _itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // 获取滑动方向
    if ([_delegate respondsToSelector:@selector(scrollDriectionOfCollectionView:layout:)]) {
        _scrollDirection = [_delegate scrollDriectionOfCollectionView:self.collectionView layout:self];
        NSAssert(_scrollDirection == UICollectionViewScrollDirectionVertical || _scrollDirection==UICollectionViewScrollDirectionHorizontal , @"please set a correct UICollectionViewScrollDirection");
    }
    
    self.collectionView.pagingEnabled = _pagingEnabled;
}

- (CGSize)collectionViewContentSize {
    CGSize size = self.collectionView.bounds.size;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        size.width = (CGFloat)_numberOfPages * size.width;
    } else if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
        size.height = (CGFloat)_numberOfPages * size.height;
    }
    _contentSize = size;
    return size;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (_numberOfPages == 0)  return nil;
    
    NSMutableArray *itemAttrsList = [NSMutableArray array];
    NSArray *visibleIndexPaths = [self _tick_indexPathsOfItemsInRect:rect];
    for (NSInteger i=0; i<visibleIndexPaths.count; i++) {
        @autoreleasepool {
            NSIndexPath *indexPath = visibleIndexPaths[i];
            UICollectionViewLayoutAttributes *itemAttrs = [self layoutAttributesForItemAtIndexPath:indexPath];
            [itemAttrsList addObject:itemAttrs];
        }
    }
    //TODO: decorationView & supplymentViews
    return itemAttrsList;
}

// 确定frame
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat marginWidth = _edgeInsetsOfPerPage.left + _edgeInsetsOfPerPage.right + (_numberOfColumnsPerPage-1.0)*_marginBetweenColumns;
    CGFloat marginHeight = _edgeInsetsOfPerPage.top + _edgeInsetsOfPerPage.bottom + (_numberOfRowsPerPage-1.0)*_marginBetweenRows;
    CGFloat itemWidth = (self.collectionView.frame.size.width - marginWidth) / _numberOfColumnsPerPage;
    CGFloat itemHeight = (self.collectionView.frame.size.height - marginHeight) / _numberOfRowsPerPage;
    
    NSInteger pageIndex = (NSInteger)floor((double)indexPath.row / (double)_maxNumberOfItemsPerPage);// indexPath所在的pageIndex
    NSInteger indexInPage = indexPath.row % _maxNumberOfItemsPerPage;// indexPath所在的item在页内的index
    NSInteger colIndex = indexInPage % _numberOfColumnsPerPage;//决定x值
    NSInteger rowIndex = indexInPage / _numberOfColumnsPerPage;//决定y值
    CGFloat originX = _edgeInsetsOfPerPage.left + colIndex * itemWidth + colIndex * _marginBetweenColumns;
    CGFloat originY = _edgeInsetsOfPerPage.top + rowIndex * itemHeight + rowIndex * _marginBetweenRows;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat pageWidth = self.collectionView.frame.size.width;
        originX += pageIndex * pageWidth;
    } else if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat pageHeight = self.collectionView.frame.size.height;
        originY += pageIndex * pageHeight;
    }
    
    CGRect itemRect = CGRectZero;
    itemRect.origin.x = originX;
    itemRect.origin.y = originY;
    itemRect.size.width = itemWidth;
    itemRect.size.height = itemHeight;
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = itemRect;
    return attrs;
}


// iOS9.0+
- (NSIndexPath *)targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath withPosition:(CGPoint)position NS_AVAILABLE_IOS(9_0) {
    // 从position计算出targetIndexPath
    NSIndexPath *indexPath = [super targetIndexPathForInteractivelyMovingItem:previousIndexPath withPosition:position];
    // NSLog(@"target: %ld->%ld, %@", (long)previousIndexPath.row, (long)indexPath.row, NSStringFromCGPoint(position));
    return indexPath;
}

// iOS9.0+
- (UICollectionViewLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position NS_AVAILABLE_IOS(9_0) {
    return [super layoutAttributesForInteractivelyMovingItemAtIndexPath:indexPath withTargetPosition:position];
}

// iOS9.0+
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition NS_AVAILABLE_IOS(9_0) {
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForInteractivelyMovingItems:targetIndexPaths withTargetPosition:targetPosition previousIndexPaths:previousIndexPaths previousPosition:previousPosition];
    //[self.collectionView.dataSource collectionView:self.collectionView moveItemAtIndexPath:previousIndexPaths[0] toIndexPath:targetIndexPaths[0]];
    return context;
}

// iOS9.0+
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled NS_AVAILABLE_IOS(9_0) {
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:indexPaths previousIndexPaths:previousIndexPaths movementCancelled:movementCancelled];
    return context;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (CGRectEqualToRect(self.collectionView.bounds, newBounds)) {
        return NO;
    }
    return YES;
}

#pragma mark - Public
- (void)reloadLayoutAndView {
    [self invalidateLayout];
    [self.collectionView reloadData];
}

#pragma mark - Setter & Getter
- (BOOL)pagingEnabled {
    _pagingEnabled = self.collectionView.pagingEnabled;
    return _pagingEnabled;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    self.collectionView.pagingEnabled = _pagingEnabled;
    if (_reloadAfterChange) {
        [self.collectionView reloadData];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (void)setNumberOfRowsPerPage:(NSInteger)numberOfRowsPerPage {
    NSAssert(numberOfRowsPerPage > 0, @"numberOfRowsPerPage should >= 1");
    _numberOfRowsPerPage = numberOfRowsPerPage;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (void)setNumberOfColumnsPerPage:(NSInteger)numberOfColumnsPerPage {
    NSAssert(numberOfColumnsPerPage > 0, @"numberOfColumnsPerPage should >= 1");
    _numberOfColumnsPerPage = numberOfColumnsPerPage;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (void)setEdgeInsetsOfPerPage:(UIEdgeInsets)edgeInsetsOfPerPage {
    _edgeInsetsOfPerPage = edgeInsetsOfPerPage;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (void)setMarginBetweenRows:(CGFloat)marginBetweenRows {
    _marginBetweenRows = marginBetweenRows;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

- (void)setMarginBetweenColumns:(CGFloat)marginBetweenColumns {
    _marginBetweenColumns = marginBetweenColumns;
    if (_reloadAfterChange) {
        [self invalidateLayout];
        [self.collectionView reloadData];
    }
}

#pragma mark - Private
/**
 *  返回在指定区域rect内可见的item的indexPath
 */
- (NSArray <__kindof NSIndexPath *> *)_tick_indexPathsOfItemsInRect:(CGRect)rect {
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    // 防止越界
    if (rect.origin.x < 0) rect.origin.x = 0;
    if (rect.origin.y < 0) rect.origin.y = 0;
    
    // 确定页起始的pageIndex
    NSInteger pageIndex_start = 0;
    NSInteger pageIndex_end = 0;
    if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat pageWidth = self.collectionView.frame.size.width;
        pageIndex_start = (NSInteger)floor(CGRectGetMinX(rect) / pageWidth);
        pageIndex_end = (NSInteger)floor(CGRectGetMaxX(rect) / pageWidth);
    } else if (_scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat pageHeight = self.collectionView.frame.size.height;
        pageIndex_start = (NSInteger)floor(CGRectGetMinY(rect) / pageHeight);
        pageIndex_end = (NSInteger)floor(CGRectGetMaxY(rect) / pageHeight);
    }
    
    // 在rect前有多少个item
    NSInteger numberOfItemsBeforeStartPage = _maxNumberOfItemsPerPage * pageIndex_start;
    // 直到rect终点有多少item
    NSInteger numberOfItemsUntilEndPage = _maxNumberOfItemsPerPage * (pageIndex_end+1);
    // 如果计算出的item比实际多，修正item数目
    if (numberOfItemsUntilEndPage > _numberOfItems) {
        numberOfItemsUntilEndPage = _numberOfItems;
    }
    for (NSInteger j=numberOfItemsBeforeStartPage; j<numberOfItemsUntilEndPage; j++) {
        @autoreleasepool {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:0];
            [indexPaths addObject:indexPath];
        }
    }
    //NSLog(@"visible page: [%ld, %ld]", (long)pageIndex_start, (long)pageIndex_end);
    return indexPaths;
}


@end
