//
//  HYVideoRecording.m
//  TestRecording
//
//  Created by wuhaoyuan on 16/5/11.
//  Copyright © 2016年 wuhaoyuan. All rights reserved.
//

#import "HYVideoRecording.h"
#define kRecordAudioFile @"myRecord.caf"

@interface HYVideoRecording ()
{
    NSString *PCMPath;
    NSString *MP3Path;
}
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) UIProgressView *audioPower;//音频波动
@property (nonatomic,strong) AVAudioPlayer *avPlayer;
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）
@end

@implementation HYVideoRecording

+ (HYVideoRecording *)singletion{
    static HYVideoRecording *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[HYVideoRecording alloc]init];
        [obj setAudioSession];
        obj.exchangeMp3 = YES;
        obj->PCMPath = @"";
        obj->MP3Path = @"";
        obj.isOpenInfrared = YES;
    });
    return obj;
}
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url = [self getSavePath];
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}


/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    PCMPath = urlStr;
    NSLog(@"file path:%@",urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //录音格式 无法使用
    [dicM setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [dicM setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];
    //通道数
    [dicM setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [dicM setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    //....其他设置等
    return dicM;
}

//============================================触发方法===============================================
/**
 *  开始录音
 */
- (void)startVideoRecording{
    [self setAudioSession];
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate = [NSDate distantPast];
    }
}

/**
 *  暂停录音
 */
- (void)suspendedVideoRecording{
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}

/**
 *  停止录音
 */
- (void)stopVideoRecording{
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
    self.audioPower.progress=0.0;
}

/**
 *  恢复录音
 */
- (void)restoreVideoRecording{
    [self startVideoRecording];
}

/**
 *  播放
 */
- (void)play{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    [self.avPlayer play];
}

//停止播放
- (void)stopPlay{
    [self.avPlayer stop];
}

#pragma mark audioRecorderDelegate
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (self.exchangeMp3) {
        [self exchangePcmWithMp3];
    }
    if (self.delegate) {
        [self.delegate HYVideoRecordEndWithPCMFilePath:PCMPath mp3Path:MP3Path];
    }
}

/**
 *  PCM转MP3格式
 */
- (void)exchangePcmWithMp3{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"music.mp3"];
    MP3Path = urlStr;
    @try {
        int read, write;
        
        FILE *pcm = fopen([PCMPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([MP3Path cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 20000;//8192
        const int MP3_SIZE = 20000;//8192
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
            {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            }
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[exception description] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
    }
    @finally {
        NSLog(@"转换成功 %@",MP3Path);
    }
}

/**
 *  初始播放器
 */
- (AVAudioPlayer *)avPlayer{
    
    NSURL *url = [NSURL fileURLWithPath:MP3Path?MP3Path:PCMPath];
    _avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _avPlayer.meteringEnabled = YES;
    _avPlayer.delegate = self;
    [self handleNotification:YES];
    return _avPlayer;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self handleNotification:NO];
}

//===================================================红外线================================================
#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    if (!self.isOpenInfrared) {
        return;
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state){
        //添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    }else{
        //移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    if (self.delegate) {
        [self.delegate HYVideoRecordWithMusicPower:power];
    }
    [self.audioPower setProgress:progress];
}




@end
