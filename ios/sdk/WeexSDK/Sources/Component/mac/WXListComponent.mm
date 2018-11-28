//
//  WXListComponent.m
//  WeexSDK MacOS
//
//  Created by zifan.zx on 2018/11/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

//#if WEEX_MAC
#import "WXListComponent.h"
#import "WXDefine.h"
#import "WXComponent+Layout.h"
#import "WXComponent_internal.h"
#import "WXCellComponent.h"
#import "NSArray+Weex.h"
#import "WXSDKInstance_private.h"
#import "WXAssert.h"
#import "WXComponent_internal.h"

@interface WXCellView:NSView
@end
@implementation WXCellView
@end

@interface WXListComponent()<NSTableViewDelegate, NSTableViewDataSource,WXCellRenderDelegate> {
    
    // vertical & horizontal
    WXScrollDirection _scrollDirection;
    BOOL _needsPlatformLayout;
    NSSize _contentSize;
    BOOL _isUpdating;
    NSTimeInterval _reloadInterval;
}

// Only accessed on component thread
@property (strong) NSMutableArray<WXCellComponent *> *cellComponents;
// Only accessed on main thread
@property (strong) NSMutableArray<WXCellComponent *> *cellComponentsCompleted;
@property (strong)NSTableView *tableView;
@property (strong)NSMutableArray<void(^)(void)> *updates;
@end

@implementation WXListComponent

#pragma mark private component life cycle

- (BOOL)_insertSubcomponent:(WXComponent *)subcomponent atIndex:(NSInteger)index
{
    if ([subcomponent isKindOfClass:[WXCellComponent class]]) {
        ((WXCellComponent *)subcomponent).delegate = self;
    }
    
    BOOL inserted = [super _insertSubcomponent:subcomponent atIndex:index];
    // If a vertical list is added to a horizontal scroller, we need platform dependent layout
    if (_flexCssNode && [self isKindOfClass:[WXListComponent class]] &&
        [subcomponent isKindOfClass:[WXListComponent class]] &&
        subcomponent->_positionType != WXPositionTypeFixed &&
        (((WXListComponent*)subcomponent)->_scrollDirection == WXScrollDirectionVertical)) {
        if (subcomponent->_flexCssNode) {
            if (subcomponent->_flexCssNode->getFlex() > 0 && !isnan(subcomponent->_flexCssNode->getStyleWidth())) {
                _needsPlatformLayout = YES;
                _flexCssNode->setNeedsPlatformDependentLayout(true);
            }
        }
    }
    if (![subcomponent isKindOfClass:[WXCellComponent class]]) {
        // Don't insert section if subcomponent is not header or cell
        return inserted;
    }
    
    return inserted;
}

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        // customization
        
        _scrollDirection = [self scrollDirection:attributes[@"scrollDirection"]];
        self->_reloadInterval = attributes[@"reloadInterval"] ? [WXConvert CGFloat:attributes[@"reloadInterval"]]/1000 : 0;
        self.cellComponents = [NSMutableArray new];
        self.cellComponentsCompleted = [NSMutableArray new];
    }
    return self;
}

- (NSView *)loadView
{
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.verticalScroller = [[NSScroller alloc] init]; // 垂直滚动条
    scrollView.hasVerticalScroller = YES;
    NSClipView *clipView = [NSClipView new];
    scrollView.contentView = clipView;
    self.tableView = [[NSTableView alloc] init];
    self.tableView.headerView = nil;
    NSTableColumn *colum = [[NSTableColumn alloc] initWithIdentifier:@"column"];
    colum.minWidth = 0;
    colum.maxWidth = 10000;
    [self.tableView addTableColumn:colum];
    clipView.documentView = self.tableView;
    
    return scrollView;
}

- (void)viewDidLoad
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _contentSize = _tableView.intrinsicContentSize;
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    self.tableView = nil;
}

- (void)dealloc
{
    self.tableView = nil;
}

