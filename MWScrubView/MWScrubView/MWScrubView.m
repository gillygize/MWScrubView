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

@interface MWIndicatorLabel : UILabel
@property (nonatomic) UIEdgeInsets edgeInsets;
@end

@implementation MWIndicatorLabel

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
  }
  return self;
}

- (void)drawTextInRect:(CGRect)rect {
  return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}
@end


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
@property (strong, nonatomic) MWIndicatorLabel *indicatorLabel;
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
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 55.0f, 0.0f, 0.0f );
    layout.itemSize = CGSizeMake(self.bounds.size.width-(layout.sectionInset.left + 1), 44.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.allowsSelection = YES;

    [self addSubview:self.collectionView];
  }
  
  self.collectionView.dataSource = self.dataSource;
  self.collectionView.delegate = self;

  self.scrubControlView = [[MWScrubControlView alloc] initWithFrame:CGRectMake(
    5.0f,
    5.0f,
    44.0f,
    self.bounds.size.height - 10.0f
  ) delegate: self];
  self.scrubControlView.layer.cornerRadius = 8.0f;
  self.scrubControlView.layer.shadowRadius = 4.0f;
  self.scrubControlView.layer.shadowOpacity = 1.0f;
  self.scrubControlView.layer.masksToBounds = NO;
  self.scrubControlView.backgroundColor = [UIColor
    colorWithRed:230.0f/255.0f
    green:230.0f/255.0f
    blue:230.0f/255.0f
    alpha:1.0f];
  [self addSubview:self.scrubControlView];

  self.indicatorLabel = [[MWIndicatorLabel alloc] initWithFrame:CGRectZero];
  self.indicatorLabel.backgroundColor = [UIColor
    colorWithRed:230.0f/255.0f
    green:230.0f/255.0f
    blue:230.0f/255.0f
    alpha:1.0f];
  self.indicatorLabel.edgeInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f);
  self.indicatorLabel.textColor = [UIColor darkGrayColor];
  self.indicatorLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0f];
  self.indicatorLabel.layer.shadowRadius = 4.0f;
  self.indicatorLabel.layer.shadowOpacity = 0.6f;
  self.indicatorLabel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.indicatorLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.indicatorLabel.layer.masksToBounds = NO;
  self.indicatorLabel.layer.borderWidth = 1.0f;
  self.indicatorLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
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

  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width-layout.sectionInset.left, layout.itemSize.height);
  [self.collectionView.collectionViewLayout invalidateLayout];

  self.scrubControlView.frame = CGRectMake(
    5.0f,
    5.0f,
    44.0f,
    self.bounds.size.height - 10.0f
  );
  [self.scrubControlView setNeedsLayout];
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
      atScrollPosition:UICollectionViewScrollPositionCenteredVertically
      animated:NO];

    MWScrubViewAttribute *attribute = self.attributeSections[indexPath.section][indexPath.item];
    self.indicatorLabel.attributedText = attribute.indicatorAttributedText;
    self.indicatorLabel.frame = CGRectMake(
      55.0f,
      yCoordinate * self.scrubControlView.bounds.size.height - 10.0f,
      100.0f,
      20.0f
    );
  }
}

- (CGRect)relativePositionOfIndicatorForScrubControlView:(MWScrubControlView *)controlView {
  if (self.collectionView.contentSize.height < 0.000000001) {
    return CGRectMake(0.0f, 0.0f, 1.0f, 0.0f);
  }

  return CGRectMake(
    0.0f,
    self.collectionView.contentOffset.y / self.collectionView.contentSize.height,
    1.0f,
    self.collectionView.bounds.size.height / self.collectionView.contentSize.height
  );
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.scrubControlView setNeedsLayout];

  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidScrollToTop:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewDidZoom:scrollView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return YES;

  return [self.delegate scrollViewShouldScrollToTop:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  if (![self.delegate respondsToSelector:_cmd]) return nil;

  return [self.delegate viewForZoomingInScrollView:scrollView];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
  if (![self.delegate respondsToSelector:_cmd]) return NO;

  return [self.delegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
  if (![self.delegate respondsToSelector:_cmd]) return;

  [self.delegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return YES;

  return [self.delegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return YES;

  return [self.delegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return YES;

  return [self.delegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return NO;

  return [self.delegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.sectionInset;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.minimumInteritemSpacing;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.minimumLineSpacing;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.footerReferenceSize;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.headerReferenceSize;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (![self.delegate respondsToSelector:_cmd]) return collectionViewLayout.itemSize;

  return [self.delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}


@end
