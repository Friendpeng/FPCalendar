//
//  ViewController.swift
//  FPCalendar
//
//  Created by 杨朋 on 2017/6/1.
//  Copyright © 2017年 瑞丽航空. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
    @IBOutlet weak var onewayBtn: UIButton!
    @IBOutlet weak var backWayBtn: UIButton!
    @IBOutlet weak var departBtn: UIButton!
    @IBOutlet weak var arriveBtn: UIButton!
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    var isBackTracking = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onewayBtn.isSelected = true
        departBtn.setTitle(dateFormatter.string(from: Date()), for: .normal)

        UIApplication.shared.statusBarStyle = .lightContent
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:-根据传入的日期和天，获取对应的日期
    func dayInTheFollowingDay(day:Int,date:String) ->Date{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        var dateComponents = DateComponents()
        dateComponents.day = day
        return NSCalendar.current.date(byAdding: dateComponents, to: formatter.date(from: date)!)!
        
    }
    
    
    @IBAction func onewayBtnAction(_ sender: UIButton) {
        backWayBtn.isSelected = false
        isBackTracking = false
        sender.isSelected = !backWayBtn.isSelected
        arriveBtn.setTitle("", for: .normal)
    }

    @IBAction func backWayBtnAction(_ sender: UIButton) {
        onewayBtn.isSelected = false
        sender.isSelected = !onewayBtn.isSelected
        isBackTracking = true
        arriveBtn.setTitle(dateFormatter.string(from: dayInTheFollowingDay(day: 2, date: (departBtn.titleLabel?.text)!)), for: .normal)
    }
    
    @IBAction func departBtnAction(_ sender: UIButton) {
        
        selectCalendar()
        
    }
    
    @IBAction func arriveBtnAction(_ sender: UIButton) {
        
        selectCalendar()
    }
    
    func selectCalendar(){
        let calendar = FPCalendarController()
        calendar.isBackTracking = self.isBackTracking
        calendar.minimumDate = Date()
        // 用于设置偏移到当前日期
        calendar.currentDateStr = (departBtn.titleLabel?.text)!
        calendar.departDateStr = (departBtn.titleLabel?.text)!
        calendar.arriveDateStr = (arriveBtn.titleLabel?.text)!
        calendar.selectCalendarBlock = {startCalendar,endCalendar in
            // 往返
            if self.isBackTracking {
                self.departBtn.setTitle(startCalendar, for: .normal)
                self.arriveBtn.setTitle(endCalendar, for: .normal)
            }else{
                
                self.departBtn.setTitle(startCalendar, for: .normal)
            }
        }
        
        self.navigationController?.pushViewController(calendar, animated: true)
    }
    
    }

