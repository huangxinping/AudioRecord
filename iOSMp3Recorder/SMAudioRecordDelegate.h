/**
 *  SMAudioRecordDelegate.h
 *  ShareMerge
 *
 *  Created by huangxp on 2014-06-25.
 *
 *  音频录制委托
 *
 *  Copyright (c) www.sharemerge.com All rights reserved.
 */

/** @file */    // Doxygen marker

#import <Foundation/Foundation.h>

//  整个音频操作的过程为：音频录制开始 - 音频录制结束 - 音频编码开始 - 音频编码结束 - 音频录制完成
//                                                                      - 音频录制失败

@class SMAudioRecord;
@protocol SMAudioRecordDelegate <NSObject>
@optional
/**
 *  录制开始
 *
 *  @param audiorecord 音频录制实例
 */
- (void)recordStart:(SMAudioRecord *)audiorecord;

/**
 *  录制结束
 *
 *  @param audiorecord 音频录制实例
 */
- (void)recordStop:(SMAudioRecord *)audiorecord;

/**
 *  编码开始
 *
 *  @param audiorecord 音频录制实例
 */
- (void)encodeStart:(SMAudioRecord *)audiorecord;

/**
 *  编码结束
 *
 *  @param audiorecord 音频录制实例
 */
- (void)encodeStop:(SMAudioRecord *)audiorecord;

/**
 *  录制成功
 *
 *  @param audiorecord 音频录制实例
 */
- (void)recordFinished:(SMAudioRecord *)audiorecord;

/**
 *  录制失败
 *
 *  @param audiorecord 音频录制实例
 *  @param error       错误描述
 */
- (void)recordFailed:(SMAudioRecord *)audiorecord error:(NSString *)error;

@end
