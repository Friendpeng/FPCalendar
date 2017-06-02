//
//  FPCalendarController.swift
//  FPCalendar
//
//  Created by 杨朋 on 2017/6/1.
//  Copyright © 2017年 瑞丽航空. All rights reserved.
//

import UIKit
import FSCalendar

class FPCalendarController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance {
    typealias Block = (String,String)->()
    var selectCalendarBlock:Block?
    var startTime = String()
    var endTime = String()
    var isBackTracking = Bool()
    var maximumDate = Date()
    var minimumDate = Date()
    var startDate = Date()
    var endDate = Date()
    var isSomeDay = false
    var currentMonth = false
    var isFirst = false
    var currentDateStr = ""
    /// 单程/往返开始日期
    var departDateStr = ""
    /// 往返到达日期
    var arriveDateStr = ""
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.backgroundColor = UIColor.white
        calendar.scrollDirection = .vertical
        calendar.allowsMultipleSelection = true
        calendar.placeholderType = .none
        //        calendar.today = nil
        // 不分页显示
        calendar.pagingEnabled = false
        // 下一个月在上一个月的日历显示在当前月并且可选择
        //  calendar.placeholderType = .fillHeadTail
        
        //  calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        calendar.appearance.headerTitleColor = UIColor.black
        calendar.appearance.weekdayTextColor = UIColor.black
        calendar.appearance.borderRadius = 0
        // 日期是周末的
        calendar.appearance.titleWeekendColor = UIColor.red
        // 选择的颜色
        calendar.appearance.headerDateFormat = "yyyy年MM月"
        calendar.appearance.todayColor = UIColor.white
        calendar.appearance.titleTodayColor = UIColor.black
        calendar.appearance.selectionColor =  UIColor.init(hexString: "29B5EB", alpha: 1)
        calendar.firstWeekday = 1;
        calendar.calendarHeaderView.backgroundColor = UIColor.groupTableViewBackground
        //  calendar.appearance.adjustsFontSizeToFitContentSize = false
        calendar.register(FPCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.appearance.subtitleOffset = CGPoint.init(x: 0, y: 7)
        // 设置语言
//        calendar.locale = Locale.init(identifier: Localize.currentLanguage())
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FPCalendar"
        view.addSubview(calendar)
        calendar.frame = CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64)
       