#pragma mark tableView dataSource
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    WXCellComponent * cellComponent = [self cellForIndexPath:[NSIndexPath indexPathWithIndex:row] withComponents:self.cellComponentsCompleted];
    
    WXLogDebug(@"Getting cell at indexPath:%ld", row);
    WXCellView * cellView = [WXCellView new];
    
    if (!cellComponent) {
        return cellView;
    }
    
    if (cellComponent.view.superview == cellView) {
        return cellView;
    }
    
    cellView.frame = (CGRect){.origin = cellView.frame.origin,.size =cellComponent.calculatedFrame.size};
    
    [cellView addSubview:cellComponent.view];
    [cellView setAccessibilityIdentifier:cellComponent.view.accessibilityIdentifier];
    
    WXLogDebug(@"Created cell:%@ view:%@ cellView:%@ at indexPath:%ld", cellComponent.ref, cellComponent.view, cellView, row);
    return cellView;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    for (NSView* subview in ((NSView*)rowView.subviews[0]).subviews) {
        [subview.wx_component _unloadViewWithReusing:YES];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.cellComponentsCompleted count];
}

- (WXScrollDirection)scrollDirection:(NSString*)direction
{
    if ([direction isKindOfClass:[NSString class]]) {
        return [WXConvert WXScrollDirection:direction];
    }
    return WXScrollDirectionVertical;
}

- (NSIndexPath *)indexPathForSubIndex:(NSUInteger)index
{
//    NSInteger section = 0;
    NSInteger row = -1;
    WXComponent *firstComponent;
    for (int i = 0; i <= index; i++) {
        WXComponent* component = [self.subcomponents wx_safeObjectAtIndex:i];
        if (!component) {
            continue;
        }
        if (([component isKindOfClass:[WXCellComponent class]])
            && !firstComponent) {
            firstComponent = component;
        }
        
//        if (component != firstComponent && [component isKindOfClass:[WXHeaderComponent class]]) {
//            section ++;
//            row = -1;
//        }
        
        if ([component isKindOfClass:[WXCellComponent class]]) {
            row ++;
        }
    }
    

    return [NSIndexPath indexPathWithIndex:row];
}

#pragma mark Layout

- (CGFloat)_getInnerContentMainSize
{
    if (_scrollDirection == WXScrollDirectionVertical) {
        return self->_contentSize.height;
    }
    else if (_scrollDirection == WXScrollDirectionHorizontal) {
        return self->_contentSize.width;
    }
    else {
        return -1.0f;
    }
}

- (void)_assignInnerContentMainSize:(CGFloat)value
{
    if (_scrollDirection == WXScrollDirectionVertical) {
        _contentSize.height = value;
    }
    else if (_scrollDirection == WXScrollDirectionHorizontal) {
        _contentSize.width = value;
    }
}

- (void)_layoutPlatform
{
    /* Handle multiple vertical scrollers inside horizontal scroller case. In weexcore,
     a verticall list with NAN height will be set flex=1, which suppresses its style-width property.
     This will cause two lists with style-width 750px in a horizontal scroller sharing one screen width.
     Here we respect its style-width property so that the two lists will both be screen width wide. */
    
    if (_needsPlatformLayout) {
        if (_flexCssNode) {
            float top = _flexCssNode->getLayoutPositionTop();
            float left = _flexCssNode->getLayoutPositionLeft();
            float width = _flexCssNode->getLayoutWidth();
            float height = _flexCssNode->getLayoutHeight();
            
            if (_scrollDirection == WXScrollDirectionVertical) {
                _flexCssNode->setFlexDirection(WeexCore::kFlexDirectionColumn, NO);
                _flexCssNode->setStyleWidth(_flexCssNode->getLayoutWidth(), NO);
                _flexCssNode->setStyleHeight(FlexUndefined);
            } else {
                _flexCssNode->setFlexDirection(WeexCore::kFlexDirectionRow, NO);
                _flexCssNode->setStyleHeight(_flexCssNode->getLayoutHeight());
                _flexCssNode->setStyleWidth(FlexUndefined, NO);
            }
            _flexCssNode->markAllDirty();
            std::pair<float, float> renderPageSize;
            renderPageSize.first = self.weexInstance.frame.size.width;
            renderPageSize.second = self.weexInstance.frame.size.height;
            auto parent = _flexCssNode->getParent(); // clear parent temporarily
            _flexCssNode->setParent(nullptr, _flexCssNode);
            _flexCssNode->calculateLayout(renderPageSize);
            _flexCssNode->setParent(parent, _flexCssNode);
            
            // set origin and size back
            _flexCssNode->rewriteLayoutResult(left, top, width, height);
        }
    }
    else {
        // should not happen, set platform layout to false
        _flexCssNode->setNeedsPlatformDependentLayout(false);
    }
}

