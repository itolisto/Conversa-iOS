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

    if ([SettingsKeys getGender] == Female) {
        self.avatarImage.image = [UIImage imageNamed:@"ic_person_female"];
    } else {
        self.avatarImage.image = [UIImage imageNamed:@"ic_person"];
    }

    // Welcome
    self.helloLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"settings_home_profile_hi", nil), [SettingsKeys getDisplayName]];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:customerDisplayName
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:customerDisplayName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
    if (keyPath == nil || change == nil || [keyPath length] == 0 || [change count] == 0) {
        return;
    }

    if ([change valueForKey:NSKeyValueChangeNewKey] == nil) {
        return;
    }

    if ([keyPath isEqualToString:customerDisplayName]) {
        self.helloLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"settings_home_profile_hi", nil), [SettingsKeys getDisplayName]];
    }
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if([indexPath section] == 3) {
        // Change status connection
        if ([indexPath row] == 0) {
            [self didSelectShareSetting:indexPath];
        }
    }
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
