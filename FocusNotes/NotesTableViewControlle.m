
//
//  NotesTableViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "NotesTableViewController.h"
#import "NoteModel.h"
#import "NoteTableViewCell.h"

@interface NotesTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *notes;



@end
@implementation NotesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 80.0;
       // 设置导航栏
    self.title = @"笔记";
    self.notes = [[[NoteModel alloc]init]notes];
}

-(void)addNotes{
    // 添加新笔记的方法，稍后可以连接到详情页面
       NSLog(@"添加新笔记");
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
    
}
//设置删除的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}



@end
