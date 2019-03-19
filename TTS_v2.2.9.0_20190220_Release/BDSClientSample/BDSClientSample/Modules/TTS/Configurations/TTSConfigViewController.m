//
//  TTSConfigViewController.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#include <math.h>
#import <AVFoundation/AVAudioSession.h>
#import "TTSConfigViewController.h"
#import "BDSSpeechSynthesizer.h"
#import "BDSSpeechSynthesizerParams.h"
#import "TTSViewController.h"
#import "SelectionTableViewController.h"

enum SettingsSections{
    SettingSection_AudioPlayer = 0,
    SettingSection_SynthesisGeneral,
    SettingSection_OnlineSynthesis,
    SettingSectionCount
};

enum SettingRows_AudioPlayer{
    SettingRow_AudioPlayer_AudioVolume = 0,
    SettingRow_AudioPlayer_Enable_AVAudioSessionManagement,
    SettingRow_AudioPlayer_AVAudiosessionCategory,
    SettingRow_AudioPlayer_AVAudioSessionCategoryOptions,
    SettingRow_AudioPlayerCount,
};

enum SettingRows_SynthesisGeneral{
    SettingRow_SynthesisGeneral_SynthVolume = 0,
    SettingRow_SynthesisGeneral_SynthSpeed,
    SettingRow_SynthesisGeneral_SynthPitch,
    SettingRow_SynthesisGeneral_EnableSpeak,
    SettingRow_SynthesisGeneral_ReadTextFromFile,
    SettingRow_SynthesisGeneral_OnlineThreshold,
    SettingRow_SynthesisGeneralCount
};

enum SettingRows_OnlineSynthesis{
    SettingRow_OnlineSynthesis_Speaker = 0,
    SettingRow_OnlineSynthesis_AudioEncoding,
    SettingRow_OnlineXml,
    SettingRow_OnlineSynthesisCount
};

enum SettingRows_OfflineSynthesis{
    SettingRow_OfflineAudiomodelManager = 0,
    SettingRow_OfflineSynthesis_AudioEncoding,
    SettingRow_OfflineSynthesis_AppID,
    SettingRow_OfflineXml,
    SettingRow_OfflineSynthesisCount
};

NSString* const EDIT_PROPERTY_ID_PLAYER_VOLUME = @"PLAYER_VOLUME";
NSString* const EDIT_PROPERTY_ID_VOLUME = @"VOL";
NSString* const EDIT_PROPERTY_ID_SPEED = @"SPEED";
NSString* const EDIT_PROPERTY_ID_PITCH = @"PITC";
NSString* const EDIT_PROPERTY_ID_ENABLE_SPEAK = @"SPEAK";
NSString* const EDIT_PROPERTY_ID_ENABLE_FILE_SYNTH = @"READ_FROM_FILE";
NSString* const EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT = @"ENABLE_AV_MANAGEMENT";
NSString* const EDIT_PROPERTY_ID_ONLINE_TTS_XML = @"ONLINE_TTS_XML";
NSString* const EDIT_PROPERTY_ID_OFFLINE_TTS_XML = @"OFFLINE_TTS_XML";
NSString* const EDIT_PROPERTY_ID_TTS_ONLINE_TIMEOUT = @"ONLINE_TTS_TIMEOUT";
NSString* const EDIT_PROPERTY_ID_OFFLINE_TTS_APPID = @"OFFLINE_ENGINE_APP_ID";

static float SDK_PLAYER_VOLUME = 0.5;

static NSString* setOfflineAppID = @"";

#define KNOWN_ONLINE_SPEAKER_COUNT 5
#define AVAILABLE_AV_CATEGORY_OPTION_COUNT 5
int AUDIO_SESSION_CATEGORY_OPTIONS[] = {
                                        AVAudioSessionCategoryOptionMixWithOthers,
                                        AVAudioSessionCategoryOptionDuckOthers,
                                        AVAudioSessionCategoryOptionAllowBluetooth,
                                        AVAudioSessionCategoryOptionDefaultToSpeaker,
                                        AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers
                                        };
