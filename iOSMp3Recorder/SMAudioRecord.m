/**
 *  SMAudioRecord
 *  ShareMerge
 *
 *  Created by huangxp on 2014=06-25.
 *
 *  音频录制
 *
 *  Copyright (c) www.sharemerge.com All rights reserved.
 */

/** @file */    // Doxygen marker
#import "SMAudioRecord.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "lame.h"

// 码率
typedef enum _AudioRate {
	SMAudioRate_44100 = 44100,
	SMAudioRate_11025 = 11025,
}AudioRate;

// 格式
typedef enum _AudioFormat {
	SMAudioFormat_LinearPCM                 =     kAudioFormatLinearPCM,
	SMAudioFormat_AC3                       =     kAudioFormatAC3,
	SMAudioFormat_60958AC3                  =     kAudioFormat60958AC3,
	SMAudioFormat_AppleIMA4                 =     kAudioFormatAppleIMA4,
	SMAudioFormat_MPEG4AAC                  =     kAudioFormatMPEG4AAC,
	SMAudioFormat_MPEG4CELP                 =     kAudioFormatMPEG4CELP,
	SMAudioFormat_MPEG4HVXC                 =     kAudioFormatMPEG4HVXC,
	SMAudioFormat_MPEG4TwinVQ               =     kAudioFormatMPEG4TwinVQ,
	SMAudioFormat_MACE3                     =     kAudioFormatMACE3,
	SMAudioFormat_MACE6                     =     kAudioFormatMACE6,
	SMAudioFormat_ULaw                      =     kAudioFormatULaw,
	SMAudioFormat_ALaw                      =     kAudioFormatALaw,
	SMAudioFormat_QDesign                   =     kAudioFormatQDesign,
	SMAudioFormat_QDesign2                  =     kAudioFormatQDesign2,
	SMAudioFormat_QUALCOMM                  =     kAudioFormatQUALCOMM,
	SMAudioFormat_MPEGLayer1                =     kAudioFormatMPEGLayer1,
	SMAudioFormat_MPEGLayer2                =     kAudioFormatMPEGLayer2,
	SMAudioFormat_MPEGLayer3                =     kAudioFormatMPEGLayer3,
	SMAudioFormat_TimeCode                  =     kAudioFormatTimeCode,
	SMAudioFormat_MIDIStream                =     kAudioFormatMIDIStream,
	SMAudioFormat_ParameterValueStream      =     kAudioFormatParameterValueStream,
	SMAudioFormat_AppleLossless             =     kAudioFormatAppleLossless,
	SMAudioFormat_MPEG4AAC_HE               =     kAudioFormatMPEG4AAC_HE,
	SMAudioFormat_MPEG4AAC_LD               =     kAudioFormatMPEG4AAC_LD,
	SMAudioFormat_MPEG4AAC_ELD              =     kAudioFormatMPEG4AAC_ELD,
	SMAudioFormat_MPEG4AAC_ELD_SBR          =     kAudioFormatMPEG4AAC_ELD_SBR,
	SMAudioFormat_MPEG4AAC_ELD_V2           =     kAudioFormatMPEG4AAC_ELD_V2,
	SMAudioFormat_MPEG4AAC_HE_V2            =     kAudioFormatMPEG4AAC_HE_V2,
	SMAudioFormat_MPEG4AAC_Spatial          =     kAudioFormatMPEG4AAC_Spatial,
	SMAudioFormat_AMR                       =     kAudioFormatAMR,
	SMAudioFormat_AMR_WB                    =     kAudioFormatAMR_WB,
	SMAudioFormat_Audible                   =     kAudioFormatAudible,
	SMAudioFormat_iLBC                      =     kAudioFormatiLBC,
	SMAudioFormat_DVIIntelIMA               =     kAudioFormatDVIIntelIMA,
	SMAudioFormat_MicrosoftGSM              =     kAudioFormatMicrosoftGSM,
	SMAudioFormat_AES3                      =     kAudioFormatAES3,
}AudioFormat;