        if isBackTracking {
            if !self.arriveDateStr.isEmpty && self.arriveDateStr != "" &&  !self.departDateStr.isEmpty && self.departDateStr != ""{
                startTime = self.departDateStr
                endTime = self.arriveDateStr
                //处理保存的起始日期小于当前日期的情况
                if (minimumDate.compare(dateFormatter.date(from: startTime)!) == ComparisonResult.orderedAscending || minimumDate.compare(dateFormatter.date(from: startTime)!) == ComparisonResult.orderedSame) && (minimumDate.compare(dateFormatter.date(from: endTime)!) == ComparisonResult.orderedAscending || minimumDate.compare(dateFormatter.date(from: endTime)!) == ComparisonResult.orderedSame){
                    calendar.select(dateFormatter.date(from: startTime))
                    calendar.select(dateFormatter.date(from: endTime))
                    configureVisibleCells()
                }else{
                    startTime = ""
                    endTime = ""
                    print("开始/结束 时间小于当前时间")
                }
            }
        }else{
            if !self.departDateStr.isEmpty && self.departDateStr != "" {
                if minimumDate.compare(dateFormatter.date(from: self.departDateStr)!) == ComparisonResult.orderedAscending || minimumDate.compare(dateFormatter.date(from: self.departDateStr)!) == ComparisonResult.orderedSame {
                    
                    calendar.select(dateFormatter.date(from: self.departDateStr))
                }else{
                    
                    calendar.select(minimumDate)
                }
            }
        }
    }
    
    //MARK:-设置子标题
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if isBackTracking {
            
            if !startTime.isEmpty && !endTime.isEmpty && calendar.selectedDates.count==0{
                return nil
            }
            if !startTime.isEmpty &&  startTime != endTime && date.compare(self.dateFormatter.date(from: startTime)!)==ComparisonResult.orderedSame{
                return "去程"
            }
            
            if !endTime.isEmpty {
                
                if date.compare(self.dateFormatter.date(from: endTime)!)==ComparisonResult.orderedSame{
                    
                    if startTime == endTime {
                        return "去程/回程"
                    }else {
                        
                        return "回程"
                    }
                    
                }
            }
            
        }else{
            
            return nil
            
        }
        
        return nil
    }
    
    //MARK:-配置cell
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell:FPCalendarCell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! FPCalendarCell
        return cell
    }
    
    //MARK:-将要显示
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        if !currentMonth {
            calendar.setCurrentPage(dateFormatter.date(from: currentDateStr)!, animated: false)
            currentMonth = true
        }
        
        self.configure(cell: cell, for: date, at: position)
    }
    
    //MARK:-设置最大日期
    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.gregorian.date(byAdding: Calendar.Component.month, value: 12, to: Date())!
    }
    
    //MARK:-设置最小日期
    func minimumDate(for calendar: FSCalendar) -> Date {
        // 返回你设置的最小日期
        return minimumDate
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.gregorian.isDateInToday(date) {
            return [UIColor.orange]
        }
        return [appearance.eventDefaultColor]
    }
    
    //MARK:-设置标题
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if self.gregorian.isDateInToday(date) {
            return "今天"
        }
        return nil
    }
    
    //MARK:-选择某个日期
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if isBackTracking {
            if !endTime.isEmpty {
                calendar.deselect(dateFormatter.date(from: startTime)!)
                calendar.deselect(dateFormatter.date(from: endTime)!)
                endTime = ""
                startTime = dateFormatter.string(from: date)
                isSomeDay = true
            }else if startTime != ""{
                
                endTime = dateFormatter.string(from: date)
                if date.compare(self.dateFormatter.date(from: startTime)!)==ComparisonResult.orderedAscending {
                    calendar.deselect(dateFormatter.date(from: startTime)!)
                    endTime = ""
                    startTime = dateFormatter.string(from: date)
                    isSomeDay = true
                }
            }else {
                
                startTime = dateFormatter.string(from: date)
                isSomeDay = true
            }
            
            if !startTime.isEmpty && !endTime.isEmpty {

                if (selectCalendarBlock != nil) {
                    selectCalendarBlock?(startTime,endTime)
                }
                //MARK:-DCG延时执行
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            calendar.reloadData()
            configureVisibleCells()
        }else{
            
            endTime = dateFormatter.string(from: date)
            startTime = dateFormatter.string(from: date)
            calendar.reloadData()
            configureVisibleCells()

            if (selectCalendarBlock != nil) {
                selectCalendarBlock?(startTime,endTime)
            }
            
            self.navigationController?.popViewController(animated: true)

        }
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        self.configureVisibleCells()
        print(calendar.selectedDates.count)
        
        /// 往返选择同一天回调
        if isBackTracking {
            
            if isSomeDay{
                endTime = self.dateFormatter.string(from: date)
                calendar.select(date)
                self.calendar.reloadData()
                if (selectCalendarBlock != nil) {
                    selectCalendarBlock?(self.dateFormatter.string(from: date),self.dateFormatter.string(from: date))
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
            }else{
                
                if isFirst{
                    
                    endTime = dateFormatter.string(from: date)
                    calendar.select(date)
                    calendar.reloadData()
                    if (selectCalendarBlock != nil) {
                        selectCalendarBlock?(startTime,endTime)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    
                }else{
                    
                    ///再次进入选择同一天
                    calendar.deselect(dateFormatter.date(from: startTime)!)
                    calendar.deselect(dateFormatter.date(from: endTime)!)
                    endTime = ""
                    startTime = dateFormatter.string(from: date)
                    calendar.select(date)
                    calendar.reloadData()
                    isFirst = true
                }
                
            }
        }else{
            calendar.select(date)
            calendar.reloadData()
            startTime = self.dateFormatter.string(from: date)

            if (selectCalendarBlock != nil) {
                selectCalendarBlock?(startTime,"")
            }
            self.navigationController?.popViewController(animated: true)
            
            
        }
        print("did deselect date \(self.dateFormatter.string(from: date))")
        
    }
    
    //MARK:-绘制当前选择的日期
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let rangeCell = (cell as! FPCalendarCell)
        if position != .current {
            rangeCell.middleLayer.isHidden = true
            rangeCell.selectionLayer.isHidden = true
            return
        }
        
        if !endTime.isEmpty && !startTime.isEmpty{
            let isMiddle = date.compare(self.dateFormatter.date(from: startTime)!)==ComparisonResult.orderedDescending && date.compare(self.dateFormatter.date(from: endTime)!)==ComparisonResult.orderedAscending
            
            rangeCell.middleLayer.isHidden = !isMiddle
            
        }else{
            
            rangeCell.middleLayer.isHidden = true
        }
        
        let isStart = (self.dateFormatter.date(from: startTime) != nil) && self.gregorian.isDate(date, inSameDayAs: self.dateFormatter.date(from: startTime)!)
        
        let isEnd = (self.dateFormatter.date(from: endTime) != nil) && self.gregorian.isDate(date, inSameDayAs: self.dateFormatter.date(from: endTime)!)
        
        rangeCell.selectionLayer.isHidden = !isEnd && !isStart
    }

}
