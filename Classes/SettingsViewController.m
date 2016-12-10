//
//  SettingsViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 11/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "SettingsViewController.h"

#import "Colors.h"
#import "Account.h"
#import "Utilities.h"
#import "SettingsKeys.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;

@end

@implementation SettingsViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    // Imagen redonda
    //self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
    //self.avatarImage.clipsToBounds = YES;
    if ([SettingsKeys getGender] == Female) {
        self.avatarImage.image = [UIImage imageNamed:@"ic_person_female"];
    } else {
        self.avatarImage.image = [UIImage imageNamed:@"ic_person"];
    }
    // Agregar borde
    //self.avatarImage.layer.borderWidth = 2.0f;
    //self.avatarImage.layer.borderColor = [Colors greenNavbarColor].CGColor;
    // Welcome
    self.helloLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"settings_home_profile_hi", nil), [SettingsKeys getDisplayName]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath section] == 3) {
        // Change status connection
        if ([indexPath row] == 0) {
            [self didSelectShareSetting:indexPath];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 1) {
        // Change status connection
    }
}

- (void)didSelectShareSetting:(NSIndexPath*)indexPath {
    NSString *textToShare = NSLocalizedString(@"settings_home_share_text", nil);
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.conversachat.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