- (NSIndexPath*)indexPathForCell:(WXCellComponent*)cellComponent withCellComponents:(NSArray<WXCellComponent*>*)cellComponents
{
    __block NSIndexPath * indexpath = nil;
    [cellComponents enumerateObjectsUsingBlock:^(WXCellComponent * _Nonnull components, NSUInteger idx, BOOL * _Nonnull stop) {
        if (components == cellComponent) {
            indexpath = [NSIndexPath indexPathWithIndex:idx];
            *stop = YES;
        }
    }];
    return indexpath;
}

- (WXCellComponent *)cellForIndexPath:(NSIndexPath *)indexPath withComponents:(NSMutableArray<WXCellComponent *>*)cellComponents
{
    if (!cellComponents) {
        WXLogError(@"No section found for num:%ld, completed sections:%ld", (long)([indexPath indexAtPosition:0]), (unsigned long)[cellComponents count]);
        return nil;
    }
    
    WXCellComponent *cell = [cellComponents wx_safeObjectAtIndex:[indexPath indexAtPosition:0]];
    if (!cell) {
        WXLogError(@"No cell found for num:%ld, completed rows:%ld", (long)([indexPath indexAtPosition:0]), (unsigned long)[cellComponents count]);
        return nil;
    }
    
    return cell;
}

#pragma mark cell delegate
- (void)cellDidRemove:(WXCellComponent *)cell
{
    WXAssertComponentThread();
    
    NSIndexPath *indexPath = [self indexPathForCell:cell withCellComponents:self.cellComponents];
    if(!indexPath){
        //protect when cell not exist in sections
        return;
    }
    [self removeCellForIndexPath:indexPath withCellComponents:self.cellComponents];
    
    __weak typeof(self) weakSelf = self;
    [self.weexInstance.componentManager _addUITask:^{
        [weakSelf removeCellForIndexPath:indexPath withCellComponents:self.cellComponentsCompleted];
        
        WXLogDebug(@"Delete cell:%@ at indexPath:%@", cell.ref, indexPath);
        @try {
            [weakSelf.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[indexPath indexAtPosition:0]] withAnimation:NSTableViewAnimationEffectFade];
        } @catch (NSException* e) {
        }
    }];
}

- (void)cellDidLayout:(WXCellComponent *)cell
{
    WXAssertComponentThread() ;
    
    NSUInteger index = [self.subcomponents indexOfObject:cell];
    NSIndexPath *indexPath = [self indexPathForSubIndex:index];
    
    NSInteger indexPathRow = [indexPath indexAtPosition:0];
    if (indexPathRow > [self.cellComponents count]) {
        // try to protect sectionNum out of range.
        return;
    }
    
    NSMutableArray *completedCellComponents;
    BOOL isReload = [self.cellComponents containsObject:cell];
    if (!isReload && indexPathRow > [self.cellComponents count]) {
        // protect crash when row out of bounds
        return ;
    }
    if (!isReload) {
        [self.cellComponents insertObject:cell atIndex:indexPathRow];
        // deep copy
        completedCellComponents = [self.cellComponents mutableCopy];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.weexInstance.componentManager _addUITask:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!isReload) {
            WXLogDebug(@"Insert cell:%@ at indexPath:%@", cell.ref, indexPath);
            strongSelf.cellComponentsCompleted = completedCellComponents;
            // catch system exception under 11.2 https://forums.developer.apple.com/thread/49676
            @try {
                [strongSelf.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:indexPathRow] withAnimation:NSTableViewAnimationEffectFade];
            } @catch(NSException *e) {
                
            }
        } else {
            WXLogInfo(@"Reload cell:%@ at indexPath:%@", cell.ref, indexPath);
            [strongSelf.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:indexPathRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            [self handleAppear];
        }
    }];
}

- (void)cellDidRendered:(WXCellComponent *)cell
{
    WXAssertMainThread();
    
//    if (WX_MONITOR_INSTANCE_PERF_IS_RECORDED(WXPTFirstScreenRender, self.weexInstance) && !self.weexInstance.onRenderProgress) {
//        // improve performance
//        return;
//    }
    
    NSIndexPath *indexPath = [self indexPathForCell:cell withCellComponents:self.cellComponentsCompleted];
    if (!indexPath || [indexPath indexAtPosition:0] >= [self.tableView numberOfRows]) {
        WXLogWarning(@"Rendered cell:%@ out of range, sections:%@", cell, self.cellComponentsCompleted);
        return;
    }
    CGRect cellRect = NSRectToCGRect([self.tableView rectOfRow:[indexPath indexAtPosition:0]]);
    if (cellRect.origin.y + cellRect.size.height >= _tableView.frame.size.height) {
//        WX_MONITOR_INSTANCE_PERF_END(WXPTFirstScreenRender, self.weexInstance);
    }
    
    if (self.weexInstance.onRenderProgress) {
        CGRect renderRect = [self.tableView convertRect:cellRect toView:self.weexInstance.rootView];
        self.weexInstance.onRenderProgress(renderRect);
    }
}