const NSString *AUDIO_SESSION_CATEGORY_OPT_NAMES[] = {@"Mix with others",@"Duck others",@"Allow bluetooth",@"Default to speaker",@"Interrupt spoken, mix others"};

typedef enum SelectionControllerSelectProperty{
    
        SelectionControllerSelectProperty_ONLINE_AUE,
    SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY_OPTIONS,
    SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY,
    SelectionControllerSelectProperty_ONLINE_SPEAKER,
    SelectionControllerSelectProperty_OFFLINE_AUDIO_ENCODING,
    SelectionControllerSelectProperty_ONLINE_TTS_THRESHOLD
}SelectionControllerSelectProperty;

__strong static NSString* currentOfflineEnglishModelName;
__strong static NSString* currentOfflineChineseModelName;

@interface TTSConfigViewController ()
@property (nonatomic,strong)NSMutableArray* selectionControllerSelectedIndexes;
@property (nonatomic)SelectionControllerSelectProperty ongoing_multiselection;
@property (nonatomic,strong)NSArray* audioSessionCategories;
@end

@implementation TTSConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAudioSessionManagementEnabled = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT withError:nil] boolValue];
    self.audioSessionCategories = [[NSArray alloc] initWithObjects:AVAudioSessionCategoryAmbient, AVAudioSessionCategorySoloAmbient, AVAudioSessionCategoryPlayback, AVAudioSessionCategoryPlayAndRecord, nil];
}

- (void)ttsEedNotif:(NSNotification *)notif{
    
    NSLog(@"ttsEedNotif object:%@", notif.object);
    
}

- (void)ttsErrorNotif:(NSNotification *)notif{
    
    NSLog(@"ttsErrorNotif object:%@", notif.object);
}


+(void)loadedAudioModelWithName:(NSString*)modelName forLanguage:(NSString*)language{
    if([language isEqualToString:@"eng"]){
        currentOfflineEnglishModelName = modelName;
    }else{
        currentOfflineChineseModelName = modelName;
    }
}

