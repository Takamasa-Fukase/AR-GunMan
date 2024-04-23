//
//  SceneNodeUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/18.
//

import Foundation
import SceneKit

final class SceneNodeUtil {
    //常にカメラを向く制約
    static func addBillboardConstraint(_ node: SCNNode) {
        node.constraints = [SCNBillboardConstraint()]
    }
    
    //カメラと同じ位置に配置
    static func getCameraPosition(_ scnView: SCNView) -> SCNVector3 {
        return scnView.pointOfView?.position ?? SCNVector3()
    }
    
    //scnファイルからノードを読み込む
    static func loadScnFile(of path: String, nodeName: String) -> SCNNode {
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        guard let node = SCNScene(named: path)?.rootNode.childNode(withName: nodeName, recursively: false) else {
            print("loadScnFile失敗　ファイルパス(\(path))またはnodeのname(\(nodeName))が間違っています")
            return SCNNode()
        }
        return node
    }

    static func getRandomTargetPosition() -> SCNVector3 {
        let randomX = Float.random(in: -3...3)
        let randomY = Float.random(in: -1.5...2)
        let randomZfirst = Float.random(in: -3...(-0.5))
        let randomZsecond = Float.random(in: 0.5...3)
        let randomZthird = Float.random(in: -3...3)
        var randomZ: Float?
        
        // 原点0（プレーヤーの初期位置）の超至近距離に的を集中させずに、
        // なるべくばらけさせることができる様に制御する
        if randomX < -0.5 || randomX > 0.5 || randomY < -0.5 || randomY > 0.5 {
            // XとYのどちらかが原点0から0.5より離れている場合は、
            // 原点0に近い値（-0.5 ~ 0.5）も含めてユーザーの近くも遠くも両方含めた範囲のZのランダム値を渡す
            randomZ = randomZthird
            
        }else {
            // それに対し、XもYも両方原点0に近い値（-0.5 ~ 0.5）になった場合はZだけは、
            // （-0.5 ~ 0.5）の範囲を除外した値から選ばせて、最低でもユーザーから0.5より離れさせる
            randomZ = [randomZfirst, randomZsecond].randomElement()
        }
        return SCNVector3(x: randomX, y: randomY, z: randomZ ?? 0)
    }
    
    static func removeOtherWeapon(except type: WeaponType, scnView: SCNView) {
        var nodeNames: [String] {
            switch type {
            case .pistol:
                return ["bazookaParent"]
            case .bazooka:
                return ["pistolParent"]
            }
        }
        nodeNames.forEach({ item in
            if let node = scnView.scene?.rootNode.childNode(withName: item, recursively: false) {
                print("\(item)を削除しました")
                node.removeFromParentNode()
            }
        })
    }
    
    static func isPlayerRunning(pos1: SCNVector3, pos2: SCNVector3) -> Bool {
        let distance = getDistance(from: pos1, to: pos2)
//            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")
        return (distance >= 0.15)
    }
    
    //２座標間の距離を計算（単位:m）
    private static func getDistance(from pos1: SCNVector3, to pos2: SCNVector3) -> Float {
        let diff = SCNVector3Make(pos1.x - pos2.x, pos1.y - pos2.y, pos1.z - pos2.z)
        return sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
    }
}
