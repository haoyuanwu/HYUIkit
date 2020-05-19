//
//  HYVideoRecording.h
//  TestRecording
//
//  Created by wuhaoyuan on 16/5/11.
//  Copyright © 2016年 wuhaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@protocol HYVideoRecordingDelegate <NSObject>

@optional
/**
 *  返回路径
 *
 *  @param PCMFilePath pcm路径
 *  @param Mp3FilePath MP3路径
 */
- (void)HYVideoRecordEndWithPCMFilePath:(NSString *)PCMFilePath mp3Path:(NSString *)Mp3FilePath;

/**
 *  开始播放
 */
- (void)HYVideoRecordWillPlayer:(AVAudioPlayer *)avplayer;

/**
 *  停止播放
 */
- (void)HYVideoRecordDidPlayer:(AVAudioPlayer *)avplayer;

/**
 *  播放中
 *
 *  @param musicPower 音量大小
 */
- (void)HYVideoRecordWithMusicPower:(CGFloat)musicPower;


@end

@interface HYVideoRecording : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

/**
 *  创建对象
 */
+ (HYVideoRecording *)singletion;

/**
 *  开始录音
 */
- (void)startVideoRecording;

/**
 *  暂停录音
 */
- (void)suspendedVideoRecording;

/**
 *  停止录音
 */
- (void)stopVideoRecording;

/**
 *  恢复录音
 */
- (void)restoreVideoRecording;

/**
 *  播放
 */
- (void)play;

/**
 *  停止播放
 */
- (void)stopPlay;

/**
 *  是否转换成MP3格式 默认是YES
 */
@property (nonatomic,assign)BOOL exchangeMp3;

/**
 *  是否打开红外线 默认是YES
 */
@property (nonatomic,assign)BOOL isOpenInfrared;

@property (nonatomic,strong)id <HYVideoRecordingDelegate> delegate;

@end
