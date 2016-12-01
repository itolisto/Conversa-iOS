//
//  CustomCategoryHeaderCell.m
//  Conversa
//
//  Created by Edgar Gomez on 11/12/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "CustomCategoryHeaderCell.h"

#import "nHeaderTitle.h"

@interface CustomCategoryHeaderCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation CustomCategoryHeaderCell

- (void)configureCellWith:(nHeaderTitle *)header {
    self.nameLabel.text = [header getHeaderName];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end