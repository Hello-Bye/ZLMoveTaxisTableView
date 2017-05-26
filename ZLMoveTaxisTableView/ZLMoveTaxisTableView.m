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
    
    // 初始化默认设置
    self.maxScrollSpeed = 10;
    self.marginScrollDistance = 50;
}

#pragma mark 长按手势处理 - 实现长按拖动cell交换位置

- (void)tableviewLongPressAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:self];
//    NSLog(@"手指移动到 - %f", point.y);
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self longPressBegan:point];
    } else if (longPress.state == UIGestureRecognizerStateChanged) {
        [self longPressChanged:point];
    } else if (longPress.state == UIGestureRecognizerStateEnded ||
               longPress.state == UIGestureRecognizerStateCancelled) {
        [self longPressEnd:point];
    }
}

- (void)longPressBegan:(CGPoint)point {
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    // 记录选中的cell的index
    self.selectedCellIndexPath = indexPath;
    
    // 将要开始移动，获取数据源
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(dataSourceInTableView:)]) {
        self.datas = [self.dataSource dataSourceInTableView:self].mutableCopy;
    }
    
    // 通知代理，将要开始移动
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:beginMoveCellAtIndexPath:)]) {
        [self.delegate tableView:self beginMoveCellAtIndexPath:self.selectedCellIndexPath];
    }
    
    // 通过数据源方法判断是否只有一组
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        if ([self.dataSource numberOfSectionsInTableView:self] == 1) {
            self.isOneSection = YES;
        } else {
            self.isOneSection = NO;
        }
    } else {
        self.isOneSection = YES;
    }
    
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
    
    // 开启边缘滚动监听
    [self startMarginScrollTimer];
}

- (void)longPressChanged:(CGPoint)point {
    self.tempMovingCell.centerY = point.y;
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    if (indexPath && ![indexPath isEqual:self.selectedCellIndexPath]) {
        // 交换数据源
        if (self.isOneSection) {
            // 只有一组，直接交换
            [self.datas exchangeObjectAtIndex:self.selectedCellIndexPath.row withObjectAtIndex:indexPath.row];
            // 移动cell
            [self beginUpdates];
            [self moveRowAtIndexPath:self.selectedCellIndexPath toIndexPath:indexPath];
            [self endUpdates];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didMoveCellNewIndexPath:oldIndexPath:)]) {
                [self.delegate tableView:self didMoveCellNewIndexPath:indexPath oldIndexPath:self.selectedCellIndexPath];
            }
            self.selectedCellIndexPath = indexPath;
        } else {
            // 多组情况, 要先交换数据源，再移动cell，否则会crash
            if ([self.datas[indexPath.section] isKindOfClass:[NSMutableArray class]]) {
                if (indexPath.section == self.selectedCellIndexPath.section) {
                    // 同一组 直接交换
                    NSMutableArray *arrM = self.datas[indexPath.section];
                    [arrM exchangeObjectAtIndex:self.selectedCellIndexPath.row withObjectAtIndex:indexPath.row];
                } else {
                    // 不同一组，需要将选中的数据源从原来的组里删除，再插入到新的组里，不交换
                    NSMutableArray *sourceSectionM = self.datas[self.selectedCellIndexPath.section];
                    NSMutableArray *destSectionM = self.datas[indexPath.section];
                    
                    id sourceItem = sourceSectionM[self.selectedCellIndexPath.row];
                    [destSectionM insertObject:sourceItem atIndex:indexPath.row];
                    [sourceSectionM removeObjectAtIndex:self.selectedCellIndexPath.row];
                }
                
                // 移动cell
                [self beginUpdates];
                [self moveRowAtIndexPath:self.selectedCellIndexPath toIndexPath:indexPath];
                [self endUpdates];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didMoveCellNewIndexPath:oldIndexPath:)]) {
                    [self.delegate tableView:self didMoveCellNewIndexPath:indexPath oldIndexPath:self.selectedCellIndexPath];
                }
                self.selectedCellIndexPath = indexPath;
            }
        }
        
        // 交换之后新的数据源传回去
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:newDataSource:)]) {
            [self.dataSource tableView:self newDataSource:self.datas.copy];
        }
    }
}

- (void)longPressEnd:(CGPoint)point {
    // 停止边缘滚动监听
    [self stopMarginScrollTimer];
    
    // 手势结束 移除截图view  显示真实cell
    UITableViewCell *cell = [self cellForRowAtIndexPath:self.selectedCellIndexPath];
    [UIView animateWithDuration:0.1 animations:^{
        self.tempMovingCell.transform = CGAffineTransformIdentity;
        self.tempMovingCell.frame = cell.frame;
    } completion:^(BOOL finished) {
        [self.tempMovingCell removeFromSuperview];
        cell.hidden = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:endMoveCellAtIndexPath:)]) {
            [self.delegate tableView:self endMoveCellAtIndexPath:self.selectedCellIndexPath];
        }
    }];
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
    // 边缘滚动
    CGFloat topMarginScrollY = self.contentOffset.y + self.marginScrollDistance;
    CGFloat bottomMarginScrollY = self.contentOffset.y + self.height - self.marginScrollDistance;
    
    CGPoint touchPoint = self.tempMovingCell.center;
    // 这里还需要先判断一下tableview是否已经滚动到最顶部或最底部，
    if (touchPoint.y <= 0-self.contentInset.top + self.marginScrollDistance || touchPoint.y >= self.contentSize.height - self.marginScrollDistance) {
        if (self.contentOffset.y <= 0-self.contentInset.top) {
            return;
        }
        if (self.contentOffset.y >= self.contentSize.height - self.height) {
            return;
        }
    }
    // 顶部需要滚动
    if (touchPoint.y < topMarginScrollY) {
        // 变速滚动，越靠近边缘滚动速度越快
        CGFloat scrollSpeed = (topMarginScrollY - touchPoint.y) / self.marginScrollDistance * self.maxScrollSpeed;
        // contentOffset.y 越小越往下滚动  注意： 这里animated不能为YES, 否则tableview不会滚动， 👇底部滚动时同理
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y -  scrollSpeed) animated:NO];
        // 这里为了让拖动的cell和tablev同步滚动，所以y值 +- 数值一定要一样，数值越大，滚动越快， 👇底部滚动时同理
        [self longPressChanged:CGPointMake(touchPoint.x, touchPoint.y - scrollSpeed)];
    }
    
    // 底部需要滚动
    if (touchPoint.y > bottomMarginScrollY) {
        // 变速滚动，越靠近边缘滚动速度越快
        CGFloat scrollSpeed = (touchPoint.y - bottomMarginScrollY) / self.marginScrollDistance * self.maxScrollSpeed;
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y +  scrollSpeed) animated:NO];
        [self longPressChanged:CGPointMake(touchPoint.x, touchPoint.y + scrollSpeed)];
    }
}

@end
