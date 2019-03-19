//
//  ViewController.h
//  TTSDemo
//
//  Created by lappi on 3/8/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDSSpeechSynthesizerDelegate.h"
#import "BDS_EttsModelManagerInterface.h"
#import "BDSTTSEventManager.h"

@interface TTSViewController : UIViewController<UITextViewDelegate,BDSSpeechSynthesizerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *SynthesizeTextInputView;
@property (weak, nonatomic) IBOutlet UITextView *SynthesizeTextProgressView;
@property (weak, nonatomic) IBOutlet UIButton *SynthesizeButton;
- (IBAction)SynthesizeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *PauseOrResumeButton;
- (IBAction)PauseOrResumeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *CancelButton;
- (IBAction)CancelTapped:(id)sender;
- (IBAction)DismissKeyboard:(id)sender;
- (IBAction)DismissTTS:(id)sender;

+ (BOOL)isFileSynthesisEnabled;
+ (BOOL)isSpeakEnabled;
+ (void)setFileSynthesisEnabled:(BOOL)isEnabled;
+ (void)setSpeakEnabled:(BOOL)isEnabled;
@end

