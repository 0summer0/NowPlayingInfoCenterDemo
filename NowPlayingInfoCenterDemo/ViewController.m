//
//  ViewController.m
//  NowPlayingInfoCenterDemo
//
//  Created by Shawn on 16/7/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "ViewController.h"
#import "DOUAudioStreamer.h"
#import "ZXTrack.h"
#import <MediaPlayer/MediaPlayer.h>

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface ViewController ()

@property (nonatomic, strong) DOUAudioStreamer *streamer;

@end

@implementation ViewController

#pragma mark - view lifecycle

- (void)dealloc
{
    [self removeObserver:self.streamer forKeyPath:@"status"];
    [self removeObserver:self.streamer forKeyPath:@"duration"];
    [self removeObserver:self.streamer forKeyPath:@"bufferingRatio"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.streamer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NowPlayingInfoCenterDemo";
    
    [self configAudioRemoteControl];
    [self createStreamer];
    [self.streamer play];
}

#pragma mark - Private Mtd

- (void)createStreamer
{
    ZXTrack *track = [[ZXTrack alloc] init];
    
//    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Sakae_in_Action" ofType:@"mp3"];
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
//    track.audioFileURL = fileURL;
    
    track.audioFileURL = [NSURL URLWithString:@"http://43.226.162.43/m10.music.126.net/20160711165719/5dc0536e58e41d22e04aab2e0eccd18b/ymusic/e965/d288/5003/f6a10da6c3306f97d1606b0854af76d8.mp3?wshc_tag=0&wsts_tag=57835abf&wsid_tag=72fb4b74&wsiphost=ipdbm"];
    _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
}

- (void)configNowPlayingInfoCenter
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@1 forKey:MPNowPlayingInfoPropertyPlaybackRate]; // 播放速度
    [dict setObject:@"路"forKey:MPMediaItemPropertyTitle]; // 歌曲名
    [dict setObject:@"朴政焕" forKey:MPMediaItemPropertyArtist]; // 歌手名
    [dict setObject:@"<<Blade & Soul O.S.T - The World>>" forKey:MPMediaItemPropertyAlbumTitle]; // 专辑名
    [dict setObject:@(self.streamer.duration) forKey:MPMediaItemPropertyPlaybackDuration]; // 歌曲时长
    [dict setObject:@(self.streamer.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; // 已经播放时长
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"zx_BNS.jpg"]]; // 封面
    [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

- (void)configAudioRemoteControl
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    [commandCenter.playCommand addTarget:self action:@selector(playAction)];
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAction)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackAction)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackAction)];
}

- (void)playbackRateToZero
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    [dict setObject:@0 forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [dict setObject:@(self.streamer.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

- (void)playbackRateResume
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
    [dict setObject:@1 forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

#pragma mark - Streamer Status KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        DOUAudioStreamerStatus status = (DOUAudioStreamerStatus)[change[@"new"] integerValue];
        [self printStreamerStatus:status];
        if (status == DOUAudioStreamerFinished) {
            [self.streamer stop];
            [self.streamer play];
        }
    } else if (context == kDurationKVOKey) {
        NSLog(@"Duration: %@", change[@"new"]);
        [self configNowPlayingInfoCenter]; // 设置歌曲信息
    } else if (context == kBufferingRatioKVOKey) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Action Code

- (void)playAction
{
    [self playbackRateResume];
    [self.streamer play];
}

- (void)pauseAction
{
    [self playbackRateToZero];
    [self.streamer pause];
}

- (void)previousTrackAction
{
    NSLog(@"previous track");
}

- (void)nextTrackAction
{
    NSLog(@"next track");
}

- (IBAction)pause:(id)sender {
    [self playbackRateToZero];
    [self.streamer pause];
}

- (IBAction)play:(id)sender {
    [self playbackRateResume];
    [self.streamer play];
}

#pragma mark - 打酱油

- (void)printStreamerStatus:(DOUAudioStreamerStatus)status
{
    switch (status) {
        case DOUAudioStreamerPlaying:
            NSLog(@"Playing");
            break;
        case DOUAudioStreamerPaused:
            NSLog(@"Paused");
            break;
        case DOUAudioStreamerIdle:
            NSLog(@"Idle");
            break;
        case DOUAudioStreamerFinished:
            NSLog(@"Finished");
            break;
        case DOUAudioStreamerBuffering:
            NSLog(@"Buffering");
            break;
        case DOUAudioStreamerError:
            NSLog(@"Error");
            break;
            
        default:
            break;
    }
}

@end
