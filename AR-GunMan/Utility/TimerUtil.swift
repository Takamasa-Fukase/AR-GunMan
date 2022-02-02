//
//  TimerUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation

class TimerUtil {
    static func startTimer() -> Timer {
       return Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerUpdate(timer:)), userInfo: nil, repeats: true)
    }
    
    //タイマーで指定間隔ごとに呼ばれる関数
    @objc func timerUpdate(timer: Timer) {
//        let lowwerTime = 0.00
//        timeCount = max(timeCount - 0.01, lowwerTime)
//        let strTimeCount = String(format: "%.2f", timeCount)
//        let twoDigitTimeCount = timeCount > 10 ? "\(strTimeCount)" : "0\(strTimeCount)"
//        timeCountLabel.text = twoDigitTimeCount
//
//        //タイマーが0になったらタイマーを破棄して結果画面へ遷移
//        if timeCount <= 0 {
//
//            timer.invalidate()
//            isShootEnabled = false
//
//            AudioModel.playSound(of: .endWhistle)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//
//                self.viewModel.rankingWillAppear.onNext(Void())
//
//                AudioModel.playSound(of: .rankingAppear)
//
//                let storyboard: UIStoryboard = UIStoryboard(name: "GameResultViewController", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "GameResultViewController") as! GameResultViewController
//
//                let sumPoint: Double = min(self.pistolPoint + self.bazookaPoint, 100.0)
//
//                let totalScore = sumPoint * (Double.random(in: 0.9...1))
//
//                print("pistolP: \(self.pistolPoint), bazookaP: \(self.bazookaPoint), sumP: \(sumPoint) totalScore: \(totalScore)")
//
//                vc.totalScore = totalScore
//                self.present(vc, animated: true)
//            })
            
//        }
    }
}
