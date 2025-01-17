//
//  NotificationTableViewCell.m
//  Dealers
//
//  Created by Gilad Lumbroso on 10/11/14.
//
//

#import "NotificationTableViewCell.h"
#import "Notification.h"
#import "Dealer.h"

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.notificationImagePlaceholder.layer.cornerRadius = self.notificationImagePlaceholder.frame.size.width / 2;
    self.notificationImagePlaceholder.layer.masksToBounds = YES;
    self.notificationImage.layer.cornerRadius = self.notificationImage.frame.size.width / 2;
    self.notificationImage.layer.masksToBounds = YES;
    self.notificationImage.imageView.contentMode = UIViewContentModeScaleAspectFill;

    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.baseWritingDirection = UITextWritingDirectionRightToLeft;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.message.text];
        [string addAttribute:NSParagraphStyleAttributeName
                       value:paragraphStyle
                       range:NSMakeRange(0, string.length)];
        
        self.message.attributedText = string;
    }
}

+ (NSString *)notificationStringForObject:(id)object
{
    if ([object isMemberOfClass:[Notification class]]) {
        
        Notification *notification = object;
        NSString *notificationString;

        if ([notification.type isEqualToString:@"Weekly Deals"]) {
            notificationString = NSLocalizedString(notification.subjectMessage, nil);
            return notificationString;
        }
        
        if ([notification.type isEqualToString:@"New Rank"]) {
            NSString *rank = NSLocalizedString(notification.subjectTitle, nil);
            notificationString = [NSString stringWithFormat:NSLocalizedString(@"Congratulations! You became a %@!", nil), rank];
            return notificationString;
        }
        
        NSString *fullName = notification.dealer.fullName;
        NSString *dealTitle = notification.subjectTitle;
        
        if ([notification.type isEqualToString:@"Like"]) {
            
            notificationString = NSLocalizedString(@"likes your deal", nil);
            
        } else if ([notification.type isEqualToString:@"Comment"]) {
            
            notificationString = NSLocalizedString(@"commented on your deal", nil);
            
        } else if ([notification.type isEqualToString:@"Also Commented"]) {
            
            notificationString = NSLocalizedString(@"also commented on the deal", nil);
            
        } else if ([notification.type isEqualToString:@"Share"]) {
            
            notificationString = NSLocalizedString(@"shared your deal", nil);
            
        } else if ([notification.type isEqualToString:@"Edit"]) {
            
            notificationString = NSLocalizedString(@"edited your deal", nil);
        }
        
        return [NSString stringWithFormat:@"%@ %@: \"%@\"", fullName, notificationString, dealTitle];
    
    
    } else {
        
        NSMutableArray *notificationsGroup = object;
        
        Notification *notification1 = [notificationsGroup objectAtIndex:0];
        Notification *notification2 = [notificationsGroup objectAtIndex:1];
        
        NSString *fullName1 = notification1.dealer.fullName;
        NSString *fullName2 = notification2.dealer.fullName;
        
        NSString *dealTitle = notification1.subjectTitle;
        NSString *notificationString;
        NSString *andSign = NSLocalizedString(@"&", nil);
        
        if ([notification1.type isEqualToString:@"Like"]) {
            
            notificationString = NSLocalizedString(@"like your deal", nil);
            
        } else if ([notification1.type isEqualToString:@"Comment"]) {
            
            notificationString = NSLocalizedString(@"commented on your deal", nil);
            if ([[[NSBundle mainBundle] preferredLocalizations].firstObject isEqualToString:@"he"]) {
                notificationString = @"הגיבו על המבצע שלך";
            }
            
        } else if ([notification1.type isEqualToString:@"Also Commented"]) {
            
            notificationString = NSLocalizedString(@"also commented on the deal", nil);
            if ([[[NSBundle mainBundle] preferredLocalizations].firstObject isEqualToString:@"he"]) {
                notificationString = @"גם הגיבו על המבצע";
            }
            
        } else if ([notification1.type isEqualToString:@"Share"]) {
            
            notificationString = NSLocalizedString(@"shared your deal", nil);
            if ([[[NSBundle mainBundle] preferredLocalizations].firstObject isEqualToString:@"he"]) {
                notificationString = @"שיתפו את המבצע שלך";
            }
            
        } else if ([notification1.type isEqualToString:@"Edit"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"There is a problem!", nil)
                                                            message:@"Notification of type \"Edit\" shouldn't be in a group."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        if (notificationsGroup.count == 2) {
            
            return [NSString stringWithFormat:@"%@ %@ %@ %@: \"%@\"", fullName1, andSign, fullName2, notificationString, dealTitle];
        
        } else if (notificationsGroup.count > 2) {
            
            return [NSString stringWithFormat:@"%@, %@ %@ %@ more people %@: \"%@\"", fullName1, fullName2, andSign, [NSNumber numberWithUnsignedInteger:notificationsGroup.count - 2], notificationString, dealTitle];
        }
    }
    
    return nil;
}

@end
