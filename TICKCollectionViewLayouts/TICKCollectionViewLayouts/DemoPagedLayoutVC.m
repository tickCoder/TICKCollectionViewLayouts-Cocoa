//
//  DemoPagedLayoutVC.m
//  TICKCollectionViewLayouts
//
//  Created by Claris on 2016.10.02.
//  Copyright © 2016 Claris. All rights reserved.
//

#import "DemoPagedLayoutVC.h"
#import "TICKCollectionViewPagedLayout.h"
#import "DemoCollectionViewCell.h"

@interface DemoPagedLayoutVC () <UICollectionViewDataSource, UICollectionViewDelegate, TICKCollectionViewPagedLayoutDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *demoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *rowLabel;
@property (weak, nonatomic) IBOutlet UILabel *colLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *directionSwitch;
@property (weak, nonatomic) IBOutlet UISlider *rowSlider;
@property (weak, nonatomic) IBOutlet UISlider *colSlider;
@property (weak, nonatomic) IBOutlet UISlider *numSlider;
@property (nonatomic, strong) TICKCollectionViewPagedLayout *pagedLayout;

@property (nonatomic, assign) NSInteger rowNumber;
@property (nonatomic, assign) NSInteger colNumber;
@property (nonatomic, assign) NSInteger itemNumber;
@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, strong) NSMutableArray *itemList;
@property (nonatomic, strong) NSArray *itemColors;

@property (nonatomic, assign) BOOL useDelegate;
@end

@implementation DemoPagedLayoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view5
    self.automaticallyAdjustsScrollViewInsets = false;
    self.useDelegate = false;
    self.itemColors = @[[UIColor redColor], [UIColor cyanColor],
                        [UIColor blueColor],[UIColor greenColor],
                        [UIColor grayColor],[UIColor magentaColor],
                        [UIColor orangeColor],[UIColor purpleColor],
                        [UIColor yellowColor],[UIColor blackColor]];
    
    NSString *cellClassName = NSStringFromClass([DemoCollectionViewCell class]);
    UINib *cellNib = [UINib nibWithNibName:cellClassName bundle:nil];
    [_demoCollectionView registerNib:cellNib forCellWithReuseIdentifier:kDemoCollectionViewCellIdentifier];
    _demoCollectionView.dataSource = self;
    _demoCollectionView.delegate = self;
    _demoCollectionView.collectionViewLayout = self.pagedLayout;
    
    _rowSlider.minimumValue = 1;
    _rowSlider.maximumValue = 11;
    _rowSlider.value = _rowSlider.minimumValue;
    _rowNumber = 1;
    [self rowSliderAction:nil];
    
    _colSlider.minimumValue = 1;
    _colSlider.maximumValue = 11;
    _colSlider.value = _colSlider.minimumValue;
    _colNumber = 1;
    [self colSliderAction:nil];
    
    _numSlider.minimumValue = 0;
    _numSlider.maximumValue = 999;
    _numSlider.value = _numSlider.minimumValue;
    _itemNumber = 0;
    [self numSliderAction:nil];
    
    _directionSwitch.on = true;
    _isVertical = false;
    [self directionSwitchAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Response
- (IBAction)directionSwitchAction:(id)sender {
    _directionLabel.text = _directionSwitch.isOn?@"H":@"V";
    _isVertical = !_directionSwitch.isOn;
    if (!_useDelegate) {
        _pagedLayout.scrollDirection = _isVertical?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;
    }
}
- (IBAction)reloadBtnAction:(id)sender {
    // [_pagedLayout reloadLayoutAndView];
    [_demoCollectionView reloadData];
}
- (IBAction)rowSliderAction:(id)sender {
    _rowNumber = roundf(_rowSlider.value);
    _rowLabel.text = [NSString stringWithFormat:@"row: %ld", (long)_rowNumber];
    if (!_useDelegate) {
        _pagedLayout.numberOfRowsPerPage = _rowNumber;
    }
}
- (IBAction)colSliderAction:(id)sender {
    _colNumber = roundf(_colSlider.value);
    _colLabel.text = [NSString stringWithFormat:@"col: %ld", (long)_colNumber];
    if (!_useDelegate) {
        _pagedLayout.numberOfColumnsPerPage = _colNumber;
    }
}
- (IBAction)numSliderAction:(id)sender {
    _itemNumber = roundf(_numSlider.value);
    _numLabel.text = [NSString stringWithFormat:@"number: %ld", (long)_itemNumber];
    
    [self.itemList removeAllObjects];
    for (NSInteger i=0; i<_itemNumber; i++) {
        [_itemList addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    [_demoCollectionView reloadData];
}

#pragma mark - Setter & Getter
- (TICKCollectionViewPagedLayout *)pagedLayout {
    if (!_pagedLayout) {
        _pagedLayout = [[TICKCollectionViewPagedLayout alloc] init];
    }
    _pagedLayout.reloadAfterChange = true;
    if (_useDelegate) {
        _pagedLayout.delegate = self;
    } else {
        _pagedLayout.numberOfRowsPerPage = 1;
        _pagedLayout.numberOfColumnsPerPage = 1;
        _pagedLayout.marginBetweenRows = 5;
        _pagedLayout.marginBetweenColumns = 5;
        _pagedLayout.edgeInsetsOfPerPage = UIEdgeInsetsMake(5, 0, 0, 5);
        //_pagedLayout.pagingEnabled = false;
        _pagedLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _pagedLayout;
}

- (NSMutableArray *)itemList {
    if (!_itemList) {
        _itemList = [[NSMutableArray alloc] init];
    }
    return _itemList;
}

#pragma mark - <DataSource & Delegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DemoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDemoCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.indexLabel.text = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    cell.backgroundColor = self.itemColors[indexPath.row % (_colNumber + 1)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath:(%ld-%ld)", (long)indexPath.section, (long)indexPath.row);
}

#pragma mark - <TICKCollectionViewPagedLayoutDelegate>
- (NSInteger)numberOfRowsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return _rowNumber;
}

- (NSInteger)numberOfColumnsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return _colNumber;
}

- (CGFloat)marginBetweenRowsInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return 5;
}

- (CGFloat)marginBetweenColumnsInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return 5;
}

- (UIEdgeInsets)edgeInsetsPerPageInCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UICollectionViewScrollDirection)scrollDriectionOfCollectionView:(UICollectionView *)aCollectionView layout:(TICKCollectionViewPagedLayout *)aLayout {
    return _isVertical ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
}

@end
