//
//  SceneNodeUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/18.
//

import Foundation
import SceneKit

class SceneNodeUtil {
    
    //常にカメラを向く制約
    static func addBillboardConstraint(_ node: SCNNode) {
        node.constraints = [SCNBillboardConstraint()]
    }
    
    //カメラと同じ位置に配置
    static func positionAsSameAsCamera(_ node: SCNNode, scnView: SCNView) {
        node.position = scnView.pointOfView?.position ?? SCNVector3()
    }
    
    //scnファイルからノードを読み込む
    static func loadScnFile(of path: String, nodeName: String) -> SCNNode {
        //注意:scnのファイル名ではなく、Identity欄のnameを指定する
        guard let node = SCNScene(named: path)?.rootNode.childNode(withName: "parent", recursively: false) else {
            print("loadScnFile失敗　ファイルパスまたはnodeのnameが間違っています")
            return SCNNode()
        }
        return node
    }
    
    static func addWeapon(of type: WeaponTypes, scnView: SCNView) {
        var node: SCNNode {
            switch type {
            case .pistol:
                return loadScnFile(of: "art.scnassets/Weapon/Pistol/M1911_a.scn", nodeName: "parent")
            case .bazooka:
                return loadScnFile(of: "art.scnassets/Weapon/RocketLauncher/bazooka2.scn", nodeName: "bazookaParent")
            default:
                return SCNNode()
            }
        }
        SceneNodeUtil.addBillboardConstraint(node)
        SceneNodeUtil.positionAsSameAsCamera(node, scnView: scnView)
        scnView.scene?.rootNode.addChildNode(node)
    }
    
    static func getRandomTargetPosition() -> SCNVector3 {
        let randomX = Float.random(in: -3...3)
        let randomY = Float.random(in: -1.5...2)
        let randomZfirst = Float.random(in: -3...(-0.5))
        let randomZsecond = Float.random(in: 0.5...3)
        let randomZthird = Float.random(in: -3...3)
        var randomZ: Float?
        
        if randomX < -0.5 || randomX > 0.5 || randomY < -0.5 || randomY > 0.5 {
            randomZ = randomZthird
        }else {
            randomZ = [randomZfirst, randomZsecond].randomElement()
        }
        return SCNVector3(x: randomX, y: randomY, z: randomZ ?? 0)
    }
}
