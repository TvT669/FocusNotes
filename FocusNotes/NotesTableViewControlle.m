
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
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property(strong,nonatomic) NSMutableArray *notes;
// 便利贴颜色数组
@property (nonatomic, strong) NSArray<UIColor *> *noteColors;

@end
@implementation NotesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // --- 1. 设置背景图 ---
    // 创建一个 UIImageView 来显示背景图
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warm_bokeh_bg"]];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    // 将背景图设置为 TableView 的背景视图
    self.tableView.backgroundView = bgImageView;
    self.tableView.backgroundColor = [UIColor clearColor]; // 确保 TableView 本身透明

    
    // --- 2. 配置 TableView ---
    // 移除固定行高，让 Auto Layout 自动计算卡片高度
    // self.tableView.rowHeight = 80.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100; // 给一个估算值
    
    // 去掉分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 增加一点顶部和底部的内边距，让第一个和最后一个 Cell 不贴边
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);

    // 如果你的 Cell 原来是在 Storyboard 里定义的，现在可能需要用代码注册一下
     [self.tableView registerClass:[NoteTableViewCell class] forCellReuseIdentifier:@"NoteCell"];

    // --- 3. 配置导航栏 ---
    [self setupNavigationBar];

    // --- 4. 初始化数据 ---
    [self setupData];
    self.notes = [NSMutableArray array];
    // 1. 先尝试加载文件数据
    [self loadNotesFromDisk];
    
    // 2. 检查是否已经迁移过
    BOOL hasMigrated = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasMigratedToFiles"];
    
    // 3. 只有当“没迁移过”且“本地没数据”时，才尝试迁移
    if (!hasMigrated && self.notes.count == 0) {
        [self migrateFromUserDefaultsToFile];
        
        // 4. 如果迁移尝试后数据仍为空，说明是全新安装，加载模拟数据
        if (self.notes.count == 0) {
            NoteModel *factory = [[NoteModel alloc] init];
            if (factory.notes.count > 0) {
                [self.notes addObjectsFromArray:factory.notes];
                [self.tableView reloadData];
                [self saveNotesToDisk]; // 保存模拟数据，使其持久化
            }
        }
    }
   // [self loadNotesFromUserDefaults];
}

- (void)setupNavigationBar {
    self.title = @"笔记";
    // 设置标题属性 (深咖啡色圆体字)
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: kWarmCoffeeColor,
        // 如果能获取到圆体字最好，否则用系统粗体
        NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold]
    };

    // 设置右侧加号按钮，并染成珊瑚色
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewNote)];
    addBtn.tintColor = kWarmCoralColor;
    self.navigationItem.rightBarButtonItem = addBtn;
    
    // 可选：设置导航栏背景透明
    // [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    // self.navigationController.navigationBar.shadowImage = [UIImage new];
    // self.navigationController.navigationBar.translucent = YES;
}

- (void)setupData {
    // 初始化便利贴颜色数组 (柔和的黄、绿、粉、米白)
    self.noteColors = @[
        [UIColor colorWithRed:255/255.0 green:245/255.0 blue:208/255.0 alpha:1.0], // 黄
        [UIColor colorWithRed:217/255.0 green:240/255.0 blue:211/255.0 alpha:1.0], // 绿
        [UIColor colorWithRed:250/255.0 green:212/255.0 blue:212/255.0 alpha:1.0], // 粉
        [UIColor colorWithRed:253/255.0 green:246/255.0 blue:232/255.0 alpha:1.0]  // 米白
    ];
}

- (void)addNewNote {
    // 传递 nil 表示新建笔记
    [self performSegueWithIdentifier:@"showNoteDetail" sender:nil];
}

// 对外公开的方法：从其他页面触发新建笔记
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
    //return self.titles.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
        
        // 获取笔记模型
        NoteModel *note = self.notes[indexPath.row];
        
        // 循环获取背景色 (使用取模运算符 %)
        UIColor *bgColor = self.noteColors[indexPath.row % self.noteColors.count];
        
        // 使用新的配置方法
        [cell configCell:note backgroundColor:bgColor];
        
        return cell;
    
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 处理单元格点击事件
    NoteModel *selectedNote = self.notes[indexPath.row];
    NSLog(@"选中了笔记: %@", selectedNote.titleName);
    //触发跳转
    [self performSegueWithIdentifier:@"showNoteDetail" sender:selectedNote];
    
    // 这里可以跳转到详情页面
}
//该行能不能编辑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}
//提交编辑
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.notes removeObjectAtIndex:indexPath.row];
    
    [tableView  deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 删除后持久化
    //[self saveNotesToUserDefaults];
    [self saveNotesToDisk];
    
}
//设置删除的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    return @"删除";
}

