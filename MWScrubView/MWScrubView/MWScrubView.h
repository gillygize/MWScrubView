//
//  MWScrubView.h
//  MWScrubCollectionVIew
//
//  Created by Matt on 7/9/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWScrubView.h"

@class MWScrubView;

@interface MWScrubViewAttribute : NSObject

@property (strong, nonatomic) NSAttributedString *positionAttributedText;
@property (strong, nonatomic) NSAttributedString *indicatorAttributedText;
@property (nonatomic) NSRange range;

+ (instancetype)attributeWithPositionMarker:(NSAttributedString*)positionAttributedText
 indicator:(NSAttributedString*)indicatorAttributedText
 weight:(NSUInteger)weight;
@end

@protocol MWScrubViewDataSource <UICollectionViewDataSource>
- (MWScrubViewAttribute*)scrubView:(MWScrubView *)scrubView attributeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MWScrubView : UIView
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet id<MWScrubViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<UICollectionViewDelegateFlowLayout> delegate;
@end
