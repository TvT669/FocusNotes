//
//  ViewController.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import <UIKit/UIKit.h>

@interface TimeVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)startTimer:(id)sender;
- (IBAction)pauseTimer:(id)sender;
- (IBAction)resetTimer:(id)sender;


@end

