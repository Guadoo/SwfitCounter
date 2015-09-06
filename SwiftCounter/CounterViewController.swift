//
//  CounterViewController.swift
//  SwiftCounter
//
//  Created by 孙雷 on 15/8/26.
//  Copyright (c) 2015年 Guadoo. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {
    
    
    //声明屏幕元素
    var timeLabel: UILabel?
    var timeButtons:[UIButton]?
    var startStopButton: UIButton?
    var clearButton: UIButton?
    var addTimeButton: UIView?
    
    let timeButtonInfos = [("1Min",60),("3Mins",180),("5Mins",300),("Sec",1)] //声明Dictionary 用于显示按键信息
    
    var timer: NSTimer? //显示时间
    var addTimer: NSTimer? //增加时间
    
    //设置显示时间 willSet
    var remainingSeconds: Int = 0 {
        willSet(newSeconds){
            let mins = newSeconds/60
            let seconds = newSeconds%60
            self.timeLabel!.text = NSString(format: "%02d:%02d", mins, seconds) as String
        }
    }
    
    //判断是非在记时，如果计时状态则执行updateTimer，否则初始化Timer
    var isCounting: Bool = false {
        willSet(newValue){
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
            }else{
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonsEnabled(!newValue) //计时状态下则true！disable相关按键，反正enable相关按键
        }
    }
    
    //判断是非添加时间，如果是添加时间则执行addTimer，否则初始化addTimer
    var isAddingTime: Bool = false {
        willSet(newValue){
            if newValue {
                addTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "addTimer:", userInfo: nil, repeats: true)
            }else{
                addTimer?.invalidate()
                addTimer = nil
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupTimeLabel()
        setupTimeButtons()
        setupActionButtons()
        
        self.addTimeButton?.multipleTouchEnabled = true

    }
    
    //设置屏幕元素显示位置
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width-20, 120)
        
        addTimeButton!.frame = CGRectMake(self.view.bounds.size.width/2-40, self.view.bounds.size.height-180, 80, 44)
        
        let gap = (self.view.bounds.size.width - 10*2 - (CGFloat(timeButtons!.count)*64)) / CGFloat(timeButtons!.count - 1)
        
        for(index, button) in enumerate(timeButtons!){
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height-120, 64, 44)
        }
        
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height-60, self.view.bounds.size.width-20-100, 44)
        clearButton!.frame = CGRectMake(10+self.view.bounds.size.width-20-100+20, self.view.bounds.size.height-60, 80, 44)
        
    }
    
    //初始化TimeLabel并添加至View, 位置由viewWillLayoutSubviews定
    func setupTimeLabel(){
        
        timeLabel = UILabel()
        timeLabel!.text = "00:00"
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Arial", size: 80)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(timeLabel!)
    
    }
    
    //初始化buttons添加到View，并存入buttons数组，位置有viewWillLayoutSubviews定
    func setupTimeButtons(){
        
        var buttons = [UIButton]()
        
        for(index,(title, _)) in enumerate(timeButtonInfos){
            
            let button: UIButton = UIButton()
            button.tag = index
            button.setTitle("\(title)", forState: UIControlState.Normal)
            
            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons.append(button)
            self.view.addSubview(button)
        }
        timeButtons = buttons //存入数组类变量timeButtons
    }
    
    
    //初始化StartStop、Clear和addTime并添加到View
    func setupActionButtons(){
        
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        startStopButton!.setTitle("Start/Stop", forState: UIControlState.Normal)
        startStopButton!.addTarget(self, action: "startStopButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStopButton!)
        
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        clearButton!.setTitle("Reset", forState: UIControlState.Normal)
        clearButton!.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(clearButton!)
        
        addTimeButton = UIView()
        addTimeButton!.backgroundColor = UIColor.blueColor()
        
        self.view.addSubview(addTimeButton!)
    }
    
    //Actions & CallBacks
    
    func startStopButtonTapped(sender: UIButton){
        
        isCounting = !isCounting
        
        if isCounting{
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        }else{
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func clearButtonTapped(sender: UIButton){
        remainingSeconds = 0
        timeLabel!.text = "00:00"
    }
    
    func timeButtonTapped(sender: UIButton){
        let (_, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
    }

    //更新时间
    func updateTimer(timer: NSTimer){
        
        remainingSeconds -= 1
        
        if remainingSeconds <= 0 {
            self.isCounting = false
            self.timeLabel?.text = "00:00"
            self.remainingSeconds = 0
            
            let alert = UIAlertView()
            alert.title = "Counting Finished"
            alert.message = ""
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func addTimer(timer: NSTimer){
        remainingSeconds += 1
    }
    
    
    func setSettingButtonsEnabled(enabled: Bool){
        
        for button in self.timeButtons!{
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
        
        addTimeButton!.alpha = enabled ? 1.0 : 0.3 //addTimeButton是UIView 不是Button
    }
    
    //创建Notification提示信息
    func createAndFireLocalNotificationAfterSeconds(seconds: Int){
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        let timeIntervalSinceNow = NSNumber(integer: seconds).doubleValue
        notification.fireDate = NSDate(timeIntervalSinceNow: timeIntervalSinceNow)
        
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = "Counting Finished"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    // UITouch Events
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches{
            var t:UITouch = touch as! UITouch
        }

        isAddingTime = !isAddingTime
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        isAddingTime = !isAddingTime
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
