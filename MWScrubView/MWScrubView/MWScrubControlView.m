//
//  MWScrubControlView.m
//  MWScrubCollectionView
//
//  Created by Matt on 7/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "MWScrubControlView.h"
#import <QuartzCore/QuartzCore.h>

@interface MWScrubControlLabelAttribute : NSObject
@property (strong, nonatomic) NSAttributedString *attributedString;
@property (nonatomic) CGFloat relativeYCoordinate;
@property (nonatomic, weak) UILabel *label;
@end

@implementation MWScrubControlLabelAttribute
@end

@interface MWScrubControlView ()
@property (strong, nonatomic) NSMutableArray *labelAttributes;
@end

@implementation MWScrubControlView

- (id)initWithFrame:(CGRect)frame delegate:(id<MWScrubControlViewDelegate>)delegate {
  if (self = [super initWithFrame:frame]) {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGesture];

    self.delegate = delegate;
    self.labelAttributes = [[NSMutableArray alloc] init];

    self.positionIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.positionIndicatorView.backgroundColor = [UIColor lightGrayColor];
    self.positionIndicatorView.layer.cornerRadius = 8.0f;
    self.positionIndicatorView.layer.masksToBounds = NO;

    [self addSubview:self.positionIndicatorView];
  }
  return self;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer*)panGesture {
  CGPoint touchPosition = [panGesture locationInView:self];

  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
      [self.delegate scrubControlViewDidBeginScrubbing:self];
      break;
    case UIGestureRecognizerStateChanged:
      [self.delegate
        scrubControlView:self
        didScrubToRelativeYCoordinate:[self relativeYCoordinateForPoint:touchPosition]];
      break;
    case UIGestureRecognizerStateEnded:
      [self.delegate scrubControlViewDidEndScrubbing:self];
      break;
    default:
      break;
  }
}

- (CGFloat)relativeYCoordinateForPoint:(CGPoint)point {
  return MIN(1.0, MAX(point.y / self.bounds.size.height, 0.0f));
}

- (void)addAttributedText:(NSAttributedString*)attributedString atRelativeYCoordinate:(CGFloat)yCoordinate {
  MWScrubControlLabelAttribute *attribute = [[MWScrubControlLabelAttribute alloc] init];
  attribute.attributedString = attributedString;
  attribute.relativeYCoordinate = yCoordinate;
  [self.labelAttributes addObject:attribute];

  [self setNeedsLayout];
}

- (void)clearAttributedText {
  [self.labelAttributes enumerateObjectsUsingBlock:^(MWScrubControlLabelAttribute *attribute, NSUInteger idx, BOOL *stop) {
    [attribute.label removeFromSuperview];
  }];

  [self.labelAttributes removeAllObjects];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [self.labelAttributes
    enumerateObjectsUsingBlock:^(MWScrubControlLabelAttribute *attribute, NSUInteger idx, BOOL *stop) {
      UILabel *label = attribute.label;
      CGFloat height = [attribute.attributedString size].height;
      CGRect labelFrame = CGRectMake(
        0.0f,
        self.bounds.origin.y + self.bounds.size.height * attribute.relativeYCoordinate - height * attribute.relativeYCoordinate,
        self.bounds.size.width,
        height
      );

      if (nil == label) {
        label = [[UILabel alloc] initWithFrame:labelFrame];
        label.attributedText = attribute.attributedString;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0f];
        label.textAlignment = NSTextAlignmentCenter;
        attribute.label = label;
        [self addSubview:label];
      } else {
        label.frame = labelFrame;
      }
  }];

  CGRect relativePositionOfIndicatorView = [self.delegate relativePositionOfIndicatorForScrubControlView:self];

  CGFloat yPosition = MAX(
    self.bounds.origin.y + 2.0f,
    self.bounds.origin.y + relativePositionOfIndicatorView.origin.y * self.bounds.size.height
  );
  
  CGFloat height = relativePositionOfIndicatorView.size.height * self.bounds.size.height;

  if (relativePositionOfIndicatorView.origin.y < 0) {
    height -= fabsf(relativePositionOfIndicatorView.origin.y * self.bounds.size.height);
  }
  
  if (relativePositionOfIndicatorView.origin.y + relativePositionOfIndicatorView.size.height >= 0.999999f) {
    height -= (relativePositionOfIndicatorView.origin.y + relativePositionOfIndicatorView.size.height - 1.0f) * self.bounds.size.height + 2.0f;
  }

  self.positionIndicatorView.frame = CGRectMake(
    relativePositionOfIndicatorView.origin.x * self.bounds.size.width + 2.0f,
    yPosition,
    relativePositionOfIndicatorView.size.width * self.bounds.size.width - 4.0f,
    height
  );
}

@end