@implementation SMAudioInfo

- (instancetype)init {
	if ((self = [super init])) {
		_recordFileSize = 0;
		_recordFileTimeLength = 0;
		_outputFileSize = 0;
		_outputFileTimeLength = 0;
	}
	return self;
}

- (NSString *)description {
	return [@{ @"recordFileSize": @(self.recordFileSize),
	           @"recordFileTimeLength" : @(self.recordFileTimeLength),
	           @"outputFileSize" : @(self.outputFileSize),
	           @"outputFileTimeLength" : @(self.outputFileTimeLength) } description];
}

@end


@interface SMAudioRecord ()

@property (nonatomic, assign) AudioRate audioRate;
@property (nonatomic, assign) AudioFormat audioFormat;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSTimer *maxDurationTimer;
@property (nonatomic, assign) BOOL hasAudioRecord;

@end


@implementation SMAudioRecord

- (NSInteger)getFileSize:(NSString *)path {
	NSFileManager *filemanager = [[NSFileManager alloc] init];
	if ([filemanager fileExistsAtPath:path]) {
		NSDictionary *attributes = [filemanager attributesOfItemAtPath:path error:nil];
		NSNumber *theFileSize;
		if ((theFileSize = [attributes objectForKey:NSFileSize]))
			return [theFileSize intValue];
		else
			return -1;
	}
	else {
		return -1;
	}
}

- (instancetype)init {
	if ((self = [super init])) {
		_audioMaximumDuration = 30.0f;
		_recordQualityType = SMAudioQualityMax;
		_outputQuaityType = SMAudioQualityMax;
		_shouldOptimizeForNetworkUse = YES;

		if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/audiooutput", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]]]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/audiooutput", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]] withIntermediateDirectories:YES attributes:nil error:nil];
		}
		self.outputPath = [NSString stringWithFormat:@"%@/audiooutput/output.mp3", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
		_smai = [[SMAudioInfo alloc] init];
		_delegate = nil;

		_audioRate = SMAudioRate_44100;
		_audioFormat = SMAudioFormat_LinearPCM;

		AVAudioSession *session = [AVAudioSession sharedInstance];
		NSError *sessionError;
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
		if (session == nil)
			NSLog(@"Error creating session: %@", [sessionError description]);
		else
			[session setActive:YES error:nil];
	}
	return self;
}

- (BOOL)hasAudioRecord {
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputPath isDirectory:&isDir] && !isDir) {
		return YES;
	}
	return NO;
}

- (void)startRecord {
	if (self.delegate &&
	    [self.delegate respondsToSelector:@selector(recordStart:)]) {
		[self.delegate recordStart:self];
	}

	if (_shouldOptimizeForNetworkUse) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}

	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
	                          [NSNumber numberWithFloat:_audioRate],                  AVSampleRateKey,
	                          [NSNumber numberWithInt:_audioFormat],                   AVFormatIDKey,
	                          [NSNumber numberWithInt:2],                              AVNumberOfChannelsKey,
	                          [NSNumber numberWithInt:_recordQualityType],                       AVEncoderAudioQualityKey,
	                          nil];

	NSURL *recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
	NSError *error;
	_audioRecorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:&error];
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
		                                                message:@"your device doesn't support your setting"
		                                               delegate:self
		                                      cancelButtonTitle:@"OK"
		                                      otherButtonTitles:nil];
		[alert show];
		return;
	}
	[_audioRecorder prepareToRecord];
	_audioRecorder.meteringEnabled = YES;
	[_audioRecorder record];

	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01f
	                                                target:self
	                                              selector:@selector(timerUpdate)
	                                              userInfo:nil
	                                               repeats:YES];
	_maxDurationTimer = [NSTimer scheduledTimerWithTimeInterval:_audioMaximumDuration
	                                                     target:self
	                                                   selector:@selector(maxDurationUpdate)
	                                                   userInfo:nil
	                                                    repeats:YES];
}

