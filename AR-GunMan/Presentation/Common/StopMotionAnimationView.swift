//
//  StopMotionAnimationView.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 22/12/24.
//

import SwiftUI

// 任意のビューを指定した間隔でコマ送り表示するビュー
struct StopMotionAnimationView: View {
    @State private var currentIndex = 0
    @State private var timer: Timer?
    let updateInterval: TimeInterval
    let contentList: [AnyView]
    
    var body: some View {
        contentList[currentIndex]
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
                    if currentIndex == (contentList.count - 1) {
                        currentIndex = 0
                    }else {
                        currentIndex += 1
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
}
