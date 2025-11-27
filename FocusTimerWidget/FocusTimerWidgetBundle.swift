//
//  FocusTimerWidgetBundle.swift
//  FocusTimerWidget
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/27.
//

import WidgetKit
import SwiftUI

@main
struct FocusTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusTimerWidget()
        FocusTimerWidgetControl()
        FocusTimerWidgetLiveActivity()
    }
}
