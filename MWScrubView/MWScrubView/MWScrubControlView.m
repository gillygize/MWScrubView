//
//  MWScrubControlView.m
//  MWScrubCollectionView
//
//  Created by Matt on 7/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "MWScrubControlView.h"

@interface MWScrubControlLabelAttribute : NSObject
@property (strong, nonatomic) NSAttributedString *attributedString;
@property (nonatomic) CGFloat relativeYCoordinate;
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

- (void)layoutSubviews {
  [super layoutSubviews];

  [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

  [self.labelAttributes
    enumerateObjectsUsingBlock:^(MWScrubControlLabelAttribute *attribute, NSUInteger idx, BOOL *stop) {
      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
        self.bounds.size.height * attribute.relativeYCoordinate,
        self.bounds.size.width,
        [attribute.attributedString size].height
      )];
      label.attributedText = attribute.attributedString;
      label.backgroundColor = [UIColor clearColor];
      label.textColor = [UIColor darkGrayColor];
      label.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0f];
      [self addSubview:label];
    }];
}

@end

