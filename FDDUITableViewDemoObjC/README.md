### UITableView如何开启极简模式

>UITableView作为iOS开发的最常用的控件，相信对我们开发来说再熟悉不过了，但是越简单的越熟悉的东西，往往也可以看出代码的质量，项目的结构等问题。本文针对 **UITableView中如何适应需求多变（新增删除、经常调换位置、高度变动等等）的通用解决方法** 及  **如何避免同一套完全相同的UITableViewDelegate、UITableViewDataSource代码在不同UIViewController多次实现**  两点进行展开讨论。不足之处还请指正。



#### 一、 **UITableView中如何适应需求多变（新增删除、经常调换位置、高度变动等等）的通用解决方法** 

拿我负责的楼盘详情来说：

![](http://7xqhx8.com1.z0.glb.clouddn.com/tableView1.png) 



因为产品会不时的参考运维及竞品产品，所以也会不时地对楼盘各个模块进行迭代调整，如果采用

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		//dosomething
	}
	else if (indexPath.row == 1) {
		//dosomething
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		//didSelect
	}
	else if (indexPath.row == 1) {
		//didSelect
	}
}
```

进行代码兼容，对应的其他方法也得细心细心是的修正，想想都觉得可怕而又不保险，经过长期的磨合及快速适应产品需求而又让自己身心愉悦，必须得有一套完整而又通用的模式。

遵循一切皆对象的思维方式，我采取了 `不同模块尽量使用独立的cell` 处理，比如

![](http://7xqhx8.com1.z0.glb.clouddn.com/tableView2.png)

这一块，尽量分两个cell实现，毕竟下一次需求 `地址 ` 和 `最新开盘` 就分开了。

当然一个项目最好能有一个基类的`UITableViewCell` , 比如这样的：

```objective-c
@interface FDDBaseTableViewCell<ObjectType>: UITableViewCell
  
@property (nonatomic,weak) id<FDDBaseTableViewCellDelegate> fddDelegate;
@property (nonatomic,strong) ObjectType fddCellData;

+ (CGFloat)cellHeightWithCellData:(ObjectType)cellData;
- (void)setCellData:(ObjectType)fddCellData;	

@end
```

再者，随着 `MVVM` 模式的普及，项目中我也使用了一个中间的 `cellModel` 来控制 `UITableView` 对 `UITableViewCell` 的构建:

```objective-c
@interface FDDBaseCellModel : NSObject
  
@property (nonatomic, strong) id cellData;                      //cell的数据源
@property (nonatomic, assign) Class cellClass;                  //cell的Class
@property (nonatomic, weak)   id delegate;                      //cell的代理
@property (nonatomic, assign) CGFloat cellHeight;               //cell的高度，提前计算好
@property (nonatomic, strong) FDDBaseTableViewCell *staticCell; //兼容静态的cell

+ (instancetype)modelFromCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData;
- (instancetype)initWithCellClass:(Class)cellClass cellHeight:(CGFloat)cellHeight cellData:(id)cellData;

