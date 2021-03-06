
//
//  BBFavoriteBusCardCell.m
//  Bus
//
//  Created by 朱辉 on 16/3/19.
//  Copyright © 2016年 朱辉. All rights reserved.
//

#import "BFavoriteBusCardCell.h"
#import "BFavoriteBusLine.h"
#import "BBusGPSView.h"

#import "BBusLine.h"
#import "BBusStation.h"
#import "BUser.h"
#import "BBusGPS.h"

#import "BLabel.h"
#import "BCommon.h"

#import "BVerticalButton.h"

#import <CoreLocation/CoreLocation.h>

@interface BFavoriteBusCardCell()

@property (weak, nonatomic) IBOutlet BLabel *busLineNameLabel;

/**
 *  首班时间
 */
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
/**
 *  末班时间
 */
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *endStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *endStationSubLabel;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;

/**
 *  当前站
 */
@property (weak, nonatomic) IBOutlet UILabel *currentStationNameLabel;
/**
 *  当前站子标题
 */
@property (weak, nonatomic) IBOutlet UILabel *currentStationSubLabel;

/**
 *  公交所在的站点label
 */
@property (weak, nonatomic) IBOutlet UILabel *busArriveStationLabel;

@property (weak, nonatomic) IBOutlet UILabel *busArriveStationSubLabel;

/**
 *  计算剩余时间label
 */
@property (weak, nonatomic) IBOutlet UILabel *surplusTimeLabel;

/**
 *  预计用时label
 */
@property (weak, nonatomic) IBOutlet UILabel *guessLabel;
/**
 *  预计用时 时间单位Label
 */
@property (weak, nonatomic) IBOutlet UILabel *guessUnitLabel;

/**
 *  到站提醒label
 */
@property (weak, nonatomic) IBOutlet UILabel *busArriveTipLabel;
/**
 *  还剩多少站label
 */
@property (weak, nonatomic) IBOutlet UILabel *countOfStationLabel;

/*********autolayout*********/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *busLineNameLabelHeight;

/**
 *  开往方向view顶部距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *busDirViewTop;

/**
 *  用户选择位置view顶部距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfLocationViewTop;

/**
 *  公交车view顶部距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *busLocationViewTop;

/**
 *  公交车view底部距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *busLocationViewBottom;

/**
 *  目的站底部 距离底部距离
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endStationNameBottom;

/**
 *  busLineNameLabel上方的间距
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *busLineNameTop;
@property (weak, nonatomic) IBOutlet UILabel *aaa;


/********** 公交信息 ************/
@property (nonatomic,strong) BBusStation* currentStation;

@end

@implementation BFavoriteBusCardCell

- (void)awakeFromNib {
    // 设置卡片的圆角
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    // 公交线路名称垂直居下
    self.busLineNameLabel.verticalAlignment = VerticalAlignmentBottom;
    
    if([UIScreen mainScreen].bounds.size.height <= 480) { // 4s
        self.busLineNameLabelHeight.constant = 60;
        self.busLineNameTop.constant = 0;
        self.busDirViewTop.constant = 0;
        self.selfLocationViewTop.constant = 0;
        self.busLocationViewTop.constant = 0;
        self.endStationNameBottom.constant = 0;
        // 预计/分钟字体大小
        self.guessLabel.font = [UIFont systemFontOfSize:9];
        self.guessUnitLabel.font = [UIFont systemFontOfSize:9];
        self.busArriveTipLabel.font =[UIFont systemFontOfSize:13];
    } else if ([UIScreen mainScreen].bounds.size.height <= 568) { // 5s
        self.busLineNameTop.constant /= 2;
        self.busDirViewTop.constant /= 2;
        self.selfLocationViewTop.constant /= 2;
        self.busLocationViewTop.constant /= 2;
        self.endStationNameBottom.constant /= 2;
        // 预计/分钟字体大小
        self.guessLabel.font = [UIFont systemFontOfSize:9];
        self.guessUnitLabel.font = [UIFont systemFontOfSize:9];
        self.busArriveTipLabel.font =[UIFont systemFontOfSize:13];
    }else if([UIScreen mainScreen].bounds.size.height <= 667) {  // 6s
        self.selfLocationViewTop.constant /= 2;
        self.busLocationViewTop.constant /= 2;
        // 预计/分钟字体大小
        self.guessLabel.font = [UIFont systemFontOfSize:11];
        self.guessUnitLabel.font = [UIFont systemFontOfSize:12];
        self.busArriveTipLabel.font =[UIFont systemFontOfSize:18];
    }else if([UIScreen mainScreen].bounds.size.height <= 736) { // 6sp
        self.busLocationViewBottom.constant = 45;
        self.busArriveTipLabel.font =[UIFont systemFontOfSize:22];
        self.guessLabel.font = [UIFont systemFontOfSize:14];
        self.guessUnitLabel.font = [UIFont systemFontOfSize:15];
    }
}

