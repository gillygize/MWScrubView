//
//  MWScrubView.m
//  MWScrubCollectionVIew
//
//  Created by Matt on 7/9/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "MWScrubView.h"
#import "MWScrubControlView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MWScrubViewAttribute
+ (instancetype)attributeWithPositionMarker:(NSAttributedString*)positionAttributedText
 indicator:(NSAttributedString*)indicatorAttributedText
 weight:(NSUInteger)weight {
  MWScrubViewAttribute *attribute = [[MWScrubViewAttribute alloc] init];
  attribute.positionAttributedText = positionAttributedText;
  attribute.indicatorAttributedText = indicatorAttributedText;
  attribute.range = NSMakeRange(0, weight);
  return attribute;
}
@end

@interface MWScrubView () <MWScrubControlViewDelegate>

@property (strong, nonatomic) MWScrubControlView *scrubControlView;
@property (strong, nonatomic) UILabel *indicatorLabel;
@property (strong, nonatomic) NSMutableArray *attributeSections;
@property (nonatomic) NSUInteger totalWeight;

@end

@implementation MWScrubView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  if (self) {
    [self setup];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setup];
}


- (void)setup {
  self.attributeSections = [[NSMutableArray alloc] init];

  if (!self.collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 44.0f, 0.0f, 0.0f );
    layout.itemSize = CGSizeMake(self.bounds.size.width-(layout.sectionInset.left + 1), 44.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
  }
  
  self.collectionView.dataSource = self.dataSource;
  self.collectionView.delegate = self.delegate;

  self.scrubControlView = [[MWScrubControlView alloc] initWithFrame:CGRectMake(
    0.0f,
    5.0f,
    44.0f,
    self.bounds.size.height - 10.0f
  ) delegate: self];
  self.scrubControlView.layer.cornerRadius = 8.0f;
  self.scrubControlView.layer.shadowRadius = 4.0f;
  self.scrubControlView.layer.shadowOpacity = 1.0f;
  self.scrubControlView.layer.masksToBounds = NO;
  self.scrubControlView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
  self.autoresizesSubviews = YES;
  [self addSubview:self.scrubControlView];

  self.indicatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.indicatorLabel.hidden = YES;
  [self addSubview:self.indicatorLabel];
  
  [self reloadData];
}

- (void)reloadData {
  [self.collectionView reloadData];

  NSInteger numberOfSections = 1;
  [self.attributeSections removeAllObjects];
  [self.scrubControlView clearAttributedText];
  self.totalWeight = 0;

  if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
    numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self.collectionView];
  }

  for (int i = 0; i < numberOfSections; i++) {
    NSInteger numberOfRows = [self.dataSource collectionView:self.collectionView numberOfItemsInSection:i];
    NSMutableArray *attributeRows = [[NSMutableArray alloc] init];

    for (int j = 0; j < numberOfRows; j++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
      MWScrubViewAttribute *attribute = [self.dataSource
        scrubView:self
        attributeForItemAtIndexPath:indexPath];
      attribute.range = NSMakeRange(self.totalWeight, attribute.range.length);

      self.totalWeight += attribute.range.length;
      [attributeRows addObject:attribute];
    }
    [self.attributeSections addObject:attributeRows];
  }

  for (int i = 0; i < self.attributeSections.count; i++) {
    NSArray *attributeSection = self.attributeSections[i];
    for (int j = 0; j < attributeSection.count; j++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
      MWScrubViewAttribute *attribute = attributeSection[j];

      if (nil != attribute.positionAttributedText) {
        NSUInteger positionOfItem = [self positionOfItemAtIndexPath:indexPath];
        CGFloat relativeYCoordinate = (CGFloat)positionOfItem / self.totalWeight;
        [self.scrubControlView addAttributedText:attribute.positionAttributedText atRelativeYCoordinate:relativeYCoordinate];
      }
    }
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width-layout.sectionInset.left, layout.itemSize.height);
  [self.collectionView.collectionViewLayout invalidateLayout];

  self.scrubControlView.frame = CGRectMake(
    0.0f,
    5.0f,
    44.0f,
    self.bounds.size.height - 10.0f
  );
}

- (NSUInteger)positionOfItemAtIndexPath:(NSIndexPath*)indexPath {
  __block NSUInteger position = 0;

  if (indexPath.section > 0) {  
    [self.attributeSections
      enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexPath.section-1)]
      options:0
      usingBlock:^(NSArray *array, NSUInteger idx, BOOL *stop) {
        position += [self
          sumOfWeightsForIndexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]
          inSection:array];
      }];
  }

  return position + [self
    sumOfWeightsForIndexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexPath.item)]
    inSection:self.attributeSections[indexPath.section]];
}

- (NSUInteger)sumOfWeightsForIndexSet:(NSIndexSet*)set inSection:(NSArray*)section {
  __block NSUInteger sumOfWeights = 0;

  [section
    enumerateObjectsAtIndexes:set
    options:0
    usingBlock:^(MWScrubViewAttribute *attribute, NSUInteger idx, BOOL *stop) {
      sumOfWeights += attribute.range.length;
    }];

  return sumOfWeights;
}

- (NSIndexPath*)indexPathForPosition:(NSUInteger)position {
  NSUInteger indexOfMatchingSection = [self.attributeSections
    indexOfObjectPassingTest:^BOOL(NSArray *array, NSUInteger idx, BOOL *stop) {
      if (array.count == 0) return NO;

      MWScrubViewAttribute *firstAttribute = array[0];
      MWScrubViewAttribute *lastAttribute = [array lastObject];

      if (position >= firstAttribute.range.location &&
       position < (lastAttribute.range.location + lastAttribute.range.length)) {
        return YES;
      }

      return NO;
    }];

  if (NSNotFound == indexOfMatchingSection) {
    return nil;
  }

  NSUInteger indexOfMatchingItem = [self.attributeSections[indexOfMatchingSection]
    indexOfObjectPassingTest:^BOOL(MWScrubViewAttribute *attribute, NSUInteger idx, BOOL *stop) {
      return NSLocationInRange(position, attribute.range);
    }];

  if (NSNotFound == indexOfMatchingItem) {
    return nil;
  }
  
  return [NSIndexPath indexPathForItem:indexOfMatchingItem inSection:indexOfMatchingSection];
}

#pragma mark - MWScrubControlViewDelegate
- (void)scrubControlViewDidBeginScrubbing:(MWScrubControlView *)controlView {
  self.indicatorLabel.hidden = NO;
}

- (void)scrubControlViewDidEndScrubbing:(MWScrubControlView *)controlView {
  self.indicatorLabel.hidden = YES;
}

- (void)scrubControlView:(MWScrubControlView *)controlView didScrubToRelativeYCoordinate:(CGFloat)yCoordinate {
  NSUInteger position = floorf(yCoordinate * self.totalWeight);
  NSIndexPath *indexPath = [self indexPathForPosition:position];
  
  if (indexPath) {
    [self.collectionView
      scrollToItemAtIndexPath:indexPath
      atScrollPosition:UICollectionViewScrollPositionTop
      animated:NO];

    MWScrubViewAttribute *attribute = self.attributeSections[indexPath.section][indexPath.item];
    self.indicatorLabel.attributedText = attribute.indicatorAttributedText;
    self.indicatorLabel.center = CGPointMake(46.0f, yCoordinate * self.scrubControlView.bounds.size.height);
    [self.indicatorLabel sizeToFit];
  }
}
@end
