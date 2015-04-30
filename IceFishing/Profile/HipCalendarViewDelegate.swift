//
//  HipCalendarViewDelegate.swift
//  IceFishing
//
//  Created by Annie Cheng on 4/28/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import Foundation

protocol HipCalendarViewDelegate {

    func hipCalendarView(hipCalendarView: HipCalendarView, didSelectDate date: NSDate)
    func hipCalendarView(hipCalendarView: HipCalendarView, didSelectItemAtIndexPath indexPath: NSIndexPath)

}