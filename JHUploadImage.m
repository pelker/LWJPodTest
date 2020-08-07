//
//  JHUploadImage.m
//  SmallCityStory
//
//  Created by Jivan on 2017/5/4.
//  Copyright © 2017年 Jivan. All rights reserved.
//

#import "JHUploadImage.h"
static JHUploadImage *_jhUploadImage = nil;

@interface JHUploadImage()
// 解决快速点击图片时会触发多次选择同一张图片的问题。
@property (nonatomic, assign) BOOL isHadSelectFinish;
@end
@implementation JHUploadImage
+ (JHUploadImage *)shareUploadImage {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jhUploadImage = [[JHUploadImage alloc] init];
    });
    return _jhUploadImage;
}
- (void)showActionSheetInFatherViewController:(UIViewController *)fatherVC  delegate:(id<JHUploadImageDelegate>)aDelegate {
    self.isHadSelectFinish = false;
    _jhUploadImage.uploadImageDelegate = aDelegate;
    _fatherViewController = fatherVC;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:MTLocalizedStr(@"all_cancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:MTLocalizedStr(@"web_gallery"), MTLocalizedStr(@"web_camera"), nil];
    [sheet showInView:fatherVC.view];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self fromPhotos];
    }else if (buttonIndex == 1) {
        [self createPhotoView];
    }
}
#pragma mark - 头像(相机和从相册中选择)
- (void)createPhotoView {
    if (self.uploadImageDelegate && [self.uploadImageDelegate respondsToSelector:@selector(clickCamera)]) {
        [self.uploadImageDelegate clickCamera];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
        imagePC.sourceType                = UIImagePickerControllerSourceTypeCamera;
        imagePC.delegate                  = self;
        imagePC.allowsEditing             = NO;
        [_fatherViewController presentViewController:imagePC
                                            animated:YES
                                          completion:^{
                                          }];
   }else {
//        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备没有照相机" preferredStyle:UIAlertControllerStyleAlert];
//       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
//       [alert addAction:cancelAction];
//       [alert addAction:okAction];
//       UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
//       [rootViewController presentViewController:alert animated:YES completion:^{
//           
//       }];
//       
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:MTLocalizedStr(@"tip_permission_camera")
                                                        delegate:nil
                                               cancelButtonTitle:MTLocalizedStr(@"all_confirm")
                                               otherButtonTitles:nil];
        [alert show];
    }
}
//图片库方法(从手机的图片库中查找图片)
- (void)fromPhotos {
    if (self.uploadImageDelegate && [self.uploadImageDelegate respondsToSelector:@selector(clickGallery)]) {
        [self.uploadImageDelegate clickGallery];
    }
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    imagePC.navigationBar.translucent = NO;
    imagePC.sourceType                = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePC.delegate                  = self;
    imagePC.allowsEditing             = false;
    [_fatherViewController presentViewController:imagePC
                                        animated:YES
                                      completion:^{
                                      }];
}
#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.isHadSelectFinish) {
        return;
    }
    self.isHadSelectFinish = true;
     // 原始图片
    UIImage * OriginalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
      //裁剪后图片
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
     //上传用户头像
    if (self.uploadImageDelegate && [self.uploadImageDelegate respondsToSelector:@selector(uploadImageToServerWithImage:OriginImage:)]) {
        [self.uploadImageDelegate uploadImageToServerWithImage:image ? image : OriginalImage OriginImage:OriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
