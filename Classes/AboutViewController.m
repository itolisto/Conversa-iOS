//
//  AboutViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 2/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - SFSafariViewControllerDelegate Methods -

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // Support
//        final String supportId = "E5ZE2sr0tx";
//        dbBusiness dbBusiness = ConversaApp.getInstance(this).getDB().isContact(supportId);
//
//        if (dbBusiness == null) {
//            final Context context = this;
//            new MaterialDialog.Builder(this)
//            .title(R.string.sett_help_dialog_title)
//            .content(R.string.sett_help_dialog_message)
//            .progress(true, 0)
//            .progressIndeterminateStyle(true)
//            .showListener(new DialogInterface.OnShowListener() {
//                @Override
//                public void onShow(final DialogInterface dialogInterface) {
//                    new SupportInfoTask(context, dialogInterface).execute(supportId);
//                }
//            })
//            .show();
//        } else {
//            Intent intent = new Intent(this, ActivityProfile.class);
//            intent.putExtra(Const.iExtraAddBusiness, false);
//            intent.putExtra(Const.iExtraBusiness, dbBusiness);
//            startActivity(intent);
//        }
//
//
//        
//
//        if (result == null) {
//            new MaterialDialog.Builder(context)
//            .title(R.string.sett_help_dialog_title)
//            .content(R.string.sett_help_dialog_message_error)
//            .positiveText(android.R.string.ok)
//            .positiveColorRes(R.color.black)
//            .onPositive(new MaterialDialog.SingleButtonCallback() {
//                @Override
//                public void onClick(@NonNull MaterialDialog dialog, @NonNull DialogAction which) {
//                    dialog.dismiss();
//                }
//            })
//            .show();
//        } else {
//            Intent intent = new Intent(context, ActivityProfile.class);
//            intent.putExtra(Const.iExtraAddBusiness, true);
//            intent.putExtra(Const.iExtraBusiness, result);
//            startActivity(intent);
//        }
//
//
//
//        try {
//            HashMap<String, Object> pparams = new HashMap<>(2);
//            pparams.put("customer", 1);
//            pparams.put("accountId", params[0]);
//            String json = ParseCloud.callFunction("getConversaAccount", pparams);
//            JSONObject businessReg = new JSONObject(json);
//
//            dbBusiness business = new dbBusiness();
//            business.setBusinessId(businessReg.getString("ob"));
//            business.setDisplayName(businessReg.getString("dn"));
//            business.setConversaId(businessReg.getString("cn"));
//            business.setAbout(businessReg.getString("ab"));
//            business.setAvatarThumbFileId(businessReg.getString("av"));
//
//            return business;
//        } catch (Exception e) {
//            if (e instanceof ParseException) {
//                if (AppActions.validateParseException((ParseException)e)) {
//                    AppActions.appLogout(getApplicationContext(), true);
//                }
//            }
//
//            return null;
//        }



    } else if (indexPath.row == 1) {
        // Feedback
        SFSafariViewController *svc = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://conversachat.com/feedback"] entersReaderIfAvailable:NO];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    } else {
        // Terms & Privacy
        SFSafariViewController *svc = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://conversachat.com/terms"] entersReaderIfAvailable:NO];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
