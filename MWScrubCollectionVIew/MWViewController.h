//
//  MWViewController.h
//  MWScrubCollectionVIew
//
//  Created by Matt on 7/9/13.
//  Copyright (c) 2013 Matthew Gillingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWScrubView.h"

@interface MWViewController : UIViewController <MWScrubViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet MWScrubView *scrubView;
@property (strong, nonatomic) NSMutableArray *sections;

@end
