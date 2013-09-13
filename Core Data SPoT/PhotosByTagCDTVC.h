//
//  PhotosByTagCDTVC.h
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Tag.h"

@interface PhotosByTagCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Tag *tag;

@end
