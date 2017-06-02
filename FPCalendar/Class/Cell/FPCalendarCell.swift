//
//  FPCalendarCell.swift
//  FPCalendar
//
//  Created by 杨朋 on 2017/6/1.
//  Copyright © 2017年 瑞丽航空. All rights reserved.
//

import UIKit
import FSCalendar
class FPCalendarCell: FSCalendarCell {
    
    weak var selectionLayer: CALayer!
    weak var middleLayer: CALayer!
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectionLayer = CALayer()
        selectionLayer.backgroundColor = UIColor.init(hexString: "29B5EB", alpha: 1).cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        
        let middleLayer = CALayer()
        middleLayer.backgroundColor = UIColor.init(hexString: "29B5EB", alpha: 1).withAlphaComponent(0.3).cgColor
        middleLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(middleLayer, below: self.titleLabel!.layer)
        self.middleLayer = middleLayer
        // false很关键默认选择有 true 默认选择有无
        self.shapeLayer.isHidden = false
        
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.selectionLayer.frame = self.contentView.bounds
        self.middleLayer.frame = self.contentView.bounds
        
    }
    
}
