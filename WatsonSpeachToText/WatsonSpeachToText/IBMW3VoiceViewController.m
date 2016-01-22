//
//  IBMW3VoiceViewController.m
//  WatsonSpeachToText
//
//  Created by Rohit on 16/01/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "IBMW3VoiceViewController.h"
#import "AppDelegate.h"
#import <IMFCore/IMFResourceRequest.h>
#import <IMFCore/IMFResponse.h>
#import <IMFCore/IMFLogger.h>
#import <watsonsdk/SpeechToText.h>
#import <watsonsdk/STTConfiguration.h>
#import <watsonsdk/TextToSpeech.h>
#import <watsonsdk/TTSConfiguration.h>

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

static NSString *const kSpeachToTextUserId = @"64893126-a2f2-441c-826d-c4ab1e0db6f7";
static NSString *const kSpeachToTextPassword = @"UuBPx7uNLsuq";
static NSString *const kTextToVoiceUserId = @"e1bef40e-d10c-4565-84fe-cdb55aafdaa7";
static NSString *const kTextToVoicePassword = @"WPwCr2ybFgpy";
static NSString *const kTextToVoiceIdentifier = @"en-US_AllisonVoice";
static NSString *const kIBMW3SearchURL = @"http://w3-03.ibm.com/search/do/search?#qt=";
static NSString *const kGoogleSearchURL = @"https://www.google.co.in/search?q=";

@interface IBMW3VoiceViewController ()

- (void) configureViewSpeachToText;
- (void) configureViewTextToSpeachWithText : (NSString *) paramText;
- (void) startRecording;
- (void) stopRecording;
- (void) setMicActiveState;
- (void) setMicInactiveState;
- (void) requestQA : (NSString*) query;
- (void) navigateOnW3SearchWithSearchTerm : (NSString *) paramSearchTerm;
- (void) manageVoiceOperation;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL shouldShowResults;
@property (nonatomic, strong) NSString *transcribeURL;
@property (nonatomic, strong) NSString *askURL;
@property (nonatomic, strong) NSString *transcript;
@property (nonatomic, strong) NSString *paramVersionURL;
@property (nonatomic, strong) NSArray *searchData;
@property (nonatomic, strong) NSString *searchURL;
@property (nonatomic, strong) SpeechToText *stt;
@property (nonatomic, strong) TextToSpeech *tts;
@property (nonatomic, strong) IMFLogger *logger;
@property (weak, nonatomic) IBOutlet UIButton *recordButtonTapped;
@property (weak, nonatomic) IBOutlet UIButton *googleSearchButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation IBMW3VoiceViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureViewSpeachToText];
}

