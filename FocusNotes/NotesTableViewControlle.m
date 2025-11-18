
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

@interface NotesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property(strong,nonatomic) NSMutableArray *notes;



@end
@implementation NotesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 80.0;
       // 设置导航栏
    self.title = @"笔记";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
           target:self
           action:@selector(addNewNote)];
    //self.notes = [[[NoteModel alloc]init]notes];
    [self loadNotesFromUserDefaults];
}

- (void)addNewNote {
    // 传递 nil 表示新建笔记
    [self performSegueWithIdentifier:@"showNoteDetail" sender:nil];
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
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
    [cell configCell:[self.notes objectAtIndex:indexPath.row]];
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
    [self saveNotesToUserDefaults];
    
}
//设置删除的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    return @"删除";
}

// 新增：从 NSUserDefaults 加载数据
- (void)loadNotesFromUserDefaults {
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
                [weakSelf saveNotesToUserDefaults];
                [weakSelf.tableView reloadData];
            };
        } else if ([sender isKindOfClass:[NoteModel class]]) {
            // 编辑模式
            detail.mode = NoteDetailModeEdit;
            detail.noteToEdit = (NoteModel *)sender;
            detail.onSave = ^(NoteModel *note, BOOL isNew) {
                // 已在原对象上修改，直接保存并刷新
                [weakSelf saveNotesToUserDefaults];
                [weakSelf.tableView reloadData];
            };
        }
    }
}







@end
