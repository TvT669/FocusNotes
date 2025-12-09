//
//  NotesTableViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "NotesTableViewController.h"
#import "NoteModel.h"
#import "NoteTableViewCell.h"
#import "NoteDetailViewController.h"

#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]

@interface NotesTableViewController ()
// 便利贴颜色数组
@property (nonatomic, strong) NSArray<UIColor *> *noteColors;
@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // --- 1. 设置背景图 ---
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warm_bokeh_bg"]];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // --- 2. 配置 TableView ---
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);
    [self.tableView registerClass:[NoteTableViewCell class] forCellReuseIdentifier:@"NoteCell"];
    
    // --- 3. 配置导航栏 ---
    [self setupNavigationBar];
    
    // --- 4. 初始化数据 ---
    [self setupData];
    self.notes = [NSMutableArray array]; // 先初始化为空
    
    // 1. 先尝试加载文件数据
    [self loadNotesFromDisk];
    
    // 2. 数据恢复与迁移逻辑
    NSArray *oldData = [[NSUserDefaults standardUserDefaults] arrayForKey:@"notesArray"];
    BOOL hasOldData = (oldData && oldData.count > 0);
    BOOL isEmpty = (self.notes.count == 0);
    BOOL isMockData = NO;
    
    if (self.notes.count == 1) {
        NoteModel *n = self.notes.firstObject;
        if ([n.titleName isEqualToString:@"第一篇笔记"] && [n.contentText isEqualToString:@"写下你的第一篇笔记内容"]) {
            isMockData = YES;
        }
    }
    
    // 如果 (当前为空 OR 是模拟数据) AND (有旧数据) -> 执行迁移
    if ((isEmpty || isMockData) && hasOldData) {
        NSLog(@"[Data Recovery] 检测到可能的数据丢失，尝试从 UserDefaults 恢复数据...");
        [self migrateFromUserDefaultsToFile];
    }
    
    // 3. 如果最终还是没数据（既没文件，也没旧数据），加载模拟数据
    if (self.notes.count == 0) {
        NoteModel *factory = [[NoteModel alloc] init];
        if (factory.notes.count > 0) {
            [self.notes addObjectsFromArray:factory.notes];
            [self.tableView reloadData];
            [self saveNotesToDisk]; // 保存模拟数据
        }
    }
}

- (void)setupNavigationBar {
    self.title = @"笔记";
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: kWarmCoffeeColor,
        NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold]
    };
    
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewNote)];
    addBtn.tintColor = kWarmCoralColor;
    self.navigationItem.rightBarButtonItem = addBtn;
}

- (void)setupData {
    self.noteColors = @[
        [UIColor colorWithRed:255/255.0 green:245/255.0 blue:208/255.0 alpha:1.0], // 黄
        [UIColor colorWithRed:217/255.0 green:240/255.0 blue:211/255.0 alpha:1.0], // 绿
        [UIColor colorWithRed:250/255.0 green:212/255.0 blue:212/255.0 alpha:1.0], // 粉
        [UIColor colorWithRed:253/255.0 green:246/255.0 blue:232/255.0 alpha:1.0]  // 米白
    ];
}

- (void)addNewNote {
    [self performSegueWithIdentifier:@"showNoteDetail" sender:nil];
}

- (void)openCreateNote {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addNewNote];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    NoteModel *note = self.notes[indexPath.row];
    UIColor *bgColor = self.noteColors[indexPath.row % self.noteColors.count];
    [cell configCell:note backgroundColor:bgColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NoteModel *selectedNote = self.notes[indexPath.row];
    NSLog(@"选中了笔记: %@", selectedNote.titleName);
    [self performSegueWithIdentifier:@"showNoteDetail" sender:selectedNote];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.notes removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 使用新保存方法
    [self saveNotesToDisk];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showNoteDetail"]) {
        NoteDetailViewController *detail = (NoteDetailViewController *)segue.destinationViewController;
        __weak typeof(self) weakSelf = self;
        if (sender == nil) {
            // 新建模式
            detail.mode = NoteDetailModeCreate;
            detail.noteToEdit = nil;
            detail.onSave = ^(NoteModel *note, BOOL isNew) {
                if (isNew) {
                    [weakSelf.notes insertObject:note atIndex:0];
                }
                [weakSelf saveNotesToDisk];
                [weakSelf.tableView reloadData];
            };
        } else if ([sender isKindOfClass:[NoteModel class]]) {
            // 编辑模式
            detail.mode = NoteDetailModeEdit;
            detail.noteToEdit = (NoteModel *)sender;
            detail.onSave = ^(NoteModel *note, BOOL isNew) {
                [weakSelf saveNotesToDisk];
                [weakSelf.tableView reloadData];
            };
        }
    }
}