- (IBAction)closeCardClick:(id)sender {
    if([self.delegate respondsToSelector:@selector(favoriteBusCardDidCloseClick:)]){
        [self.delegate favoriteBusCardDidCloseClick:self];
    }
}

- (IBAction)locationButtonClick:(id)sender {
    // 如果是选中状态，表示用户自己选择了某个公交站点，点击该按钮时，需要回到用户定位的公交站点
    if(self.locationButton.selected){
        
        [self setUserCurrentStationWithUserLocation];
        
        [self.gpsView selectBusStation:self.currentStation];
    }
}

/**
 *  切换方向点击
 *
 */
- (IBAction)changeDirectionClick:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(favoriteBusCardDidChangeDirectionClick:)]) {
        [self.delegate favoriteBusCardDidChangeDirectionClick:self];
    }
}

/**
 *  刷新按钮点击
 */
- (IBAction)updateClick:(id)sender {
    if([self.delegate respondsToSelector:@selector(favoriteBusCardDidUpdateClick:)]){
        [self.delegate favoriteBusCardDidUpdateClick:self];
    }
}

- (void)didSelected
{
    self.currentStation = nil;
    [self setLocationButtonImageWithSelected:NO];
}

- (void)setFavoriteBusLine:(BFavoriteBusLine *)favoriteBusLine {
    _favoriteBusLine = favoriteBusLine;
    
    // 公交名称
    
    self.busLineNameLabel.text = favoriteBusLine.busLine.fullname;
    
    // 首末班时间,需要将日期截掉
    self.startTimeLabel.text = [NSString stringWithFormat:@"早 %@", [BCommon timeFromDateString:favoriteBusLine.busLine.firsttime]];
    self.endTimeLabel.text = [NSString stringWithFormat:@"晚 %@", [BCommon timeFromDateString:favoriteBusLine.busLine.lasttime]];
    
    // 设置终点站名称
    [self setEndStationName:[[favoriteBusLine.busLine busStationsWithDirection:favoriteBusLine.direction] lastObject]];
    
    [self updateConstraints];
    [self layoutIfNeeded];
    
    [self autosizeAllLabel];
    
    // 设置当前位置
    [self setUserCurrentStationWithUserLocation];
}


// 设置开往方向终点站名称
- (void)setEndStationName:(BBusStation*)endStation {
    
    if(endStation == nil) return;
    
    // 目的站
    BBusStation* endBusStation = endStation;
    
    NSArray<NSString*>* endBusStationName = [BCommon subNameInStationName:endBusStation.name];
    
    self.endStationLabel.text = endBusStationName[0];
    self.endStationSubLabel.text = endBusStationName[1];
    
    if([endBusStationName[1] isEqualToString:@""]) {
        self.endStationNameBottom.constant = 5;
    }else{
        self.endStationNameBottom.constant = 14;
    }
}

- (void)autosizeAllLabel {
    // fullName,fullName的宽度不超过自身宽的62%
    self.busLineNameLabel.font =[self.busLineNameLabel.text maxFontInSize:CGSizeMake(self.width * .62, self.busLineNameLabel.frame.size.height)  maxFontSize:50];
    self.busLineNameLabel.verticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    
    // 开往
    //    self.aaa.font = [self.aaa.text maxFontInSize:self.aaa.frame.size  maxFontSize:50];
    
    // 尾站
    self.endStationLabel.font = [self.endStationLabel.text maxFontInSize:self.endStationLabel.frame.size  maxFontSize:50];
    
    // 时间label
    
    self.surplusTimeLabel.font = [self.surplusTimeLabel.text maxFontInSize:CGSizeMake(CGFLOAT_MAX, self.endStationLabel.frame.size.height)   maxFontSize:100];
}


/**
 *  设置公交GPS数据，并计算时时公交数据
 */
