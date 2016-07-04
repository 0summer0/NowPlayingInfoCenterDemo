//
//  ZXTrack.h
//  NowPlayingInfoCenterDemo
//
//  Created by Shawn on 16/7/4.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface ZXTrack : NSObject <DOUAudioFile>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *audioFileURL;

@end