@end
```



一套通用构建 `UITableView` 的大致的思路如下：

![](http://7xqhx8.com1.z0.glb.clouddn.com/tableView3.png) 

对应的代码也就是这样：

```objective-c
- (void)disposeDataSources{
    NSArray *randomSources = @[@"Swift is now open source!",
                               @"We are excited by this new chapter in the story of Swift. After Apple unveiled the Swift programming language, it quickly became one of the fastest growing languages in history. Swift makes it easy to write software that is incredibly fast and safe by design. Now that Swift is open source, you can help make the best general purpose programming language available everywhere",
                               @"For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is now open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.",
                               @"Welcome to the Swift community. Together we are working to build a better programming language for everyone.",
                               @"– The Swift Team"];
    for (int i=0; i<30; i++) {
        NSInteger randomIndex = arc4random() % 5;
        FDDBaseCellModel *cellModel = [FDDBaseCellModel modelFromCellClass:HDTableViewCell.class cellHeight:[HDTableViewCell cellHeightWithCellData:randomSources[randomIndex]] cellData:randomSources[randomIndex]];
        [self.dataArr addObject:cellModel];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FDDBaseCellModel *cellModel = self.dataArr[indexPath.row];
    FDDBaseTableViewCell *cell = [tableView cellForIndexPath:indexPath cellClass:cellModel.cellClass];
    [cell setCellData:cellModel.cellData delegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	FDDBaseCellModel *cellModel = self.dataArr[indexPath.row];
  	//dosomething
}
```

也就是无论有多少种不同类型、各种顺序排列的 `UITableViewCell` ，**我们只需要关注数据源中的FDDBaseCellModel即可** ，而且 `UITableViewDataSource` 中的协议方法变得极为的简洁和通用。



#### 二、如何避免同一套完全相同的UITableViewDelegate、UITableViewDataSource代码在不同UIViewController多次实现

有了前面的构想，我们会惊奇的发现，实现一个无论简单或者复杂的 `UITableView` 仅仅取决于包含 `FDDBaseCellModel` 的数据源！而所有包含 `UITableView` 的 `UIViewController` 的 `UITableViewDelegate、UITableViewDataSource` 代码完全一致！

那么问题来了，怎么避免有如此的的重复代码在你优秀的项目中呢？

**1、继承帮你忙：**

在项目的 `UIViewController` 基类中，实现通用的  `UITableViewDelegate、UITableViewDataSource` 方法即可，毕竟数据源 `self.dataArr` 可以放在基类中，子类如果确实有通用方法无法处理的特殊情况，没有问题！各自子类重载对应的方法即可。`Objective-C` 和 `Swift` 通用。

存在的问题：

```
1. 对非继承基类的 UIViewController 无力回天；
2. 对 UIView 中包含的 UITableView 无法做到兼容；
3. 当 UITableViewDelegate、UITableViewDataSource不是交给当前 UIViewController 时；
4. 等等等。。。
```



**2、中间转换类（FDDTableViewConverter）实现：**

![](http://7xqhx8.com1.z0.glb.clouddn.com/tableView5.png)  



**2.1、通过响应模式来实现：**

只需要判断 `UITableView` 的载体是否能响应对应的  `UITableViewDelegate、UITableViewDataSource` 方法，如果载体实现则使用载体本身的方法即可，这个其实和继承中重载的思路一致，但是少了一层继承依赖关系总是好的。`Swift` 不可用。

存在的问题：

```
1. 和继承方式一样，需要在当前类响应 UITableViewDelegate、UITableViewDataSource 方法；
2. 当 UITableViewDelegate、UITableViewDataSource 不是交给当前 UIViewController 时；
3. 因为载体不在遵循 UITableViewDelegate、UITableViewDataSource，写对应的方法是编译器无法给到代码联想补全功能，略尴尬。
4. 中间转换类需要实现大部分的 UITableViewDelegate、UITableViewDataSource 方法，尽量全面写完；
5. 响应模式中因为要在 转换类 中调用载体的方法、提供不定向的入参及接收返回值，使用 performSelector： 方法则不可行，在 Objective-C 中倒是可以使用 NSInvocation 实现，但是在 Swift 中 NSInvocation 已经被废弃，也就是只能兼容 Objective-C 代码。如果有其他方式兼容 swift 请立马告知我，谢谢！
6. 等等等。。。
```



**2.2、通过注册模式来实现：**

这种思维模式和AOP切片模式很像，哪里注册了 `UITableViewDelegate、UITableViewDataSource` 方法，哪里处理改方法，没有默认的统一走 **中间转换类** 的统一处理。实现方式是通过 `NSMutableDictionary` 来保存注册的 `SEL` 和 `resultBlock` 。`resultBlock` 传参放入一个数组中，个数和 `SEL` 中的入参保持一致，返回值是注册的载体返回给 **中间转换类** 的结果， **中间转换类** 拿到这个值再给到  `UITableViewDelegate、UITableViewDataSource` 。好像有点转，看代码你肯定就清晰了：

`FDDTableViewConverter` 部分代码：

```objective-c
typedef id (^resultBlock)(NSArray *results);
@interface FDDTableViewConverter<TableViewCarrier>: NSObject <UITableViewDataSource, UITableViewDelegate>
  
//默认模式，使用注册方式处理tableView的一些协议
@property (nonatomic, assign) FDDTableViewConverterType converterType;
// 只有在选择 FDDTableViewConverter_Register 模式时，才会block回调
- (void)registerTableViewMethod:(SEL)selector handleParams:(resultBlock)block;

@end
```

`UITableView` 载体 `ViewController` 部分代码：

```objective-c
- (void)disposeTableViewConverter{
    _tableViewConverter = [[FDDTableViewConverter alloc] initWithTableViewCarrier:self daraSources:self.dataArr];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = _tableViewConverter;
    tableView.dataSource = _tableViewConverter;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    __weak typeof(self) weakSelf = self;
    [_tableViewConverter registerTableViewMethod:@selector(tableView:cellForRowAtIndexPath:) handleParams:^id(NSArray *results) {
        UITableView *tableView = results[0];
        NSIndexPath *indexPath = results[1];
        FDDBaseCellModel *cellModel = weakSelf.dataArr[indexPath.row];
        FDDBaseTableViewCell *cell = [tableView cellForIndexPath:indexPath cellClass:cellModel.cellClass];
        [cell setCellData:cellModel.cellData delegate:weakSelf];
        return cell;
    }];
}
```

这种方式暂时看来是比较可取的方式了，无论从代码的整洁还是耦合度来说都是非常棒的模式了，而且它关注的是谁注册了对应的方法，你就在block拿到 **中间转换类** 的值来实现你特殊化的 `UITableView` , 再回传给  **中间转换类** 来替你实现。而且注册的 `SEL` 有代码联想补全功能，😁😁   `Objective-C` 和 `Swift` 通用。

存在的问题：

```
1. 中间转换类需要实现大部分的 UITableViewDelegate、UITableViewDataSource 方法，尽量全面写完。
2. 等等等。。。
```



**3、Swift通过Category实现:**

 `Swift` 和 `Objective-C` 的 `Category` 实现机制是不一样的，对于 `Objective-C` 来说，当前类和 `Category` 有相同方法时会优先执行 `Category` 中的方法，但是在 `Swift` 的世界里，同时存在同一个方法是不允许的，所以也就多了一个 `override` 关键字来优先使用当前类的方法。

实现方式也就是在 `UITableView` 载体的 `Category` 中实现通用的代码，然后使用  `override` 关键字来特殊化需要特殊处理的 方法即可。

比如这样：

`FDDTableViewConverter.swift`

```swift
extension FDDBaseViewController: FDDBaseTableViewCellDelegate {
    
    @objc(tableView:numberOfRowsInSection:) func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel: FDDBaseCellModel = self.dataArr.object(at: indexPath.row) as! FDDBaseCellModel
        let cell: FDDBaseTableViewCell = tableView.cellForIndexPath(indexPath, cellClass: cellModel.cellClass)!
        cell.setCellData(cellModel.cellData, delegate: self)
        cell.setSeperatorAtIndexPath(indexPath, numberOfRowsInSection: self.dataArr.count)
        return cell
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel: FDDBaseCellModel = self.dataArr.object(at: indexPath.row) as! FDDBaseCellModel
        return CGFloat(cellModel.cellHeight)
    }
}
```

`ViewController.swift`

```swift
override internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	return 10
}
```

这种模式代码量非常少，并且实现起来很方便，`Objective-C` 不可用。

存在的问题：

```
1. 当在引入 FDDTableViewConverter.swift 后，因为Swift项目的特殊性（同模块中不需要导入该文件即可使用），这会导致以前的代码中，不是通用代码能实现的 UITableViewDelegate、UITableViewDataSource 方法前面都得加上 override 关键字；
2. 和继承有同样的毛病，不同的载体需要写上对应的category，貌似这块代码又是重复代码，苦逼；😅
3. 等等等。。。
```



#### 三、小结：

上面的两个问题点是同事 @袁强 抛出给到我，但是解决问题的思路很多出至于 @凌代平 ，很庆幸有这么一次机会来搬砖的机会。相信还会有其他更好的思路，如果你正好看到了请不吝赐教，🙏

代码整洁的道路很远，我相信只要需求理解到位，代码设计合理，我相信以后我们的实现 `UITableView` 时，只需要如下代码：

```objective-c
@implementation ViewController

