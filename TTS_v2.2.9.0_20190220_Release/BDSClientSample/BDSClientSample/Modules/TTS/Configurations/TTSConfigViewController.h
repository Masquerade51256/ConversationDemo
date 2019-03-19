//
//  TTSConfigViewController.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCells/NavigationTableViewCell.h"
#import "TableViewCells/SliderTableViewCell.h"
#import "TableViewCells/InputTableViewCell.h"
#import "TableViewCells/SwitchTableViewCell.h"

@protocol SettingsViewControllerDelegate <NSObject>

-(void)enableSpeakChanged:(BOOL)enable;
-(void)enableFileSynthesisChanged:(BOOL)enable;

@end

@interface TTSConfigViewController : UITableViewController<SwitchTableViewCellDelegate,SliderTableViewCellDelegate,InputTableViewCellDelegate>
@property (nonatomic)BOOL isAudioSessionManagementEnabled;
@property (nonatomic,weak)id<SettingsViewControllerDelegate> configDelegate;
+(void)loadedAudioModelWithName:(NSString*)modelName forLanguage:(NSString*)language;

@end