#pragma mark - Data Persistence (File System)

// 文件路径辅助方法
- (NSString *)dataFilePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docPath stringByAppendingPathComponent:@"notes.data"];
}

// 保存数据到磁盘
- (void)saveNotesToDisk {
    NSString *path = [self dataFilePath];
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:NO error:&error];
    
    if (data) {
        BOOL success = [data writeToFile:path atomically:YES];
        if (success) {
            NSLog(@"笔记已保存到文件: %@", path);
        } else {
            NSLog(@"写入文件失败");
        }
    } else {
        NSLog(@"归档失败: %@", error);
    }
}

// 从磁盘加载数据
- (void)loadNotesFromDisk {
    NSString *path = [self dataFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"本地没有 notes.data 文件");
        self.notes = [NSMutableArray array];
        return;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSArray *savedNotes = nil;
        if (@available(iOS 11.0, *)) {
            NSSet *classes = [NSSet setWithObjects:[NSArray class], [NoteModel class], nil];
            savedNotes = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
        }
        if (!savedNotes) {
            savedNotes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        
        if (savedNotes) {
            self.notes = [NSMutableArray arrayWithArray:savedNotes];
            NSLog(@"成功从磁盘加载 %lu 条笔记", (unsigned long)self.notes.count);
            [self.tableView reloadData];
        } else {
            NSLog(@"解档失败，数据可能损坏: %@", error);
        }
    }
}

// 迁移工具方法
- (void)migrateFromUserDefaultsToFile {
    NSString *oldKey = @"notesArray";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *oldData = [defaults arrayForKey:oldKey];
    
    if (oldData && oldData.count > 0) {
        NSLog(@"[Migration] 发现旧版本数据 (共 %lu 条)，准备迁移到文件...", (unsigned long)oldData.count);
        
        NSMutableArray *migratedNotes = [NSMutableArray array];
        for (NSDictionary *dict in oldData) {
            NoteModel *note = [[NoteModel alloc] init];
            
            // 标题
            id title = dict[@"titleName"];
            if ([title isKindOfClass:[NSString class]]) {
                note.titleName = title;
            } else {
                note.titleName = [title description] ?: @"无标题";
            }
            
            // 内容
            id content = dict[@"contentText"];
            if ([content isKindOfClass:[NSString class]]) {
                note.contentText = content;
            } else {
                note.contentText = [content description] ?: @"";
            }
            
            // 日期
            id date = dict[@"dateText"];
            if ([date isKindOfClass:[NSDate class]]) {
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm";
                note.dateText = [fmt stringFromDate:(NSDate *)date];
            } else if ([date isKindOfClass:[NSString class]]) {
                note.dateText = date;
            } else {
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm";
                note.dateText = [fmt stringFromDate:[NSDate date]];
            }
            
            [migratedNotes addObject:note];
        }
        
        // 保存迁移后的数据
        NSString *path = [self dataFilePath];
        NSError *error = nil;
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:migratedNotes requiringSecureCoding:NO error:&error];
        
        if (archivedData && [archivedData writeToFile:path atomically:YES]) {
            NSLog(@"[Migration] 迁移成功！数据已保存到: %@", path);
            self.notes = migratedNotes;
            [self.tableView reloadData];
            
            // 标记已迁移
            [defaults setBool:YES forKey:@"hasMigratedToFiles"];
            [defaults synchronize];
        } else {
            NSLog(@"[Migration] 迁移失败: %@", error);
        }
    } else {
        NSLog(@"[Migration] UserDefaults 里没有旧数据，无需迁移");
        [defaults setBool:YES forKey:@"hasMigratedToFiles"];
        [defaults synchronize];
    }
}

@end