- (void)cell:(WXCellComponent *)cell didMoveToIndex:(NSUInteger)index
{
    WXAssertComponentThread();
    
    NSIndexPath *fromIndexPath = [self indexPathForCell:cell withCellComponents:self.cellComponents];
    NSIndexPath *toIndexPath = [self indexPathForSubIndex:index];
    if ([toIndexPath indexAtPosition:0] > [self.cellComponents count]) {
        WXLogError(@"toIndexPath %@ is out of range as the current is %lu",toIndexPath ,(unsigned long)[self.cellComponents count]);
        return;
    }
    [self removeCellForIndexPath:fromIndexPath withCellComponents:self.cellComponents];
    [self insertCell:cell forIndexPath:toIndexPath];
    
    __weak typeof(self) weakSelf = self;
    [self.weexInstance.componentManager _addUITask:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (_reloadInterval > 0) {
            // use [UITableView reloadData] to do batch updates, will move to recycler's update controller
            if (!strongSelf.updates) {
                strongSelf.updates = [NSMutableArray array];
            }
            [strongSelf.updates addObject:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf removeCellForIndexPath:fromIndexPath withCellComponents:self.cellComponentsCompleted];
                [strongSelf insertCell:cell forIndexPath:toIndexPath];
            }];
            
            [self checkReloadData];
        } else {
            [self removeCellForIndexPath:fromIndexPath withCellComponents:self.cellComponentsCompleted];
            [self insertCell:cell forIndexPath:toIndexPath];
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                @try {
                    [self.tableView beginUpdates];
                    [self.tableView moveRowAtIndex:[fromIndexPath indexAtPosition:0] toIndex:[toIndexPath indexAtPosition:0]];
                    [self handleAppear];
                    [self.tableView endUpdates];
                }@catch(NSException * exception){
                    WXLogDebug(@"move cell exception: %@", [exception description]);
                }@finally {
                    // do nothing
                }
            } completionHandler:^{
                
            }];
        }
    }];
}

- (float)containerWidthForLayout:(WXCellComponent *)cell {
    return [self safeContainerStyleWidth];
}


#pragma mark cell edit
- (void)insertCell:(WXCellComponent *)cell forIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:0] > [self.cellComponents count]) {
        WXLogError(@"inserting cell at indexPath:%@ outof range, sections:%@", indexPath, self.cellComponents);
        return;
    }
    WXAssert(self.cellComponents, @"inserting cell at indexPath:%@ section has not been inserted to list before, sections:%@", indexPath, self.cellComponents);
    WXAssert([indexPath indexAtPosition:0] < [self.cellComponents count], @"inserting cell at indexPath:%@ outof range, sections:%@", indexPath, self.cellComponents);
    [self.cellComponents insertObject:cell atIndex:[indexPath indexAtPosition:0]];
}

- (void)removeCellForIndexPath:(NSIndexPath *)indexPath withCellComponents:(NSMutableArray<WXCellComponent*>*)cellComponents
{
    if (0 == [cellComponents count]) {
        return;
    }
    WXAssert(cellComponents, @"Removing cell at indexPath:%@ has not been inserted to cell list before, sections:%@", indexPath, cellComponents);
    WXAssert([indexPath indexAtPosition:0] < [cellComponents count], @"Removing cell at indexPath:%@ outof range, sections:%@", indexPath, cellComponents);
    [cellComponents removeObjectAtIndex:[indexPath indexAtPosition:0]];
}

- (void)checkReloadData
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reloadInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_isUpdating || weakSelf.updates.count == 0) {
            return ;
        }
        
        _isUpdating = YES;
        NSArray *updates = [_updates copy];
        [weakSelf.updates removeAllObjects];
        for (void(^update)(void) in updates) {
            update();
        }
        [weakSelf.tableView reloadData];
        _isUpdating = NO;
        
        [self checkReloadData];
    });
}

- (void)handleAppear
{
    
}
@end
