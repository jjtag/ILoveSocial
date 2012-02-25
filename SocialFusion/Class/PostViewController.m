//
//  NewStatusViewController.m
//  SocialFusion
//
//  Created by Blue Bitch on 12-1-29.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "PostViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIApplication+Addition.h"
#import "RenrenClient.h"
#import "WeiboClient.h"
#import "UIImageView+Addition.h"
#import "UIButton+Addition.h"

@interface PostViewController()

- (void)dismissView;
@end

@implementation PostViewController

@synthesize textView = _textView;
@synthesize textCountLabel = _textCountLabel;
@synthesize toolBarView = _toolBarView;
@synthesize titleLabel = _titleLabel;

- (void)dealloc {
    [_textView release];
    [_textCountLabel release];
    [_toolBarView release];
    [_titleLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textView = nil;
    self.textCountLabel = nil;
    self.toolBarView = nil;
    self.titleLabel = nil;
}

- (id)init {
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView becomeFirstResponder];
    self.textView.delegate = self;
    self.textView.text = @"";
    [self updateTextCount];
}

- (void)dismissView {
    [self.textView resignFirstResponder];
    [[UIApplication sharedApplication] dismissModalViewController];
}

- (int)sinaCountWord:(NSString*)s
{
    int i,n=[s length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        
        c=[s characterAtIndex:i];
        
        if(isblank(c)){
            
            b++;
            
        }else if(isascii(c)){
            
            a++;
            
        }else{
            
            l++;
            
        }
        
    }
    
    if(a==0 && l==0) return 0;
    
    return l+(int)ceilf((float)(a+b)/2.0);
    
}

- (void)updateTextCount {
    NSString *text = self.textView.text;
    self.textCountLabel.text = [NSString stringWithFormat:@"%d", [self sinaCountWord:text]];
    
}

- (void)postStatusCompletion {
    _postCount--;
    if(_postCount == 0) {
        switch (_postStatusErrorCode) {
            case PostStatusErrorAll:
                [[UIApplication sharedApplication] presentErrorToast:@"发送到新浪微博、人人网均失败。" withVerticalPos:kToastBottomVerticalPosition];
                break;
            case PostStatusErrorWeibo:
                [[UIApplication sharedApplication] presentErrorToast:@"发送到新浪微博失败。" withVerticalPos:kToastBottomVerticalPosition];
                break;
            case PostStatusErrorRenren:
                [[UIApplication sharedApplication] presentErrorToast:@"发送到人人网失败。" withVerticalPos:kToastBottomVerticalPosition];
                break;
            case PostStatusErrorNone:
                [[UIApplication sharedApplication] presentToast:@"发送成功。" withVerticalPos:kToastBottomVerticalPosition];
                break;
            default:
                break;
        }
    }
}

- (void)showTextWarning
{
    NSInteger textCount = [self.textCountLabel.text integerValue];
    if ((textCount>=WEIBO_MAX_WORD)&&(_lastTextViewCount<WEIBO_MAX_WORD))
    {
        [[UIApplication sharedApplication] presentToast:@"超出140字部分将不会发送至新浪微博。" withVerticalPos:TOAST_POS_Y];
    }
    if ((textCount>=240)&&(_lastTextViewCount<240))
    {
        [[UIApplication sharedApplication] presentToast:@"超出240字部分将不会发送至人人网。" withVerticalPos:TOAST_POS_Y];
    }
    _lastTextViewCount=textCount;
}

#pragma mark -
#pragma mark IBAction

- (IBAction)didClickCancelButton:(id)sender {
    [self dismissView];
}

- (IBAction)didClickPostButton:(id)sender {
    [self dismissView];
}

- (IBAction)didClickAtButton:(id)sender {
    PickAtListViewController *vc = [[PickAtListViewController alloc] init];
    vc.managedObjectContext = self.managedObjectContext;
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:^{
        [vc updateTableView];
    }];
    [vc release];
}

#pragma mark -
#pragma mark Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //NSLog(@"keyboard changed, keyboard width = %f, height = %f", kbSize.width,kbSize.height);
    
    CGRect toolbarFrame = self.toolBarView.frame;
    toolbarFrame.origin.y = self.view.frame.size.height - kbSize.height - toolbarFrame.size.height;
    self.toolBarView.frame = toolbarFrame;
    
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.size.height = self.view.frame.size.height - kbSize.height - textViewFrame.origin.y - TOOLBAR_HEIGHT;
    self.textView.frame = textViewFrame;
    
}

#pragma mark -
#pragma mark UITextView delegate 
- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextCount];
    [self showTextWarning];
}

#pragma mark -
#pragma makr PickAtListViewController delegate

- (void)cancelPickUser {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didPickAtUser:(NSString *)userName {
    int location = self.textView.selectedRange.location;
    NSString *content = self.textView.text;
    NSString *stringToInsert = [userName stringByAppendingString:@" "];
    NSString *result = [NSString stringWithFormat:@"%@%@%@",[content substringToIndex:location], stringToInsert, [content substringFromIndex:location]];
    self.textView.text = result;
    NSRange range = self.textView.selectedRange;
    range.location = location + stringToInsert.length;
    self.textView.selectedRange = range;
    [self updateTextCount];
    [self dismissModalViewControllerAnimated:YES];
}

@end
