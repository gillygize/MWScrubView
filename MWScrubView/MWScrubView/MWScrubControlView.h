//
//  MWScrubControlView.h
//  MWScrubCollectionView
//
//  Created by Matt on 7/10/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWScrubControlView;

@protocol MWScrubControlViewDelegate
- (void)scrubControlViewDidBeginScrubbing:(MWScrubControlView*)controlView;
- (void)scrubControlViewDidEndScrubbing:(MWScrubControlView*)controlView;
- (void)scrubControlView:(MWScrubControlView*)controlView didScrubToRelativeYCoordinate:(CGFloat)yCoordinate;
@end

@interface MWScrubControlView : UIView

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (weak, nonatomic) id<MWScrubControlViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<MWScrubControlViewDelegate>)delegate;
- (void)addAttributedText:(NSAttributedString*)attributedString atRelativeYCoordinate:(CGFloat)yCoordinate;

@end
