//
//  NotificationTableViewCell.h
//  Dealers
//
//  Created by Gilad Lumbroso on 10/11/14.
//
//

#import <UIKit/UIKit.h>
#import "ElasticLabel.h"

@interface NotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *notificationImagePlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *notificationImage;
@property (weak, nonatomic) IBOutlet ElasticLabel *message;
@property (weak, nonatomic) IBOutlet UILabel *date;

+ (NSString *)notificationStringForObject:(id)object;

@end
