//
//  ActionViewController.m
//  PhotoEdited
//
//  Created by crazypoo on 14/6/12.
//  Copyright (c) 2014年 crazypoo. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@import CoreImage;
int tapCount;

@interface ActionViewController ()


@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic) UIImage *sourceImage;
@property(nonatomic) NSArray *filterNames;
@property (strong, nonatomic) IBOutlet UILabel *filterNameLabel;
@property (nonatomic, retain) UIButton *dropButton;

@end

@implementation ActionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Filter array setup
    self.sourceImage = self.imageView.image;
    self.filterNames = @[@"No effects",
                         @"CIPhotoEffectChrome",
                         @"CIPhotoEffectFade",
                         @"CIPhotoEffectInstant",
                         @"CIPhotoEffectMono",
                         @"CIPhotoEffectNoir",
                         @"CIPhotoEffectProcess",
                         @"CIPhotoEffectTonal",
                         @"CIPhotoEffectTransfer",
                         @"CIVignette",];
    self.filterNameLabel.text = [self.filterNames objectAtIndex:tapCount];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            self.sourceImage = image;
                            
                            [imageView setImage:self.sourceImage];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
    self.dropButton                            = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dropButton.frame                      = CGRectMake(10, 300, 30, 30);
    self.dropButton.backgroundColor            = [UIColor purpleColor];
    [self.dropButton setTitle:@"點" forState:UIControlStateNormal];
    self.dropButton.layer.borderColor          = [UIColor clearColor].CGColor;
    self.dropButton.layer.borderWidth          = 2.0;
    self.dropButton.layer.cornerRadius         = 5.0;
    [self.dropButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.dropButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.dropButton addTarget:self action:@selector(imageTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.dropButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)filterImage:(UIImage *)sourceImage
{
    CIImage *processImage = [[CIImage alloc]initWithImage:self.sourceImage];
    CIFilter *filter = [CIFilter filterWithName:[self.filterNames objectAtIndex:tapCount] keysAndValues:kCIInputImageKey,processImage, nil];
    [filter setDefaults];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef];
    
    return resultImage;
}

- (void)imageTap:(id)sender
{
    if (tapCount < self.filterNames.count - 1) {
        tapCount ++;
        __weak UIImageView *imageView = self.imageView;
        [imageView setImage:[self filterImage:self.sourceImage]];
    }else{
        tapCount = 0;
        self.imageView.image = self.sourceImage;
    }
    self.filterNameLabel.text = [self.filterNames objectAtIndex:tapCount];
}

- (IBAction)cancelBTNTap:(id)sender {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"User Canceled"
                                                                      code:0
                                                                  userInfo:nil]];
}

- (IBAction)doneBTNTap {
    
    NSExtensionItem* extensionItem = [[NSExtensionItem alloc] init];
    [extensionItem setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Photo Filter"]];
    
    [extensionItem setAttachments:@[[[NSItemProvider alloc] initWithItem:self.imageView.image typeIdentifier:(NSString*)kUTTypeImage]]];
    
    [self.extensionContext completeRequestReturningItems:@[extensionItem] completionHandler:nil];
}

@end
