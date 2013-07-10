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

@property (strong, nonatomic) NSAttributedString *attributedText;
@property (nonatomic) NSRange range;

+ (instancetype)attributeWithAttributedText:(NSAttributedString*)attributedString
 weight:(NSUInteger)weight;
@end

@protocol MWScrubViewDataSource <UICollectionViewDataSource>
- (MWScrubViewAttribute*)scrubView:(MWScrubView *)scrubView attributeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MWScrubView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet id<MWScrubViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<UICollectionViewDelegateFlowLayout> delegate;
@end