- (void)dealloc{
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ViewController";
    
    [self disposeDataSources];
    [self disposeTableViewConverter];
}

- (void)disposeDataSources{
    NSArray *randomSources = @[@"Swift is now open source!",
                               @"We are excited by this new chapter in the story of Swift. After Apple unveiled the Swift programming language, it quickly became one of the fastest growing languages in history. Swift makes it easy to write software that is incredibly fast and safe by design. Now that Swift is open source, you can help make the best general purpose programming language available everywhere",
                               @"For students, learning Swift has been a great introduction to modern programming concepts and best practices. And because it is now open, their Swift skills will be able to be applied to an even broader range of platforms, from mobile devices to the desktop to the cloud.",
                               @"Welcome to the Swift community. Together we are working to build a better programming language for everyone.",
                               @"– The Swift Team"];
    for (int i=0; i<30; i++) {
        NSInteger randomIndex = arc4random() % 5;
        FDDBaseCellModel *cellModel = [FDDBaseCellModel modelFromCellClass:HDTableViewCell.class cellHeight:[HDTableViewCell cellHeightWithCellData:randomSources[randomIndex]] cellData:randomSources[randomIndex]];
        [self.dataArr addObject:cellModel];
    }
}

- (void)disposeTableViewConverter{
    _tableViewConverter = [[FDDTableViewConverter alloc] initWithTableViewCarrier:self daraSources:self.dataArr];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = _tableViewConverter;
    tableView.dataSource = _tableViewConverter;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

@end
```



[Objective-C源码地址](https://github.com/erduoniba/FDDUITableViewDemoObjC)

[Swift源码地址](https://github.com/erduoniba/FDDUITableViewDemoSwift) 

欢迎 **star** 


