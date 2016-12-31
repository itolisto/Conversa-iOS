//
//  HomeViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/9/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "HomeViewController.h"

#import "Colors.h"
#import "UIStateButton.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface HomeViewController () <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIStateButton *loginButton;
@property (weak, nonatomic) IBOutlet UIStateButton *signupButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *clickHereLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add login button properties
    [self.loginButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[Colors green] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[Colors green] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    // Add sign up button properties
    [self.signupButton setBackgroundColor:[Colors green] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[Colors white] forState:UIControlStateNormal];
    [self.signupButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.signupButton setTitleColor:[Colors green] forState:UIControlStateHighlighted];

    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:self.clickHereLabel.text
                                                                                attributes:nil];

    NSString *language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    NSUInteger size = [self.clickHereLabel.text length];
    NSRange start, end;

    if ([language isEqualToString:@"es"]) {
        start = NSMakeRange(0, size - 13);
        end = NSMakeRange(size - 13, 13);
    } else {
        start = NSMakeRange(0, size - 10);
        end = NSMakeRange(size - 10, 10);
    }

    // Normal
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}
                     range:start];
    // Green
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[Colors green]}
                     range:end];
    // Active
    self.clickHereLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};

    NSURL *url = [NSURL URLWithString:@"http://en.wikipedia.org"];
    [self.clickHereLabel addLinkToURL:url withRange:end];
    self.clickHereLabel.attributedText = attrStr;
    self.clickHereLabel.delegate = self;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"%@", url);
}

@end
