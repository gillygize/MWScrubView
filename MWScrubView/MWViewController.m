//
//  MWViewController.m
//  MWScrubCollectionVIew
//
//  Created by Matt on 7/9/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import "MWViewController.h"

@interface TestCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *label;
@end

@implementation TestCell
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:self.label];
  }

  return self;
}
@end

@interface MWViewController ()
@end

@implementation MWViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.sections = [[NSMutableArray alloc] initWithCapacity:3];

    NSMutableArray *row1 = [[NSMutableArray alloc] initWithCapacity:100];

    for (int i = 0; i < 100; i++) {
      [row1 addObject:@(i)];
    }

    [self.sections addObject:row1];

    [self.sections addObject:[[NSMutableArray alloc] init]];

    NSMutableArray *row3 = [[NSMutableArray alloc] initWithCapacity:100];

    for (int i = 0; i < 10; i++) {
      [row3 addObject:@(i)];
    }

    [self.sections addObject:row3];
  }

  return self;
}

- (void)viewDidLoad {
  [self.scrubView.collectionView registerClass:[TestCell class] forCellWithReuseIdentifier:@"test"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return ((NSArray *)self.sections[section]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  TestCell *cell = (TestCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"test" forIndexPath:indexPath];
  cell.backgroundColor = indexPath.item % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
  cell.label.text = [self.sections[indexPath.section][indexPath.item] stringValue];

  return cell;
}

- (MWScrubViewAttribute*)scrubView:(MWScrubView *)scrubView attributeForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSAttributedString *positionMarker = indexPath.item % 5 == 0 ? [[NSAttributedString alloc] initWithString:[self.sections[indexPath.section][indexPath.item] stringValue]] : nil;
  NSAttributedString *indicator = [[NSAttributedString alloc] initWithString:[self.sections[indexPath.section][indexPath.item] stringValue]];
  NSUInteger weight = indexPath.item % 5 == 0 ? 20 : 1;
  return [MWScrubViewAttribute attributeWithPositionMarker:positionMarker indicator:indicator weight:weight];
}

@end
