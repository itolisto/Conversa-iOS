//
//  CustomInfoCell.m
//  Conversa
//
//  Created by Edgar Gomez on 2/27/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "CustomInfoCell.h"

@implementation CustomInfoCell

- (void)awakeFromNib {
    // Initialization code
    // Automatically detect links when the label text is subsequently changed
    self.optionDescription.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
    self.optionDescription.delegate = self;
}

- (void)configureCellWith:(NSDictionary *)option {
    NSString *code = [option objectForKey:@"code"];
    self.optionTitle.text = [self getTitleFromCode:code defaultTitle:@"Ups..."];
    self.optionDescription.text = [option objectForKey:@"value"];

    NSRange range = NSMakeRange(0, [self.optionDescription.text length]);
    if ([code isEqualToString:@"01"]) {
        // Embedding a custom link in a substring
        [self.optionDescription addLinkToPhoneNumber:self.optionDescription.text withRange:range];
    } else if ([code isEqualToString:@"02"]) {
        // Embedding a custom link in a substring
        [self.optionDescription addLinkToAddress:@{@"address":self.optionDescription.text} withRange:range];
    } else if ([code isEqualToString:@"06"]) {
        // Embedding a custom link in a substring
        [self.optionDescription addLinkToURL:[NSURL URLWithString:self.optionDescription.text] withRange:range];
    }
}

- (NSString *)getTitleFromCode:(NSString *)code defaultTitle:(NSString *)title {
    if ([code isEqualToString:@"01"]) {
        return @"Teléfono";
    } else if ([code isEqualToString:@"02"]) {
        return @"Dirección";
    } else if ([code isEqualToString:@"03"]) {
        return @"Horario";
    } else if ([code isEqualToString:@"04"]) {
        return @"Cerrado los";
    } else if ([code isEqualToString:@"05"]) {
        return @"Servicio a domicilio";
    } else if ([code isEqualToString:@"06"]) {
        return @"Enlace";
    } else if ([code isEqualToString:@"07"]) {
        return @"Promoción especial";
    } else if ([code isEqualToString:@"08"]) {
        return @"Promoción del día";
    } else {
        return title;
    }
}

#pragma mark - TTTAttributedLabelDelegate Methods -

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithAddress:(NSDictionary *)addressComponents {
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        
        // Waze is installed. Launch Waze and start navigation
        NSString *urlStr =
        [NSString stringWithFormat:@"waze://?q=%@",
         [addressComponents objectForKey:@"address"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    } else {
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    phoneNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

@end
