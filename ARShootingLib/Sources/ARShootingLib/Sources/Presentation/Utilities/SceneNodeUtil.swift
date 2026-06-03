//
//  SceneNodeUtil.swift
//  ARShooting
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
    
    //カメラと同じ位置に配置する時に使う
    static func getCameraPosition(_ scnView: SCNView) -> SCNVector3 {
        return scnView.pointOfView?.position ?? SCNVector3()
    }
    
    // scnファイルからノードを読み込む
    static func loadScnNode(fileName: String, nodeName: String) -> SCNNode {
        guard let url = Bundle.module.url(forResource: fileName, withExtension: "scn"),
              let scene = try? SCNScene(url: url, options: nil),
              // 注意: childNode(withName:)にはscnのファイル名ではなく、Identity欄のnameを指定する
              let node = scene.rootNode.childNode(withName: nodeName, recursively: false)
        else {
            print("loadScnFile失敗　ファイル名(\(fileName)), またはnodeのname(\(nodeName))が間違っています")
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

    static func originalBulletNode() -> SCNNode {
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        sphere.firstMaterial?.diffuse.contents = customYellow
        
        let bulletNode = SCNNode(geometry: sphere)
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        // 衝突検知時に判別する為の名前を設定
        bulletNode.name = "bullet"
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false
        return bulletNode
    }
    
    static func originalTargetNode() -> SCNNode {
        let targetNode = SceneNodeUtil.loadScnNode(fileName: "target", nodeName: "target")
        
        targetNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let targetNodeGeometry = (targetNode.childNode(withName: "sphere", recursively: false)?.geometry) ?? SCNGeometry()
        
        // ①形状はラップしてる空のNodeではなく何か1つgeometryを持っているものを指定する
        // ②当たり判定のscaleはoptions: [SCNPhysicsShape.Option.scale: SCNVector3]で明示的に設定する（大体①のgeometryの元となっているNodeのscaleを代入すれば等しい当たり判定になる）
        let shape = SCNPhysicsShape(geometry: targetNodeGeometry, options: [SCNPhysicsShape.Option.scale: targetNode.scale])
        
        //当たり判定用のphysicBodyを追加
        targetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        targetNode.physicsBody?.isAffectedByGravity = false
        
        return targetNode
    }
}
