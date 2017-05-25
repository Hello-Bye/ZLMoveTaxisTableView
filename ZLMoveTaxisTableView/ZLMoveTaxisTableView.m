//
//  ZLMoveTaxisTableView.m
//  ZLMoveTaxisTableViewDemo
//
//  Created by GeekZooStudio on 2017/5/24.
//  Copyright © 2017年 personal. All rights reserved.
//

#import "ZLMoveTaxisTableView.h"
#import "UIView+Additions.h"

@interface ZLMoveTaxisTableView ()
@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;
@property (nonatomic, weak) UIView *tempMovingCell;
@property (nonatomic, strong) CADisplayLink *link;

@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) BOOL isOneSection;
@end

@implementation ZLMoveTaxisTableView

@dynamic dataSource;
@dynamic delegate;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self viewInitialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self viewInitialization];
    }
    return self;
}

- (void)viewInitialization {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableviewLongPressAction:)];
    [self addGestureRecognizer:longPress];
}

#pragma mark 长按手势处理 - 实现长按拖动cell交换位置

- (void)tableviewLongPressAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:self];
    NSLog(@"手指移动到 - %f", point.y);
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self longPressBegan:point];
    } else if (longPress.state == UIGestureRecognizerStateChanged) {
        [self longPressChanged:point];
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self longPressEnd:point];
    }
}

- (void)longPressBegan:(CGPoint)point {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    NSLog(@"长按手势开始 - %ld", indexPath.row);
    // 记录选中的cell的index
    self.selectedCellIndexPath = indexPath;
    // 隐藏cell，利用截图的以假乱真效果实现拖动
    UITableViewCell *selectedCell = [self cellForRowAtIndexPath:self.selectedCellIndexPath];
    
    UIGraphicsBeginImageContextWithOptions(selectedCell.frame.size, NO, 0.0);
    [selectedCell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *tempMovingCell = [[UIImageView alloc] initWithImage:img];
    tempMovingCell.frame = selectedCell.frame;
    [self addSubview:tempMovingCell];
    self.tempMovingCell = tempMovingCell;
    [UIView animateWithDuration:0.25 animations:^{
        tempMovingCell.transform = CGAffineTransformMakeScale(1.1, 1.1);
        tempMovingCell.centerY = point.y;
    }];
    
    selectedCell.hidden = YES;
    
    // 通过代理方法判断是否只有一组
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        if ([self.dataSource numberOfSectionsInTableView:self] == 1) {
            self.isOneSection = YES;
        } else {
            self.isOneSection = NO;
        }
    } else {
        self.isOneSection = YES;
    }
    
    // 获取数据源
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceInTableView:)]) {
        self.datas = [self.dataSource dataSourceInTableView:self];
    }
    
    // 开启边缘滚动监听
    [self startMarginScrollTimer];
}

- (void)longPressChanged:(CGPoint)point {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    if (indexPath && ![indexPath isEqual:self.selectedCellIndexPath]) {
        // 交换数据源
        if (self.isOneSection) {
            [self.datas exchangeObjectAtIndex:self.selectedCellIndexPath.row withObjectAtIndex:indexPath.row];
            // 移动cell
            [self beginUpdates];
            [self moveRowAtIndexPath:self.selectedCellIndexPath toIndexPath:indexPath];
            [self endUpdates];
        } else {
            // 多组情况 如果实现了代理方法，调用代理方法
            // 通知代理 交换数据源并移动cell
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willChangeDataSource:source:destination:)]) {
                self.datas = [self.delegate tableView:self willChangeDataSource:self.datas source:self.selectedCellIndexPath destination:indexPath];
                // 交换完之后要重置选中的cell的index
                self.selectedCellIndexPath = indexPath;
            } else {
                // 如果组是数组类型，直接交换，如果是组是自定义model并且没有实现代理方法
                if ([self.datas[indexPath.section] isKindOfClass:[NSMutableArray class]]) {
                    
                    if (indexPath.section == self.selectedCellIndexPath.section) {
                        // 同一组 直接交换
                        NSMutableArray *arrM = self.datas[indexPath.section];
                        [arrM exchangeObjectAtIndex:self.selectedCellIndexPath.row withObjectAtIndex:indexPath.row];
                    } else {
                        // 不同一组，需要将选中的数据源从原来的组里删除，再插入到新的组里，不交换
                        NSMutableArray *sourceSectionM = self.datas[self.selectedCellIndexPath.section];
                        NSMutableArray *descSectionM = self.datas[indexPath.section];
                        id sourceItem = sourceSectionM[self.selectedCellIndexPath.row];
                        [descSectionM insertObject:sourceItem atIndex:indexPath.row];
                        [sourceSectionM removeObjectAtIndex:self.selectedCellIndexPath.row];
                    }
                    // 移动cell
                    [self beginUpdates];
                    [self moveRowAtIndexPath:self.selectedCellIndexPath toIndexPath:indexPath];
                    [self endUpdates];
                }
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didChangeDataSource:)]) {
            [self.delegate tableView:self didChangeDataSource:self.datas];
        }
    }
    self.tempMovingCell.centerY = point.y;
}