- (void)maxDurationUpdate {
	[self stopRecord];
}

- (void)timerUpdate {
	int m = _audioRecorder.currentTime / 60; // 分
	int s = ((int)_audioRecorder.currentTime) % 60; // 秒
	int ss = (_audioRecorder.currentTime - ((int)_audioRecorder.currentTime)) * 100; // 毫秒
	NSInteger fileSize =  [self getFileSize:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
//	NSLog(@"%.2d:%.2d %.2d - %d", m, s, ss, fileSize);

	_smai.recordFileTimeLength = _audioRecorder.currentTime;
	_smai.recordFileSize = fileSize;

	[_audioRecorder updateMeters];
	_smai.averagePower = [_audioRecorder averagePowerForChannel:0];
	_smai.peakPower = [_audioRecorder peakPowerForChannel:0];

	_smai.averagePower = (100 + _smai.averagePower) / 100;
	_smai.peakPower = (100 + _smai.peakPower) / 100;
}

- (void)stopRecord {
	[_audioRecorder stop];
	[_updateTimer invalidate];
	_updateTimer = nil;
	[_maxDurationTimer invalidate];
	_maxDurationTimer = nil;

	if (self.delegate &&
	    [self.delegate respondsToSelector:@selector(recordStop:)]) {
		[self.delegate recordStop:self];
	}

	__block typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{  // 开始编码成mp3
	    NSString *cafFilePath = [NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
	    NSString *mp3FilePath = weakSelf.outputPath;

	    @try {
	        if (weakSelf.delegate &&
	            [weakSelf.delegate respondsToSelector:@selector(encodeStart:)]) {
	            [weakSelf.delegate encodeStart:weakSelf];
			}

	        int read, write;

	        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
	        fseek(pcm, 4 * 1024, SEEK_CUR);                                   //skip file header
	        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output

	        const int PCM_SIZE = 8192;
	        const int MP3_SIZE = 8192;
	        short int pcm_buffer[PCM_SIZE * 2];
	        unsigned char mp3_buffer[MP3_SIZE];

	        lame_t lame = lame_init();
	        lame_set_in_samplerate(lame, _audioRate);
	        lame_set_quality(lame, _outputQuaityType);
	        lame_set_VBR(lame, vbr_default);
	        lame_init_params(lame);

	        do {
	            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
	            if (read == 0)
					write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
	            else
					write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

	            fwrite(mp3_buffer, write, 1, mp3);
			}
	        while (read != 0);

	        lame_close(lame);
	        fclose(mp3);
	        fclose(pcm);

	        if (weakSelf.delegate &&
	            [weakSelf.delegate respondsToSelector:@selector(encodeStop:)]) {
	            [weakSelf.delegate encodeStop:weakSelf];
			}
		}
	    @catch (NSException *exception)
	    {
	        if (weakSelf.delegate &&
	            [weakSelf.delegate respondsToSelector:@selector(recordFailed:error:)]) {
	            [weakSelf.delegate recordFailed:weakSelf error:[exception description]];
			}
		}
	    @finally
	    {
	        NSInteger fileSize =  [weakSelf getFileSize:weakSelf.outputPath];
	        _smai.outputFileSize = fileSize / 1024;
	        _smai.outputFileTimeLength = _smai.recordFileTimeLength;

	        if (_shouldOptimizeForNetworkUse) {
	            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			}

	        if (weakSelf.delegate &&
	            [weakSelf.delegate respondsToSelector:@selector(recordFinished:)]) {
	            [weakSelf.delegate recordFinished:weakSelf];
			}
		}
	});
}

- (void)clearCache {
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputPath isDirectory:&isDir] && !isDir) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtPath:self.outputPath error:&error]) {
			NSLog(@"Failed to delete audio record. The error is %@", error);
		}
	}
}

@end
