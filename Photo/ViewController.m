//
//  ViewController.m
//  Photo
//
//  Created by crazypoo on 14/6/12.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *picker;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)editSelectedPhoto
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:@[self.imageView.image]
                                            applicationActivities:nil];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType,
                                                BOOL completed,
                                                NSArray *returnedObjects,
                                                NSError *error){
        if(returnedObjects.count != 0){
            
            NSExtensionItem* extensionItem = [returnedObjects objectAtIndex:0];
            
            NSItemProvider* itemProvider = [extensionItem.attachments objectAtIndex:0];
            
            if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]){
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    
                    if(image && !error){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.imageView setImage:image];
                        });
                        
                    }
                }];
                
            }
        }
    }];
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIBarButtonItem *editBTN = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSelectedPhoto)];
        self.navigationItem.leftBarButtonItem = editBTN;
        
    }];
}

- (IBAction)chooseBTNTap:(id)sender
{
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
