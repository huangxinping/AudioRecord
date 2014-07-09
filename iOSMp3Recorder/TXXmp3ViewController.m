//
//  TXXmp3ViewController.m
//  iOSMp3Recorder
//
//  Created by huangxinping on 7/9/14.
//  Copyright (c) 2014 xiaoxuan Tang. All rights reserved.
//

#import "TXXmp3ViewController.h"
#import "SMAudioRecord.h"

@interface TXXmp3ViewController () <SMAudioRecordDelegate>
{
	SMAudioRecord *record;
	IBOutlet UIProgressView *recordPower;
}
@end

@implementation TXXmp3ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	record = [[SMAudioRecord alloc] init];
	record.delegate = self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
	[record startRecord];

	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)handleTimer:(id)sender {
	[recordPower setProgress:record.smai.averagePower];
}

- (IBAction)stop:(id)sender {
	[record stopRecord];
}

- (void)recordStart:(SMAudioRecord *)audiorecord {
}

- (void)recordStop:(SMAudioRecord *)audiorecord {
}

- (void)encodeStart:(SMAudioRecord *)audiorecord {
}

- (void)encodeStop:(SMAudioRecord *)audiorecord {
}

- (void)recordFinished:(SMAudioRecord *)audiorecord {
	NSLog(@"%f kb", audiorecord.smai.outputFileSize);
}

- (void)recordFailed:(SMAudioRecord *)audiorecord error:(NSString *)error {
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

- (void)dealloc {
	[recordPower release];
	[super dealloc];
}

- (void)viewDidUnload {
	[recordPower release];
	recordPower = nil;
	[super viewDidUnload];
}

@end