-(void)processMultiselectResult{
    NSMutableArray* selected = self.selectionControllerSelectedIndexes;
    self.selectionControllerSelectedIndexes = nil;
    switch (self.ongoing_multiselection) {
        case SelectionControllerSelectProperty_ONLINE_AUE:
        {
            if(selected.count > 0){
                NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[selected objectAtIndex:0] forKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING];
                if(err){
                    [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online audio encoding" value:@"" table:@"Localizable"]];
                }
            }
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY_OPTIONS:
        {
            int options = 0;
            for(NSNumber* n in selected){
                options|= AUDIO_SESSION_CATEGORY_OPTIONS[[n intValue]];
            }
            NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInt:options] forKey:BDS_SYNTHESIZER_PARAM_AUDIO_SESSION_CATEGORY_OPTIONS];
            if(err){
                [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set synth strategy" value:@"" table:@"Localizable"]];
            }
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY:
        {
            [[BDSSpeechSynthesizer sharedInstance] setAudioSessionCategory:[self.audioSessionCategories objectAtIndex:[[selected objectAtIndex:0] integerValue]]];
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case SelectionControllerSelectProperty_ONLINE_SPEAKER:
        {
            if(selected.count > 0){
                NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[selected objectAtIndex:0] forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
                if(err){
                    [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS speaker" value:@"" table:@"Localizable"]];
                }
            }
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case SelectionControllerSelectProperty_OFFLINE_AUDIO_ENCODING:
        {
            if(selected.count > 0){
                NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[selected objectAtIndex:0] forKey:BDS_SYNTHESIZER_PARAM_ETTS_AUDIO_FORMAT];
                if(err){
                    [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set offline audio encoding" value:@"" table:@"Localizable"]];
                }
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
        case SelectionControllerSelectProperty_ONLINE_TTS_THRESHOLD:
        {
            if(selected.count > 0){
                NSError *err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[selected objectAtIndex:0] forKey:BDS_SYNTHESIZER_PARAM_ONLINE_TTS_THRESHOLD];
                if(err){
                    [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online TTS threshold" value:@"" table:@"Localizable"]];
                }
//                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:6 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
        }
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.selectionControllerSelectedIndexes != nil){
        [self processMultiselectResult];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayError:(NSError*)error withTitle:(NSString*)title{
    NSString* errMessage = error.localizedDescription;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"Localizable"] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SettingSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SettingSection_AudioPlayer:
            return [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT withError:nil] boolValue]?SettingRow_AudioPlayerCount:(SettingRow_AudioPlayerCount-2);
        case SettingSection_SynthesisGeneral:
            return SettingRow_SynthesisGeneralCount;
        case SettingSection_OnlineSynthesis:
            return SettingRow_OnlineSynthesisCount;
        default:
            break;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [l setBackgroundColor:[UIColor grayColor]];
    switch (section) {
        case SettingSection_AudioPlayer:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio player settings" value:@"" table:@"Localizable"]];
            break;
        case SettingSection_SynthesisGeneral:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"Synthesizer general settings" value:@"" table:@"Localizable"]];
            break;
        case SettingSection_OnlineSynthesis:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"Online Synthesizer Settings" value:@"" table:@"Localizable"]];
            break;
        default:
            break;
    }
    return l;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

-(NSString*)netThresholdNameFromID:(ONLINE_TTS_TRESHOLD)thresHold{
    switch (thresHold) {
        case REQ_CONNECTIVITY_ANY: return [[NSBundle mainBundle] localizedStringForKey:@"Not offline" value:@"" table:@"Localizable"];
        case REQ_CONNECTIVITY_3G: return [[NSBundle mainBundle] localizedStringForKey:@"have 3G or better" value:@"" table:@"Localizable"];
        case REQ_CONNECTIVITY_4G: return [[NSBundle mainBundle] localizedStringForKey:@"have 4G or better" value:@"" table:@"Localizable"];
        case REQ_CONNECTIVITY_WIFI: return [[NSBundle mainBundle] localizedStringForKey:@"have WiFi" value:@"" table:@"Localizable"];
        default:
            return [[NSBundle mainBundle] localizedStringForKey:@"Unknown" value:@"" table:@"Localizable"];
    }
}

-(UITableViewCell*)cellForGeneralSettings:(NSIndexPath* )path table:(UITableView*) tableView{
    switch (path.row) {
        case SettingRow_SynthesisGeneral_SynthVolume:
        {
            // Volume
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_VOLUME;
            int currentValue = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_VOLUME withError:nil] intValue];
            [cell.valueSlider setMaximumValue:15.0];
            [cell.valueSlider setMinimumValue:0.0];
            [cell.valueSlider setValue:(float)currentValue];
            [cell.currentValueLabel setText:[NSString stringWithFormat:@"%d", currentValue]];
            cell.isContinuous = NO;
            cell.delegate = self;
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Speech volume" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_SynthesisGeneral_SynthSpeed:
        {
            // Speed
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_SPEED;
            int currentValue = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_SPEED withError:nil] intValue];
            [cell.valueSlider setMaximumValue:9.0];
            [cell.valueSlider setMinimumValue:0.0];
            [cell.valueSlider setValue:(float)currentValue];
            [cell.currentValueLabel setText:[NSString stringWithFormat:@"%d", currentValue]];
            cell.isContinuous = NO;
            cell.delegate = self;
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Speech speed" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_SynthesisGeneral_SynthPitch:
        {
            // Pitch
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_PITCH;
            int currentValue = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_PITCH withError:nil] intValue];
            [cell.valueSlider setMaximumValue:9.0];
            [cell.valueSlider setMinimumValue:0.0];
            [cell.valueSlider setValue:(float)currentValue];
            [cell.currentValueLabel setText:[NSString stringWithFormat:@"%d", currentValue]];
            cell.isContinuous = NO;
            cell.delegate = self;
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Speech pitch" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_SynthesisGeneral_EnableSpeak:
        {
            // Enable speak
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SWITCH_CELL" forIndexPath:path];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Enable speak" value:@"" table:@"Localizable"]];
            [cell.stateSwitch setOn:[TTSViewController isSpeakEnabled]];
            cell.delegate = self;
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ENABLE_SPEAK;
            return cell;
        }
        case SettingRow_SynthesisGeneral_ReadTextFromFile:
        {
            // Read text from tts_text.txt
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SWITCH_CELL" forIndexPath:path];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Read text from tts_text.txt" value:@"" table:@"Localizable"]];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ENABLE_FILE_SYNTH;
            [cell.stateSwitch setOn:[TTSViewController isFileSynthesisEnabled]];
            cell.delegate = self;
            return cell;
        }
        case SettingRow_SynthesisGeneral_OnlineThreshold:
        {
            // threshold
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:path];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Prefer Online TTS when" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:[self netThresholdNameFromID:(ONLINE_TTS_TRESHOLD)[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ONLINE_TTS_THRESHOLD withError:nil] intValue]]];
            return cell;
        }
        default:
            break;
    }
    return nil;
}