// 新增：从 NSUserDefaults 加载数据
/*- (void)loadNotesFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *notesDicts = [defaults arrayForKey:@"notesArray"];
    
    if (notesDicts && notesDicts.count > 0) {
        self.notes = [NSMutableArray array];
        for (NSDictionary *dict in notesDicts) {
            NoteModel *note = [[NoteModel alloc] init];
            note.titleName = dict[@"titleName"] ?: @"新笔记"; 
            note.contentText = dict[@"contentText"];
            note.dateText = dict[@"dateText"]; // 自动转换为 NSDate
            [self.notes addObject:note];
        }
    } else {
        // 没有数据时用模拟数据
        self.notes = [[[NoteModel alloc] init] notes];
    }
}

// 新增：保存数据到 NSUserDefaults
- (void)saveNotesToUserDefaults {
    NSMutableArray *notesDicts = [NSMutableArray array];
    for (NoteModel *note in self.notes) {
        NSDictionary *noteDict = @{
            @"titleName": note.titleName,
            @"contentText": note.contentText,
            @"dateText": note.dateText
        };
        [notesDicts addObject:noteDict];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:notesDicts forKey:@"notesArray"];
    [defaults synchronize]; // 立即写入磁盘
    // 获取 Bundle Identifier
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    // 拼接 plist 路径
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Preferences/%@.plist", bundleID]];
    NSLog(@"[FocusNotes] 笔记数据文件保存路径: %@", plistPath);
}
*/
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
               // [weakSelf saveNotesToUserDefaults];
                [weakSelf saveNotesToDisk];
                [weakSelf.tableView reloadData];
            };
        } else if ([sender isKindOfClass:[NoteModel class]]) {
            // 编辑模式
            detail.mode = NoteDetailModeEdit;
            detail.noteToEdit = (NoteModel *)sender;
            detail.onSave = ^(NoteModel *note, BOOL isNew) {
                // 已在原对象上修改，直接保存并刷新
               //[weakSelf saveNotesToUserDefaults];
                [weakSelf saveNotesToDisk];
                [weakSelf.tableView reloadData];
            };
        }
    }
}

- (void)migrateFromUserDefaultsToFile {
    NSString *oldKey = @"notesArray"; // 你之前用的 Key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 1. 检查是否有旧数据
    NSArray *oldData = [defaults arrayForKey:oldKey];
    
    if (oldData && oldData.count > 0) {
        NSLog(@" 发现旧版本数据 (共 %lu 条)，准备迁移到文件...", (unsigned long)oldData.count);
        
        // 2. 将旧的字典数组转换为模型数组
        NSMutableArray *migratedNotes = [NSMutableArray array];
        for (NSDictionary *dict in oldData) {
            NoteModel *note = [[NoteModel alloc] init];
            note.titleName = dict[@"titleName"] ?: @"无标题";
            note.contentText = dict[@"contentText"] ?: @"";
            note.dateText = dict[@"dateText"];
            
            [migratedNotes addObject:note];
        }
        
        // 3. 保存到新的文件路径 (Documents/notes.data)
        // 获取文件路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"notes.data"];
        
        NSError *error = nil;
        // 使用 NSKeyedArchiver 归档
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:migratedNotes requiringSecureCoding:NO error:&error];
        
        if (archivedData) {
            BOOL success = [archivedData writeToFile:filePath atomically:YES];
            if (success) {
                NSLog(@"迁移成功！数据已保存到: %@", filePath);
                
                // 4. 读取到内存，刷新界面
                self.notes = migratedNotes;
                [self.tableView reloadData];
                //标记为已迁移
                [defaults setBool:YES forKey:@"hasMigratedToFiles"];
                [defaults synchronize];
                
                // 5. 【可选】删除旧数据 (建议确认迁移成功后再打开这行)
                // [defaults removeObjectForKey:oldKey];
                // [defaults synchronize];
                
            } else {
                NSLog(@"写入文件失败");
            }
        } else {
            NSLog(@"归档失败: %@", error);
        }
    } else {
        NSLog(@"UserDefaults 里没有旧数据，无需迁移");
        // 如果旧版本本来就没数据，也标记为已迁移，防止以后反复检查
        [defaults setBool:YES forKey:@"hasMigratedToFiles"];
        [defaults synchronize];
    }
}

// 文件路径辅助方法
- (NSString *)dataFilePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docPath stringByAppendingPathComponent:@"notes.data"];
}

// 从磁盘加载数据
- (void)loadNotesFromDisk {
    NSString *path = [self dataFilePath];
    
    // 检查文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"本地没有 notes.data 文件");
        self.notes = [NSMutableArray array]; // 初始化空数组
        return;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (data) {
        // 尝试解档
        NSArray *savedNotes = nil;
        
        // 1. 尝试用新式安全解码 (iOS 11+)
        if (@available(iOS 11.0, *)) {
            // 注意：这里需要告诉系统数组里装的是 NoteModel
            NSSet *classes = [NSSet setWithObjects:[NSArray class], [NoteModel class], nil];
            savedNotes = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
        }
        
        // 2. 如果新式解码失败，尝试旧式解码 (兼容性)
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

//保存数据到磁盘 (替代旧的 UserDefaults)
- (void)saveNotesToDisk {
    NSString *path = [self dataFilePath];
    NSError *error = nil;
    
    // 使用 NSKeyedArchiver 归档
    // requiringSecureCoding:NO 能最大程度兼容旧数据迁移过来的情况
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






@end
