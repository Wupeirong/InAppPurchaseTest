//
//  ViewController.m
//  InAppPurchaseTest
//
//  Created by Fashion+ on 2016/11/23.
//  Copyright © 2016年 Fashion+. All rights reserved.
//

#import "ViewController.h"
#import "RMStore.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) NSArray *profuctIdArr;

@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, assign) BOOL productsRequestFinished;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createTableView];
    
    _profuctIdArr = @[ @"vip_234",
                       @"vip_123",
                       @"com.TestBuyProductDemo.buyVip"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //    [self requestProductsList];
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_profuctIdArr] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _productsRequestFinished = YES;
        [self.myTableView reloadData];
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }];
    
}


- (void)createTableView {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.view addSubview:self.myTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _productsRequestFinished ? _profuctIdArr.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSString *productID = _profuctIdArr[indexPath.row];
    //    SKProduct *product = self.productList[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [RMStore localizedPriceOfProduct:product];
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![RMStore canMakePayments]) return;
    
    NSString *productID = _profuctIdArr[indexPath.row];
    [self inAppOnKeyPurchase:productID targetViewController:self];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        
//        if (transaction.error == nil) {
//            NSLog(@"购买%@成功", productID);
//        }
//    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Payment Transaction Failed" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//        [alertController addAction:alertAction];
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//    }];
    
}

- (void)inAppOnKeyPurchase:(NSString *)productId
      targetViewController:(UIViewController *)controller {

    [[RMStore defaultStore] addPayment:productId success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideHUDForView:controller.view animated:YES];
        NSLog(@"购买成功");
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideHUDForView:controller.view animated:YES];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Payment Transaction Failed" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction];
        [controller presentViewController:alertController animated:YES completion:nil];
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