- (void) viewWillAppear:(BOOL)animated {
    [APPDELEGATE verifyConnection];
    self.statusLabel.text = @"Status : Please tap on button for voice based search";
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

/**
 * Configure Speach to Text Watson API
 */
- (void) configureViewSpeachToText {

    self.title = @"Watson Speech to Text";
    [self setSearchData:nil];
    
    NSString *server = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Backend_Route"];
    self.transcribeURL = [NSString stringWithFormat:@"%@/transcribe", server];
    self.askURL = [NSString stringWithFormat:@"%@/ask", server];
    
    //Speach to Text
    STTConfiguration *conf = [[STTConfiguration alloc] init];
    [conf setBasicAuthUsername:kSpeachToTextUserId];
    [conf setBasicAuthPassword:kSpeachToTextPassword];
    [conf setAudioCodec:WATSONSDK_AUDIO_CODEC_TYPE_OPUS];
    
    self.stt = [SpeechToText initWithConfig:conf];
    
    self.recording = NO;
    self.shouldShowResults = YES;

}

/**
 * Configure Text to Voice Watson API based on input parameter
 */
- (void) configureViewTextToSpeachWithText : (NSString *) paramText {
    
    [APPDELEGATE verifyConnection];
    
    TTSConfiguration *conf = [[TTSConfiguration alloc] init];
    [conf setBasicAuthUsername:kTextToVoiceUserId];
    [conf setBasicAuthPassword:kTextToVoicePassword];
    [conf setVoiceName:kTextToVoiceIdentifier];
    
    self.tts = [TextToSpeech initWithConfig:conf];
    
    [self.tts synthesize:^(NSData *data, NSError *err) {
        
        //Play audio
        [self.tts playAudio:^(NSError *err) {
            
            if(!err) {
                self.statusLabel.text = @"Status : audio finished playing";
                self.statusLabel.textColor = [UIColor greenColor];
                [self navigateOnW3SearchWithSearchTerm:paramText];
            } else {
                self.statusLabel.text = @"Status : error playing audio";
                self.statusLabel.textColor = [UIColor redColor];
                [self.activityIndicator stopAnimating];
            }
            
        } withData:data];
        
    } theText:paramText];
    
}

/**
 * Method start the recording
 */
- (void) startRecording {
    
    [self.logger logDebugWithMessages:@"startRecording"];
    self.recording = YES;
    self.transcript = nil;
    [self.activityIndicator startAnimating];
    
    [self.stt recognize:^(NSDictionary* res, NSError* err){
        
        if(err == nil) {
            
            self.transcript = [self.stt getTranscript:res];
            
            if([self.stt isFinalTranscript:res]) {
                
                [APPDELEGATE verifyConnection];
                [self stopRecording];
                [self setMicInactiveState];
                [self requestQA:self.transcript];
                
                //[self navigateOnW3SearchWithSearchTerm:self.transcript];
                [self configureViewTextToSpeachWithText:self.transcript];
            }
            
        } else {
            self.recording = NO;
            
            [self setMicInactiveState];
            if (self.transcript == nil) {
                [self.statusLabel setText:@"Sorry, I didn't catch that. Try again?"];
                [self.activityIndicator stopAnimating];
            }
            else
                [self requestQA:self.transcript];
        }
    }];
    
}

/**
 * Method stop recording
 */
- (void) stopRecording {
    [self.activityIndicator stopAnimating];
    [self.logger logDebugWithMessages:@"stopRecording"];
    [self.stt endRecognize];
    self.recording = NO;
}

/**
 * Method to logs event
 */

- (void) requestQA : (NSString*) query {
    
    [self.logger logInfoWithMessages:@"Query: %@", query];
    
    NSDictionary *params = @{@"query":query};
    
    IMFResourceRequest *imfRequest = [IMFResourceRequest requestWithPath:self.askURL
                                                                  method:@"GET"
                                                              parameters:params];
    [imfRequest sendWithCompletionHandler:^(IMFResponse *response, NSError *error) {
        
        NSDictionary* json = response.responseJson;
        
        if (json == nil) {
            json = @{@"answers":@[]};
            [self.logger logErrorWithMessages:@"Unable to retrieve results from server.  %@", [error localizedDescription]];
        }
        
        [self setSearchData:[json objectForKey:@"answers"]];
        
        NSString *labelString = nil;
        
        if ( ![self.searchData count] > 0) {
            labelString = @"Sorry, I was unable find what you are looking for.";
        }
        
        [self.logger logInfoWithMessages:@"query complete: %d records", [self.searchData count]];
        
        if (self.shouldShowResults) {
            self.shouldShowResults = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [self.searchData count] > 0) {
                    [self performSegueWithIdentifier:@"detailsViewSeque" sender:self];
                }
                
                [self.activityIndicator stopAnimating];
                if ( labelString != nil) {
                    [self.statusLabel setText:labelString];
                }
            });
        }
    }];
}

- (void) setMicActiveState {
    
    [self.logger logDebugWithMessages:@"setMicActiveState"];
    [self.statusLabel setText:@"What can Watson help you with today?"];
}

- (void) setMicInactiveState {
    
    [self.logger logDebugWithMessages:@"setMicInactiveState"];
    [self.statusLabel setText:@"Press button to start again."];
    [self.statusLabel setTextColor:[UIColor blackColor]];
    
    //[APPDELEGATE verifyConnection];

    
}

/**
 * Navigate on external browser
 */
- (void) navigateOnW3SearchWithSearchTerm : (NSString *) paramSearchTerm {
    
    [self.activityIndicator stopAnimating];
    paramSearchTerm = [paramSearchTerm stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *searchURL = [NSString stringWithFormat:@"%@%@%@",self.searchURL,paramSearchTerm,self.paramVersionURL];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:searchURL]]) {
        self.statusLabel.text = @"Status : Processing...";
        self.statusLabel.textColor = [UIColor greenColor];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchURL]];
    } else {
        self.statusLabel.text = @"Status : wrong keyword captured. Please try again";
        self.statusLabel.textColor = [UIColor redColor];
    }

    //[self configureViewTextToSpeachWithText:paramSearchTerm];
}

- (void) manageVoiceOperation {
   
    if (!self.recording) {
        [self startRecording];
        [self setMicActiveState];
    } else {
        [self stopRecording];
        [self setMicInactiveState];
    }
}

#pragma mark - ButtonTapped
- (IBAction) recordButtonTapped:(id)sender {

    [APPDELEGATE verifyConnection];

    if ([sender isEqual:self.recordButtonTapped]) {
        self.paramVersionURL = @"&v=17";
        self.searchURL = kIBMW3SearchURL;
        
    } else if ([sender isEqual:self.googleSearchButton]) {
        self.paramVersionURL = @"";
        self.searchURL = kGoogleSearchURL;
    }
    
    [self manageVoiceOperation];
}


@end
