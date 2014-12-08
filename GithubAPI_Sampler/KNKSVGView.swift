//
//  KNKSVGView.swift
//  KNKSVGParser
//
//  Created by Ken Tominaga on 12/8/14.
//  Copyright (c) 2014 Ken Tominaga. All rights reserved.
//

import UIKit

extension String {
    func point() -> CGPoint? {
        
        if let lb = self.rangeOfString("translate(") {
            if let rb = self.rangeOfString(")") {
                let points = self.substringWithRange(Range(start: lb.endIndex, end: rb.startIndex)).componentsSeparatedByString(", ")
                let x = CGFloat(points[0].toInt()!)
                let y = CGFloat(points[1].toInt()!)
                
                return CGPointMake(x, y)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

class KNKSVGRect {
    let width: CGFloat
    let height: CGFloat
    let color: UIColor
    let y: CGFloat
    let dataCount: Int
    let dataDate: NSDate
    
    init(rectData: JSON) {
        self.width = CGFloat(rectData["width"].intValue)
        self.height = CGFloat(rectData["height"].intValue)
        self.color = UIColor(rgba: rectData["fill"].stringValue)
        self.y = CGFloat(rectData["y"].intValue)
        self.dataCount = rectData["data-count"].intValue
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.dataDate = df.dateFromString(rectData["data-date"].stringValue)!
        // println(df.stringFromDate(self.dataDate))
    }
}

class KNKSVGColumn {
    var svg_rects: [KNKSVGRect] = []
    let offset: CGPoint
    init(column: JSON) {
       
        for rect in column["rect"].arrayValue {
            self.svg_rects.append(KNKSVGRect(rectData: rect))
        }
        
        self.offset = column["transform"].stringValue.point()!
    }
}

class KNKSVGView: UIView {

    let userName: String
    
    let width: CGFloat
    let height: CGFloat
    let offset: CGPoint
    var columns: [KNKSVGColumn] = []
    
    init(userName: String) {
        self.userName = userName
        let url = NSURL(string: "https://github.com/users/\(self.userName)/contributions")
        let parser = SHXMLParser()
        let result = parser.parseData(NSData(contentsOfURL: url!))
        let svgInfo = JSON(result)
        
        self.width = CGFloat(svgInfo["svg"]["width"].intValue)
        self.height = CGFloat(svgInfo["svg"]["height"].intValue)
        self.offset = svgInfo["svg"]["g"]["transform"].stringValue.point()!
        
        for column in svgInfo["svg"]["g"]["g"].arrayValue {
            self.columns.append(KNKSVGColumn(column: column))
        }
        
        super.init(frame: CGRectMake(0, 0, self.width - self.offset.x, self.height - self.offset.y))
        self.backgroundColor = UIColor.whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        for column in columns {
            for svg_rect in column.svg_rects {
                let paint = UIBezierPath(rect: CGRectMake(column.offset.x, column.offset.y + svg_rect.y, svg_rect.width, svg_rect.height))
                svg_rect.color.setFill()
                paint.fill()
            }
        }
    }
    
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
