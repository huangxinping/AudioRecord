/**
 *  SMAudioRecord.h
 *  ShareMerge
 *
 *  Created by huangxp on 2014=06-25.
 *
 *  音频录制
 *
 *  整个音频操作的过程为：音频录制开始 - 音频录制结束 - 音频编码开始 - 音频编码结束
 *
 *
 *  Copyright (c) www.sharemerge.com All rights reserved.
 */

/** @file */    // Doxygen marker

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "SMAudioRecordDelegate.h"


// 质量
typedef enum _AudioQuality {
	SMAudioQualityMax = AVAudioQualityMax,      // 最大质量
	SMAudioQualityHigh = AVAudioQualityHigh,     // 最高质量
	SMAudioQualityMedium = AVAudioQualityMedium,   // 中等质量
	SMAudioQualityLow = AVAudioQualityLow,      // 最低质量
	SMAudioQualityMin = AVAudioQualityMin,      // 最小质量
}AudioQuality;

@interface SMAudioInfo : NSObject

/**
 *  录制的音频的大小（kb为单位）
 */
@property (nonatomic, assign) CGFloat recordFileSize;

/**
 *  录制的音频的时间长度（秒为单位）
 */
@property (nonatomic, assign) NSTimeInterval recordFileTimeLength;

/**
 *  声音力度平均值
 */
@property (nonatomic, assign) float averagePower;

/**
 *  声音力度最大值
 */
@property (nonatomic, assign) float peakPower;

/**
 *  输出的音频的大小（kb为单位）
 */
@property (nonatomic, assign) CGFloat outputFileSize;

/**
 *  输出的音频的时间长度（秒为单位）
 */
@property (nonatomic, assign) NSTimeInterval outputFileTimeLength;

@end



@interface SMAudioRecord : NSObject

/**
 *  音频录制最大时间（默认为30秒）
 */
@property (nonatomic, assign) NSTimeInterval audioMaximumDuration;

/**
 *  音频录制音质（默认为high）
 */
@property (nonatomic, assign) AudioQuality recordQualityType;

/**
 *  音频输出音质（默认为high）
 */
@property (nonatomic, assign) AudioQuality outputQuaityType;

/**
 *  是否显示网络菊花（默认为YES）
 */
@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;

/**
 *  音频输出路径（默认为../Documents/audiooutput/output.mp3）
 */
@property (nonatomic, strong) NSString *outputPath;

/**
 *  音频信息（包含录制和输出）
 */
@property (nonatomic, readonly) SMAudioInfo *smai;

/**
 *  委托
 */
@property (nonatomic, assign) id <SMAudioRecordDelegate> delegate;

/**
 *  是否有视频文件
 */
@property (nonatomic, readonly) BOOL hasAudioRecord;

/**
 *  开始录制
 */
- (void)startRecord;

/**
 *  停止录制
 */
- (void)stopRecord;

/**
 *  清除音频录制的缓存文件
 */
- (void)clearCache;

@end
