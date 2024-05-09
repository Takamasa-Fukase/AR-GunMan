//
//  GameSceneConst.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/09.
//

import Foundation
import SceneKit

final class GameSceneConst {
    static let bulletNode: SCNNode = {
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        sphere.firstMaterial?.diffuse.contents = customYellow
        
        let bulletNode = SCNNode(geometry: sphere)
        bulletNode.name = GameConst.bulletNodeName
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false
        return bulletNode
    }()
}
