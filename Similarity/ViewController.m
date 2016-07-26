//
//  ViewController.m
//  Similarity
//
//  Created by Cheney on 16/7/26.
//  Copyright © 2016年 Cheney. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageBeautifyFilter.h"
#import <GPUImage.h>
#import "ShareViewController.h"
@interface ViewController ()<UIAlertViewDelegate>{

    GPUImageBeautifyFilter *beautifyFilter;
    GPUImageView *filterView;
    GPUImageStillCamera *stillCamera;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initCamera];
    [self addGuestureForView];
    
}


- (void)initCamera{
    
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [stillCamera addTarget:beautifyFilter];
    //视图对象
    filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, -40.0, ScreenWidth, ScreenHeight)];
    [filterView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    //    filterView.center = self.view.center;
    [self.view insertSubview:filterView atIndex:0];
    [beautifyFilter addTarget:filterView];
    filterView.userInteractionEnabled = true;
    [stillCamera startCameraCapture];
    

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"相机权限受限,请到设置-像不像,开启相机授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:true completion:nil];
    }
}

- (void)addGuestureForView{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapInView:)];
    [self.view addGestureRecognizer:tap];

}

-(void)tapInView:(UITapGestureRecognizer*)tap{

    [stillCamera capturePhotoAsPNGProcessedUpToFilter:beautifyFilter withCompletionHandler:^(NSData *processedPNG, NSError *error) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSError *error2 = nil;
        if (![processedPNG writeToFile:[documentsDirectory stringByAppendingPathComponent:@"FilteredPhoto.png"] options:NSAtomicWrite error:&error2])
        {
            NSLog(@"储存图片失败：%@",error2);
            return;
        }
        if (processedPNG) {
            [self performSegueWithIdentifier:@"goShare" sender:processedPNG];
        } else {
            NSLog(@"获取图片失败：%@",error2);
        }
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:processedPNG], nil, nil, nil);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    ShareViewController *shareVC = segue.destinationViewController;
    
    shareVC.stillImage = [UIImage imageWithData:(NSData*)sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
