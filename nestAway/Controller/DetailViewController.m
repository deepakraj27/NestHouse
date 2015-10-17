//
//  DetailViewController.m
//  nestAway
//
//  Created by deepakraj murugesan on 17/10/15.
//  Copyright © 2015 deepakraj murugesan. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+WebCache.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *typehouse;
@property (weak, nonatomic) IBOutlet UILabel *idnest;
@property (weak, nonatomic) IBOutlet UILabel *titleHead;
@property (weak, nonatomic) IBOutlet UILabel *beds;
@property (weak, nonatomic) IBOutlet UILabel *sizebhk;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *malefemale;
@property (weak, nonatomic) IBOutlet UILabel *addressBok;
@property (weak, nonatomic) IBOutlet UILabel *rentValue;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self outletSetting];
    // Do any additional setup after loading the view.
}

-(void)outletSetting{
    [self.image sd_setImageWithURL:[NSURL URLWithString:self.imageURL]
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.typehouse.text =[@"Type: "  stringByAppendingString:self.houseType];
    self.idnest.text = [@"NestAwayID: " stringByAppendingString:self.nestawayID];
    self.titleHead.text =[@"Title: " stringByAppendingString: self.Title];
    
    double bedValue = [self.bedAvailable doubleValue];
    NSString * bednumberValue = [NSString stringWithFormat:@"%.f Pts", bedValue];
    self.beds.text =[@"BHK Type: " stringByAppendingString: bednumberValue];

    self.sizebhk.text =[@"BHK Type: " stringByAppendingString:self.BHK];
    self.location.text =[@"Loc: " stringByAppendingString:self.locality];
    self.malefemale.text =[@"Gender: " stringByAppendingString: self.gender];
    self.addressBok.text =[@"Address: " stringByAppendingString: self.address];
    
    double rentValue1 = [self.rent doubleValue];
    NSString * rentnumberValue = [NSString stringWithFormat:@"%.f Pts", rentValue1];
    self.rentValue.text =[@"Rent is ₹: " stringByAppendingString: rentnumberValue];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
