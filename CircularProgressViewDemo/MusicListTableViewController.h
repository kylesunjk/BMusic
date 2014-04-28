//
//  MusicListTableViewController.h
//  CircularProgressViewDemo
//
//  Created by Massive Mac on 28/4/14.
//  Copyright (c) 2014 YangYubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "sqlite3.h"
#import "EGORefreshTableHeaderView.h"
#define TABLE_NAME @"Music"
#define DATA_FILE @"musiclist"
#define MUSIC_NAME @"mediatitle"
@interface MusicListTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    sqlite3 *db;

}


@property (nonatomic,retain) NSMutableArray *items;         //存放本地歌曲
@property (nonatomic,retain) MPMusicPlayerController *mpc;
@end
