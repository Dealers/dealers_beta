//
//  CommentsTableViewController.h
//  Dealers
//
//  Created by Gilad Lumbroso on 10/12/14.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CommentTableViewCell.h"
#import "ProfileTableViewController.h"
#import "Comment.h"
#import "Dealer.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface CommentsTableViewController : UITableViewController <UITextViewDelegate, MBProgressHUDDelegate> {
    
    MBProgressHUD *unableToPostComment;
}

@property AppDelegate *appDelegate;

@property NSMutableArray *comments;
@property Deal *deal;

@property BOOL isKeyboardReady;

@property UIView *textInputView;

@property UITextView *textView;
@property UILabel *placeholder;
@property UIButton *postButton;

@property BOOL didChanges;


@end
