//
//  MWScrubView.m
//  MWScrubCollectionVIew
//
//  Created by Matt on 7/9/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "MWScrubView.h"

@class MWScrubControlView;

@protocol MWScrubControlViewDelegate
- (void)scrubControlView:(MWScrubControlView*)controlView didScrubToRelativeYCoordinate:(CGFloat)yCoordinate;
@end

@interface MWScrubControlLabelAttribute : NSObject
@property (strong, nonatomic) NSAttributedString *attributedString;
@property (nonatomic) CGFloat relativeYCoordinate;
@end

@implementation MWScrubControlLabelAttribute
@end

@interface MWScrubControlView : UIView

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (weak, nonatomic) id<MWScrubControlViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *labelAttributes;

- (void)addAttributedText:(NSAttributedString*)attributedString atRelativeYCoordinate:(CGFloat)yCoordinate;

@end

@implementation MWScrubControlView

- (id)initWithFrame:(CGRect)frame delegate:(id<MWScrubControlViewDelegate>)delegate {
  if (self = [super initWithFrame:frame]) {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.delegate = delegate;
    self.labelAttributes = [[NSMutableArray alloc] init];
    [self addGestureRecognizer:self.panGesture];
  }
  return self;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer*)panGesture {
  CGPoint touchPosition = [panGesture locationInView:self];

  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged:
    case UIGestureRecognizerStateEnded:
      [self.delegate scrubControlView:self didScrubToRelativeYCoordinate:[self relativeYCoordinateForPoint:touchPosition]];
      break;
    default:
      break;
  }
}

- (CGFloat)relativeYCoordinateForPoint:(CGPoint)point {
  return MAX(point.y / self.bounds.size.height, 0.0f);
}

- (void)addAttributedText:(NSAttributedString*)attributedString atRelativeYCoordinate:(CGFloat)yCoordinate {
  MWScrubControlLabelAttribute *attribute = [[MWScrubControlLabelAttribute alloc] init];
  attribute.attributedString = attributedString;
  attribute.relativeYCoordinate = yCoordinate;
  [self.labelAttributes addObject:attribute];

  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

  [self.labelAttributes enumerateObjectsUsingBlock:^(MWScrubControlLabelAttribute *attribute, NSUInteger idx, BOOL *stop) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
      self.bounds.size.height * attribute.relativeYCoordinate,
      self.bounds.size.width,
      [attribute.attributedString size].height
    )];
    label.attributedText = attribute.attributedString;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
  }];
}

@end

@implementation MWScrubViewAttribute
+ (instancetype)attributeWithAttributedText:(NSAttributedString*)attributedString
 weight:(NSUInteger)weight {
  MWScrubViewAttribute *attribute = [[MWScrubViewAttribute alloc] init];
  attribute.attributedText = attributedString;
  attribute.range = NSMakeRange(0, weight);
  return attribute;
}
@end

@interface MWScrubView () <MWScrubControlViewDelegate>

@property (strong, nonatomic) MWScrubControlView *scrubControlView;
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
  [self setup];
}


- (void)setup {
  self.attributeSections = [[NSMutableArray alloc] init];
  self.totalWeight = 0;

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.sectionInset = UIEdgeInsetsMake(0.0f, 44.0f, 0.0f, 0.0f );
  layout.itemSize = CGSizeMake(self.bounds.size.width-(layout.sectionInset.left + 1), 44.0f);
  layout.minimumInteritemSpacing = 0.0f;
  layout.minimumLineSpacing = 0.0f;

  self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.collectionView.dataSource = self.dataSource;
  self.collectionView.delegate = self.delegate;
  [self addSubview:self.collectionView];

  self.scrubControlView = [[MWScrubControlView alloc] initWithFrame:CGRectMake(
    0.0f,
    0.0f,
    44.0f,
    self.bounds.size.height
  ) delegate: self];
  self.scrubControlView.backgroundColor = [UIColor yellowColor];
  self.autoresizesSubviews = YES;
  [self addSubview:self.scrubControlView];

  NSInteger numberOfSections = 1;

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

      if (nil != attribute.attributedText) {
        NSUInteger positionOfItem = [self positionOfItemAtIndexPath:indexPath];
        CGFloat relativeYCoordinate = (CGFloat)positionOfItem / self.totalWeight;
        NSLog(@"%d, %d, %f", positionOfItem, self.totalWeight, relativeYCoordinate);
        [self.scrubControlView addAttributedText:attribute.attributedText atRelativeYCoordinate:relativeYCoordinate];
      }
    }
  }
}

- (void)layoutSubviews {
  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width-layout.sectionInset.left, 44.0f);
  [self.collectionView.collectionViewLayout invalidateLayout];

  self.scrubControlView.frame = CGRectMake(
    0.0f,
    0.0f,
    44.0f,
    self.bounds.size.height
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

  [section enumerateObjectsAtIndexes:set options:0 usingBlock:^(MWScrubViewAttribute *attribute, NSUInteger idx, BOOL *stop) {
    sumOfWeights += attribute.range.length;
  }];

  return sumOfWeights;
}

#pragma mark - MWScrubControlViewDelegate
- (void)scrubControlView:(MWScrubControlView *)controlView didScrubToRelativeYCoordinate:(CGFloat)yCoordinate {
  NSUInteger position = floorf(yCoordinate * self.totalWeight);

  NSUInteger indexOfMatchingSection = [self.attributeSections indexOfObjectPassingTest:^BOOL(NSArray *array, NSUInteger idx, BOOL *stop) {
    if (array.count == 0) return NO;

    MWScrubViewAttribute *firstAttribute = array[0];
    MWScrubViewAttribute *lastAttribute = [array lastObject];

    if (position >= firstAttribute.range.location && position < (lastAttribute.range.location + lastAttribute.range.length)) {
      return YES;
    }

    return NO;
  }];

  NSUInteger indexOfMatchingItem = [self.attributeSections[indexOfMatchingSection] indexOfObjectPassingTest:^BOOL(MWScrubViewAttribute *attribute, NSUInteger idx, BOOL *stop) {
    return NSLocationInRange(position, attribute.range);
  }];

  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexOfMatchingItem inSection:indexOfMatchingSection];
  [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}
@end
