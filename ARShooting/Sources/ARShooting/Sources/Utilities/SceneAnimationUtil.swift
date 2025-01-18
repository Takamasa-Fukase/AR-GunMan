//
//  SceneAnimationUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation
import SceneKit

final class SceneAnimationUtil {
    //プレーヤーの銃を持つ手の緩やかな揺れを再現するアニメーション
    static let gunnerHandShakingAnimation: SCNAction = {
        //銃の先端が上に跳ね上がる回転のアニメーション
        let rotate = SCNAction.rotateBy(x: -0.1779697224, y: 0.0159312604, z: -0.1784194, duration: 1.2)
        //↑の逆（下に戻る回転）
        let rotateReverse = rotate.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let rotateAction = SCNAction.sequence([rotate, rotateReverse])
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.8)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let moveAction = SCNAction.sequence([moveUp, moveDown])
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.group([rotateAction, moveAction])
        
        //↑を永遠繰り返すアニメーション
        return SCNAction.repeatForever(conbineAction)
    }()
    
    //プレーヤーが素早く移動している時の銃が激しく揺れるアニメーション
    static let gunnerRunningAnimation: SCNAction = {
        //銃が右に移動するアニメーション
        let moveRight = SCNAction.moveBy(x: 0.03, y: 0, z: 0, duration: 0.3)
        //↑の逆（左に移動）
        let moveLeft = moveRight.reversed()
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.02, z: 0, duration: 0.15)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下交互
        let upAndDown = SCNAction.sequence([moveUp, moveDown])
        
        let rightAndUpDown = SCNAction.group([moveRight, upAndDown])
        let LeftAndUpDown = SCNAction.group([moveLeft, upAndDown])
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.sequence([rightAndUpDown, LeftAndUpDown])
        
        //↑を永遠繰り返すアニメーション
        return SCNAction.repeatForever(conbineAction)
    }()
    
    //発砲時の反動アニメーション
    static let recoilAnimation: SCNAction = {
        //発砲時に銃の先端が上に跳ね上がる回転のアニメーション
        let rotateAction = SCNAction.rotateBy(x: -0.9711356901, y: -0.08854044763, z: -1.013580166, duration: 0.1)
        //↑の逆（下に戻る回転）
        let reverse = rotateAction.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        return SCNAction.sequence([rotateAction, reverse])
    }()
    
    //弾を発射させる
    static func bulletShootingAnimation(_ camera: SCNNode?) -> SCNAction {
        guard let camera = camera else { return SCNAction()}
        let targetPosCamera = SCNVector3(x: camera.position.x, y: camera.position.y, z: camera.position.z - 10)
        //カメラ座標をワールド座標に変換
        let target = camera.convertPosition(targetPosCamera, to: nil)
        return SCNAction.move(to: target, duration: TimeInterval(1))
    }
}