-(NSString*)onlineSpeakerDescriptionFromID:(NSInteger)speakerID{
    switch (speakerID) {
        case 0: return [[NSBundle mainBundle] localizedStringForKey:@"Female, f7" value:@"" table:@"Localizable"];
        case 1: return [[NSBundle mainBundle] localizedStringForKey:@"Male, macs" value:@"" table:@"Localizable"];
        case 2: return [[NSBundle mainBundle] localizedStringForKey:@"Male, m15" value:@"" table:@"Localizable"];
        case 3: return [[NSBundle mainBundle] localizedStringForKey:@"Male, yyjw" value:@"" table:@"Localizable"];
        case 4: return [[NSBundle mainBundle] localizedStringForKey:@"Duyaya" value:@"" table:@"Localizable"];
        default:
            return [[NSBundle mainBundle] localizedStringForKey:@"Unknown" value:@"" table:@"Localizable"];
    }
}

-(NSString*)OnlineAudioEncodingDescFromID:(NSInteger)AUEID{
    switch (AUEID) {
        case BDS_SYNTHESIZER_AUDIO_ENCODE_BV_16K: return @"BroadVoice 16kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_6K6: return @"AMR 6.6kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_8K85: return @"AMR 8.85kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_12K65: return @"AMR 12.65kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_14K25: return @"AMR 14.25kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_15K85: return @"AMR 15.85kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_18K25: return @"AMR 18.25kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_19K85: return @"AMR 19.85kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_23K05: return @"AMR 23.05kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_AMR_23K85: return @"AMR 23.85kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_8K: return @"Opus 8kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_16K:return  @"Opus 16kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_18K: return @"Opus 18kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_20K: return @"Opus 20kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_24K: return @"Opus 24kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_OPUS_32K: return @"Opus 32kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_8K: return @"MP3 8kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_11K: return @"MP3 11kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_16K: return @"MP3 16kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_24K: return @"MP3 24kbps";
        case BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_32K: return @"MP3 32kbps";
        default:
            return [[NSBundle mainBundle] localizedStringForKey:@"Unknown" value:@"" table:@"Localizable"];
    }
}

- (UITableViewCell*)cellForOnlineTTSSettings:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case SettingRow_OnlineSynthesis_Speaker:
        {
            // speaker
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Speaker" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:[self onlineSpeakerDescriptionFromID:[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_SPEAKER withError:nil] integerValue]]];
            return cell;
        }
        case SettingRow_OnlineSynthesis_AudioEncoding:
        {
            // audio encoding
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio encoding" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:[self OnlineAudioEncodingDescFromID:[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING withError:nil] integerValue]]];
            return cell;
        }
        case SettingRow_OnlineXml:
        {
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SWITCH_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Enable xml" value:@"" table:@"Localizable"]];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ONLINE_TTS_XML;
            [cell.stateSwitch setOn:([[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ONLINE_OPEN_XML withError:nil] integerValue] == 1)];
            cell.delegate = self;
            return cell;
        }
        default:
            break;
    }
    return nil;
}