-(void)setBusGPSs:(NSArray<BBusGPS *> *)busGPSs {
    _busGPSs = busGPSs;
    
    if(self.currentStation == nil) {
        [self setUserCurrentStationWithUserLocation];
    }
    
    [self updateBusInfo];
}


/**
 *  计算当前站与公交之间的信息，并显示在界面上
 */
- (void)updateBusInfo {
    
    // 计算最近一辆公交的所在站点
    BBusGPS* nearsetBusGPS = nil;
    for (BBusGPS* gps in self.busGPSs) {
        if(gps.stationNo.intValue >= self.currentStation.orderno.intValue) {
            break;
        }else{
            nearsetBusGPS = gps;
        }
    }
    
    // 设置开往方向终点站
    [self setEndStationName:[self.favoriteBusLine.busLine.busStations lastObject]];
    
    NSString* stationName =nil;
    NSString* subText = nil;
    NSString* countOfStation = nil;
    NSString* surplusTime = nil;
    do {
        
        if(nearsetBusGPS == nil) {
            stationName = @"目前没有合适的公交";
            subText = @"请耐心等待";
            countOfStation = @"还有0站";
            surplusTime = @"0";
            break;
        }
        
        BBusStation* nearestBusStation = nil;
        for (BBusStation* station in self.favoriteBusLine.busLine.busStations) {
            if(station.orderno.integerValue == nearsetBusGPS.stationNo.integerValue) {
                nearestBusStation = station;
            }
        }
        
        if(nearestBusStation != nil) {
            stationName = nearestBusStation.name;
        } else {
            stationName = @"公交失联了";
            subText = @"悲剧啊~~";
            break;
        }
        
        // 计算两点之间的距离
        CLLocation* curLocation = [self currentLocation];
        CLLocation* busLocation = [[CLLocation alloc]initWithLatitude:nearestBusStation.latitude.doubleValue longitude:nearestBusStation.longitude.doubleValue];
        
        CLLocationDistance distance = [curLocation distanceFromLocation:busLocation];
        
        
        
        NSString* unit = @"米";
        if(distance > 10000) {
            distance /= 1000;
            unit = @"千米";
        }
        subText = [NSString stringWithFormat:@"%.2f%@", distance, unit];
        
        // 计算公交车离开上一站的时间
        NSString* timeTip = [BCommon stringFromTimeInterval:[BCommon dateFromDateString:nearsetBusGPS.date]];
        
        if(nearsetBusGPS.arriveStation.integerValue == 0) {
            subText = [NSString stringWithFormat:@"%@离开此站\n距您%@", timeTip, subText];
        }else{
            subText = [NSString stringWithFormat:@"刚刚到!快去\n距离%@", subText];
        }

        // 计算剩余站数量
        int countOfStationNum = self.currentStation.orderno.intValue - nearestBusStation.orderno.intValue;
        
        countOfStation = [NSString stringWithFormat:@"还有%d站", countOfStationNum];
        
        // 推测时间
        float probablyTime = 0;
        
        NSInteger indexInArray = [self.favoriteBusLine.busLine.busStations indexOfObject:nearestBusStation];
        BBusStation* temp = nearestBusStation;
        
        while(temp.orderno.intValue < self.currentStation.orderno.intValue) {
            
            BBusStation* nextStation = [self.favoriteBusLine.busLine.busStations objectAtIndex:indexInArray + 1];
            
            CLLocationDistance distance = [temp.location distanceFromLocation:nextStation.location];
            
            probablyTime += [self probablyTimeForDistance:distance];
            
            temp = nextStation;
            indexInArray++;
        }
        
        // 减去公交已经离开的时间
        surplusTime = [NSString stringWithFormat:@"%d", (int)probablyTime];
        
    }while(0);
    
    self.busArriveStationLabel.text = stationName;
    self.busArriveStationSubLabel.text = subText;
    self.countOfStationLabel.text = countOfStation;
    self.surplusTimeLabel.text = surplusTime;
    
    [self autosizeAllLabel];
}

