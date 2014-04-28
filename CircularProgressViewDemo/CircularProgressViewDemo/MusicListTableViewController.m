//
//  MusicListTableViewController.m
//  CircularProgressViewDemo
//
//  Created by Massive Mac on 28/4/14.
//  Copyright (c) 2014 YangYubin. All rights reserved.
//

#import "MusicListTableViewController.h"

@interface MusicListTableViewController ()
@property (nonatomic , retain)NSMutableArray *albumArray;
@property (nonatomic , retain)NSMutableArray *artistArray;
@property (nonatomic , retain)NSMutableArray *sortedArray;
@end

@implementation MusicListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.items = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    [self initMusicItems];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initMusicItems{
    //获得query，用于请求本地歌曲集合
    _albumArray =[[NSMutableArray alloc]init];
    _artistArray =[[NSMutableArray alloc]init];
    _sortedArray =[[NSMutableArray alloc]init];
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    //循环获取得到query获得的集合

    for (MPMediaItemCollection *conllection in query.collections) {
        //MPMediaItem为歌曲项，包含歌曲信息
        for (MPMediaItem *item in conllection.items) {
            [self.items addObject:item];
        }
    }
    //通过歌曲items数组创建一个collection
    MPMediaItemCollection *mic = [[MPMediaItemCollection alloc] initWithItems:self.items];
    //获得应用播放器
    self.mpc = [MPMusicPlayerController applicationMusicPlayer];
    //开启播放通知，不开启，不会发送歌曲完成，音量改变的通知
    [self.mpc beginGeneratingPlaybackNotifications];
    //设置播放的集合
    [self.mpc setQueueWithItemCollection:mic];
    
    _albumArray = [self sortByalbumOrArtist:YES];
    _sortedArray = [self newSortedMusicList:_albumArray];
}


-(NSMutableArray *)sortByalbumOrArtist:(BOOL) y{
   NSMutableArray* sortByAlbumArray = [[NSMutableArray alloc] init];
   
    for ( MPMediaItem *item in self.items) {
        NSString *albumName;
        if (y) {
            albumName =[item valueForProperty:MPMediaItemPropertyArtist];
        }
        else{
            albumName =[item valueForProperty:MPMediaItemPropertyAlbumTitle];
        }
        
        if (![sortByAlbumArray containsObject:albumName]) {
            [sortByAlbumArray addObject:albumName];
        }
    }
    return sortByAlbumArray;
    
}


-(NSMutableArray *)newSortedMusicList:(NSMutableArray *) array{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    for (NSString *sortName in array) {
        NSMutableArray *subArray = [[NSMutableArray alloc]init];
        for (MPMediaItem *item in self.items) {
            if ([[item valueForProperty:MPMediaItemPropertyArtist] isEqualToString:sortName]) {
                [subArray addObject:item];
            }
        }
        [newArray addObject:subArray];
    }
    return newArray;
}

-(void)reload{
    //音乐播放完成刷新table
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return  [self sortByalbumOrArtist:YES].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSMutableArray *subArray = [_sortedArray objectAtIndex:section];
    return subArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *CellIdentifier = @"MusicCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MPMediaItem *item = [[_sortedArray objectAtIndex:section] objectAtIndex:row];
    
//    MPMediaItem *item = self.items[indexPath.row];
    //获得专辑对象
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    //专辑封面
    UIImage *img = [artwork imageWithSize:CGSizeMake(100, 100)];
    if (!img) {
        img = [UIImage imageNamed:@"musicImage.png"];
    }
    cell.imageView.image = img;
   
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];         //歌曲名称
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];  //歌手名称
    if (self.mpc.nowPlayingItem == self.items[indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *provincName = [_albumArray objectAtIndex:section] ;
    return provincName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    //设置播放选中的歌曲
    [self.mpc setNowPlayingItem:self.items[indexPath.row]];
    [self.mpc play];
    
    [self.tableView reloadData];
}




-(NSString *)dataFilePath {
    NSArray * myPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory,
                                                             NSUserDomainMask, YES); NSString * myDocPath = [myPaths objectAtIndex:0];
    NSString *filename = [myDocPath stringByAppendingPathComponent:DATA_FILE];
    return filename;
}



#pragma mark -- sqllite method

//-(NSMutableArray*)selectAll
//{
//    NSMutableArray *list = [[NSMutableArray alloc] initWithObjects:nil];;
//	NSString *filename = [self dataFilePath];
//	NSLog(@"%@",filename);
//	if (sqlite3_open([filename UTF8String], &db) != SQLITE_OK) {
//		sqlite3_close(db);
//		NSAssert(NO,@"数据库打开失败。");
//	} else {
//		
//		NSString *qsql = [NSString stringWithFormat: @"SELECT %@ FROM %@", MUSIC_NAME, TABLE_NAME];
//		NSLog(@"%@",qsql);
//		sqlite3_stmt *statement;
//		//预处理过程
//		if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
//			//绑定参数开始
//			sqlite3_bind_text(statement, 1, [studentId.text UTF8String], -1, NULL);
//			
//			//执行
//			while (sqlite3_step(statement) == SQLITE_ROW) {
//				char *field1 = (char *) sqlite3_column_text(statement, 0);
//				NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
//				//studentId.text = field1Str;
//				//[field1Str release];
//                [list addObject:field1Str];
//                NSLog(@"%d",list.count);
//                
//			}
//		}
//		
//		sqlite3_finalize(statement);
//		sqlite3_close(db);
//		
//	}
//    return list;
//}


-(void)reloadTableViewDataSource
{
    [self.tableView reloadData];
    _reloading = YES;
}
- (void)doneLoadingTableViewData{
    
    NSLog(@"===加载完数据");
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    
}
#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
    
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

@end