-(NSString*)offlineSpeakerDescriptionFromID:(NSInteger)speakerID{
    switch (speakerID) {
        case 0: return [[NSBundle mainBundle] localizedStringForKey:@"Female" value:@"" table:@"Localizable"];
        case 1: return [[NSBundle mainBundle] localizedStringForKey:@"Male" value:@"" table:@"Localizable"];
        default:
            return [[NSBundle mainBundle] localizedStringForKey:@"Unknown" value:@"" table:@"Localizable"];
    }
}

-(NSString*)OfflineAudioEncodingDescFromID:(NSInteger)AUEID{
    switch (AUEID) {
        case ETTS_AUDIO_TYPE_PCM_16K: return @"16 bit PCM 16 khz";
        case ETTS_AUDIO_TYPE_PCM_8K: return @"16 bit PCM 8 khz";
        default:
            return @"Unknown";
    }
}
- (UITableViewCell*)cellForAudioSettings:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case SettingRow_AudioPlayer_AudioVolume:
        {
            // Volume
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:indexPath];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_PLAYER_VOLUME;
            [cell.valueSlider setMaximumValue:1.0];
            [cell.valueSlider setMinimumValue:0.0];
            [cell.valueSlider setValue:SDK_PLAYER_VOLUME];
            [cell.currentValueLabel setText:[NSString stringWithFormat:@"%.2f", SDK_PLAYER_VOLUME]];
            cell.isContinuous = YES;
            cell.delegate = self;
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Volume" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_AudioPlayer_Enable_AVAudioSessionManagement:{
            // Enable management
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SWITCH_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio session management" value:@"" table:@"Localizable"]];
            [cell.stateSwitch setOn:[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT withError:nil] boolValue]];
            cell.delegate = self;
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT;
            return cell;
        }
        case SettingRow_AudioPlayer_AVAudiosessionCategory:
        {
            // category
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Category" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:[BDSSpeechSynthesizer sharedInstance].audioSessionCategory];
            return cell;
        }
        case SettingRow_AudioPlayer_AVAudioSessionCategoryOptions:
        {
            // category options
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio session category opts" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:@""];
            return cell;
        }
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case SettingSection_AudioPlayer:
            return [self cellForAudioSettings:tableView IndexPath:indexPath];
        case SettingSection_SynthesisGeneral:
            return [self cellForGeneralSettings:indexPath table:tableView];
        case SettingSection_OnlineSynthesis:
            return [self cellForOnlineTTSSettings:tableView IndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SettingSection_AudioPlayer:
        {
            switch (indexPath.row) {
                case SettingRow_AudioPlayer_Enable_AVAudioSessionManagement:
                    return NO;
                case SettingRow_AudioPlayer_AVAudiosessionCategory:
                case SettingRow_AudioPlayer_AVAudioSessionCategoryOptions:
                    return YES;
                default:
                    break;
            }
        }
        case SettingSection_SynthesisGeneral:
        {
            switch (indexPath.row) {
                case SettingRow_SynthesisGeneral_SynthVolume:
                case SettingRow_SynthesisGeneral_SynthSpeed:
                case SettingRow_SynthesisGeneral_SynthPitch:
                case SettingRow_SynthesisGeneral_EnableSpeak:
                case SettingRow_SynthesisGeneral_ReadTextFromFile:
                    return NO;
                case SettingRow_SynthesisGeneral_OnlineThreshold:
                    return YES; // select strategy
                default:
                    return NO;
            }
        }
        case SettingSection_OnlineSynthesis:
            switch (indexPath.row) {
                case SettingRow_OnlineSynthesis_Speaker:
                case SettingRow_OnlineSynthesis_AudioEncoding:
                    return YES;
                default:
                    return NO;
            }
        default:
            return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SettingSection_AudioPlayer:
        {
            switch (indexPath.row) {
                case SettingRow_AudioPlayer_AVAudiosessionCategory:{
                    // select category
                    NSString * storyboardName = @"TTSMain";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = NO;
                    vc.allowNoneSelected = NO;
                    NSString* currCategory = [BDSSpeechSynthesizer sharedInstance].audioSessionCategory;
                    int selectedCategory = 0;
                    for(NSString* string in self.audioSessionCategories){
                        if([currCategory isEqualToString:string]){
                            break;
                        }
                        selectedCategory++;
                    }
                    if(selectedCategory >= self.audioSessionCategories.count)selectedCategory = 0;
                    
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:selectedCategory], nil];
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"Synthesis strategy" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = self.audioSessionCategories;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case SettingRow_AudioPlayer_AVAudioSessionCategoryOptions:{
                    // select options
                    NSString * storyboardName = @"TTSMain";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = YES;
                    vc.allowNoneSelected = YES;
                    
                    int currFlags = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_AUDIO_SESSION_CATEGORY_OPTIONS withError:nil] intValue];
                    
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] init];
                    NSMutableArray* options = [[NSMutableArray alloc] init];
                    for(int i = 0;i<AVAILABLE_AV_CATEGORY_OPTION_COUNT;i++){
                        if((currFlags&AUDIO_SESSION_CATEGORY_OPTIONS[i]) == AUDIO_SESSION_CATEGORY_OPTIONS[i])
                        {
                            [selectedItems addObject:[NSNumber numberWithInt:i]];
                        }
                        [options addObject:AUDIO_SESSION_CATEGORY_OPT_NAMES[i]];
                    }
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"AV session category options" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = options;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY_OPTIONS;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case SettingSection_SynthesisGeneral:
        {
            switch (indexPath.row) {
                case SettingRow_SynthesisGeneral_OnlineThreshold:{
                    NSString * storyboardName = @"TTSMain";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = NO;
                    vc.allowNoneSelected = NO;
                    ONLINE_TTS_TRESHOLD curr = (ONLINE_TTS_TRESHOLD)[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ONLINE_TTS_THRESHOLD withError:nil] intValue];
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:curr], nil];
                    NSMutableArray* options = [[NSMutableArray alloc] init];
                    for(ONLINE_TTS_TRESHOLD m = REQ_CONNECTIVITY_ANY;m <= REQ_CONNECTIVITY_WIFI;m++){
                        [options addObject:[self netThresholdNameFromID:m]];
                    }
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"Online TTS preferred when" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = options;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_ONLINE_TTS_THRESHOLD;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case SettingSection_OnlineSynthesis:
            switch (indexPath.row) {
                case SettingRow_OnlineSynthesis_Speaker:{
                    // online speaker
                    NSString * storyboardName = @"TTSMain";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = NO;
                    vc.allowNoneSelected = NO;
                    NSInteger currentSpeaker = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_SPEAKER withError:nil] integerValue];
                    NSMutableArray* availableItems = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < KNOWN_ONLINE_SPEAKER_COUNT; i++) {
                        [availableItems addObject:[self onlineSpeakerDescriptionFromID:i]];
                    }
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:currentSpeaker], nil];
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"Online speaker" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = availableItems;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_ONLINE_SPEAKER;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                case SettingRow_OnlineSynthesis_AudioEncoding:{
                    // online audio format
                    NSString * storyboardName = @"TTSMain";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = NO;
                    vc.allowNoneSelected = NO;
                    NSInteger currentEncoding = [[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING withError:nil] integerValue];
                    NSMutableArray* availableItems = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i <= BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_32K; i++) {
                        [availableItems addObject:[self OnlineAudioEncodingDescFromID:i]];
                    }
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:currentEncoding], nil];
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"Online audio encoding" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = availableItems;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_ONLINE_AUE;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - SwitchTableViewCellDelegate
-(void)switchStateChanged:(BOOL)newState forPropertyID:(NSString*)propertyID{
    if([EDIT_PROPERTY_ID_ENABLE_FILE_SYNTH isEqualToString:propertyID]){
        [TTSViewController setFileSynthesisEnabled:newState];
    }
    else if([EDIT_PROPERTY_ID_ENABLE_SPEAK isEqualToString:propertyID]){
        [TTSViewController setSpeakEnabled:newState];
    }
    else if([EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT isEqualToString:propertyID]){
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithBool:newState] forKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed to change audio session management status" value:@"" table:@"Localizable"]];
            return;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if([EDIT_PROPERTY_ID_ONLINE_TTS_XML isEqualToString:propertyID]){
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:(newState?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]) forKey:BDS_SYNTHESIZER_PARAM_ONLINE_OPEN_XML];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online xml" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_OFFLINE_TTS_XML isEqualToString:propertyID]){
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:(newState?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]) forKey:BDS_SYNTHESIZER_PARAM_ETTS_OPEN_XML];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online xml" value:@"" table:@"Localizable"]];
        }
    }
}
#pragma mark - SliderTableViewCellDelegate
-(void)sliderValueChanged:(float)newValue forProperty:(NSString*)propertyID fromSlider:(SliderTableViewCell*)src{
    if([EDIT_PROPERTY_ID_VOLUME isEqualToString:propertyID]){
        int value = (int)newValue;
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInteger:value] forKey:BDS_SYNTHESIZER_PARAM_VOLUME];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set synth volume" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_SPEED isEqualToString:propertyID]){
        int value = (int)newValue;
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInteger:value] forKey:BDS_SYNTHESIZER_PARAM_SPEED];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set synth speed" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_PITCH isEqualToString:propertyID]){
        int value = (int)newValue;
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInteger:value] forKey:BDS_SYNTHESIZER_PARAM_PITCH];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set synth pitch" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_PLAYER_VOLUME isEqualToString:propertyID]){
        SDK_PLAYER_VOLUME = newValue;
        [[BDSSpeechSynthesizer sharedInstance] setPlayerVolume:newValue];
    }
}
#pragma mark - InputTableViewCellDelegate
-(void)InputCellChangedValue:(NSString*)newValue forProperty:(NSString*)propertyID
{
    if([EDIT_PROPERTY_ID_TTS_ONLINE_TIMEOUT isEqualToString:propertyID]){
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithFloat:[newValue floatValue]] forKey:BDS_SYNTHESIZER_PARAM_ONLINE_REQUEST_TIMEOUT];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online tts timeout" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_OFFLINE_TTS_APPID isEqualToString:propertyID]){
//        // switching app id requires reloading whole engine
//        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerChineseSpeechDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineTextData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerChineseTextDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineEnglishSpeechData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerEnglishSpeechDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineEnglishTextData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerEnglishTextDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineLicenseFile = [[NSBundle mainBundle] pathForResource:@"offline_engine_tmp_license" ofType:@"dat"];
//        
//        NSError* err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineEngineTextData speechDataPath:offlineEngineSpeechData licenseFilePath:offlineEngineLicenseFile withAppCode:newValue];
//        if(err){
//            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Offline TTS init failed" value:@"" table:@"Localizable"]];
//            setOfflineSpeaker = OfflineSpeaker_None;
//            return;
//        }
//        err = [[BDSSpeechSynthesizer sharedInstance] loadEnglishDataForOfflineEngine:offlineEngineEnglishTextData speechData:offlineEngineEnglishSpeechData];
//        if(err){
//            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Offline TTS load English support failed" value:@"" table:@"Localizable"]];
//            return;
//        }
//        setOfflineAppID = newValue;
    }
    [self.tableView reloadData];
}
@end