- (void)longPressEnd:(CGPoint)point {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    NSLog(@"长按手势结束 - %ld", indexPath.row);
    // 手势结束 移除截图view  显示真实cell
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.selectedCellIndexPath];
    [UIView animateWithDuration:0.1 animations:^{
        self.tempMovingCell.transform = CGAffineTransformIdentity;
        self.tempMovingCell.frame = cell.frame;
    } completion:^(BOOL finished) {
        [self.tempMovingCell removeFromSuperview];
        cell.hidden = NO;
    }];
    
    // 停止边缘滚动监听
    [self stopMarginScrollTimer];
}

- (void)startMarginScrollTimer {
    // 定时，CADisplayLink比较NSTimer, CADisplayLink时间间隔不可变，与屏幕刷新间隔一样1/60秒一次
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(startMarginScorll)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMarginScrollTimer {
    [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.link invalidate];
    self.link = nil;
}

- (void)startMarginScorll {
    // 边缘滚动 靠近屏幕上下50开始滚动
    CGFloat marginScrollConst = 50.0;
    CGFloat topMarginScrollY = self.contentOffset.y + marginScrollConst;
    CGFloat bottomMarginScrollY = self.contentOffset.y + self.height - marginScrollConst;
    
    CGPoint touchPoint = self.tempMovingCell.center;
    // 这里还需要先判断一下tableview是否已经滚动到最顶部或最底部，
    if (touchPoint.y <= 0 + marginScrollConst || touchPoint.y >= self.contentSize.height - marginScrollConst) {
        if (self.contentOffset.y <= 0) {
            return;
        }
        if (self.contentOffset.y >= self.contentSize.height - self.height) {
            return;
        }
    }
    // 顶部需要滚动
    // 最大滚动速度为10
    CGFloat maxScrollSpeed = 10;
    if (touchPoint.y < topMarginScrollY) {
        // 变速滚动，越靠近边缘滚动速度越快
        CGFloat scrollSpeed = (topMarginScrollY - touchPoint.y) / marginScrollConst * maxScrollSpeed;
        // contentOffset.y 越小越往下滚动  注意： 这里animated不能为YES, 否则tableview不会滚动， 👇底部滚动时同理
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y -  scrollSpeed) animated:NO];
        // 这里为了让拖动的cell和tablev同步滚动，所以y值+-数值一定要一样，数值越大，滚动越快， 👇底部滚动时同理
        [self longPressChanged:CGPointMake(touchPoint.x, touchPoint.y - scrollSpeed)];
    }
    
    // 底部需要滚动
    if (touchPoint.y > bottomMarginScrollY) {
        // 变速滚动，越靠近边缘滚动速度越快
        CGFloat scrollSpeed = (touchPoint.y - bottomMarginScrollY) / marginScrollConst * maxScrollSpeed;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y +  scrollSpeed) animated:NO];
        [self longPressChanged:CGPointMake(touchPoint.x, touchPoint.y + scrollSpeed)];
    }
}

@end