- (void)selectBusStation:(BBusStation*)busStation {
    // 清理上次遗留的数据
    self.currentStation = nil;
    
    // 如果选中的是当前站
    if(busStation.orderno.intValue == [BUser defaultUser].nearestStation.orderno.intValue) {
        [self setUserCurrentStationWithUserLocation];
        return;
    }
    
    CLLocation* curLocation =  [BUser defaultUser].curLocation;
    
    // 获取用户当前位置距离选中站间隔几站
    BBusStation* nearestStation = [self getNearsetBusStaionAtLocation:curLocation];
    
    int coutOf = abs(nearestStation.orderno.intValue - busStation.orderno.intValue);
    
    // 计算选中的站点距离用户的位置
    CLLocationDistance distance = [busStation.location distanceFromLocation:curLocation];
    
    // 用户自己选中时，图标设置为蓝色
    [self.locationButton setSelected:YES];
    [self setLocationButtonImageWithSelected:YES];
    
    
    self.currentStation = busStation;
    self.currentStationNameLabel.text = busStation.name;
    self.currentStationSubLabel.text = [NSString stringWithFormat:@"距您%d站, %@", coutOf, [self distanceToString:distance]];
    [self updateBusInfo];
}

- (void)setUserCurrentStationWithUserLocation {
    CLLocation* curLocation =  [BUser defaultUser].curLocation;
    
    BBusStation* minDistanceStation = [self getNearsetBusStaionAtLocation:curLocation];
    
    if (minDistanceStation == nil) {
        self.currentStationNameLabel.text = @"网络不给力";
    } else {
        self.currentStationNameLabel.text = minDistanceStation.name;
    }
    
    CLLocationDistance minDistance = [minDistanceStation.location distanceFromLocation:curLocation];
    
    self.currentStationSubLabel.text = [NSString stringWithFormat:@"距您约%@", [self distanceToString:minDistance]];
    
    // 设置当前用户所在站点
    self.currentStation = minDistanceStation;
    
    // 保存到用户
    [BUser defaultUser].nearestStation = minDistanceStation;
    
    [self.locationButton setSelected:NO];
    [self setLocationButtonImageWithSelected:NO];
    [self updateBusInfo];
}

- (void)setUserCurrentStationWithBusStation:(BBusStation*)busStation {
    
    
}

- (void)setLocationButtonImageWithSelected:(BOOL)selected {
    if(selected) {
        [self.locationButton setImage:[UIImage imageNamed:@"favorite_card_other_location"] forState:UIControlStateNormal];
        [self.locationButton setImage:[UIImage imageNamed:@"favorite_card_other_location_highlight"] forState:UIControlStateHighlighted];
    }else{
        [self.locationButton setImage:[UIImage imageNamed:@"favorite_card_location"] forState:UIControlStateNormal];
        [self.locationButton setImage:[UIImage imageNamed:@"favorite_card_location_highlight"] forState:UIControlStateHighlighted];
    }
    
}

/**
 *  返回当前用户的位置
 *  如果用户使用系统定位的位置，返回定位的位置
 *  如果用户手动选择了公交站点，则返回用户选择的公交站点位置
 */
- (CLLocation*)currentLocation {
    return [BUser defaultUser].curLocation;
}

/**
 *  计算指定地理位置最近的一个公交站点
 */
- (BBusStation*)getNearsetBusStaionAtLocation:(CLLocation*)location {
    
    CLLocationDistance minDistance = CGFLOAT_MAX;
    BBusStation* minDistanceStation = nil;
    
    // 计算当前距离用户最近的公交站点
    for (BBusStation* station in self.favoriteBusLine.busLine.busStations) {
        CLLocation* stationLocation = [[CLLocation alloc]initWithLatitude:station.latitude.doubleValue longitude:station.longitude.doubleValue];
        CLLocationDistance distance = [location distanceFromLocation:stationLocation];
        if(distance < minDistance) {
            minDistance = distance;
            minDistanceStation = station;
        }
    }
    
    return minDistanceStation;
}

/**
 *  将距离转化为字符串，>10km，返回10千米 否则返回 xxx米
 */
- (NSString*)distanceToString:(CLLocationDistance)distance {
    NSString* unit = @"米";
    
    if(distance > 10000) {
        distance /= 1000;
        unit = @"千米";
    }
    
    return [NSString stringWithFormat:@"%.2f%@", distance, unit];
}

/**
 *  计算公交车大概
 *
 *  @param distance 距离
 *
 *  @return 推测的分钟数
 */
- (float)probablyTimeForDistance:(CLLocationDistance)distance {
    
    float speed = 300;
    
    // 里程数 > 1km  速度为 400/m
    if(distance > 1000) {
        speed = 400;
    }
    
    // 里程数 > 2km  速度 600/m
    if(distance > 2000){
        speed = 600;
    }
    // 里程数 > 3km  速度 800/m
    if(distance > 2000){
        speed = 800;
    }

    return distance / speed;
}

@end
