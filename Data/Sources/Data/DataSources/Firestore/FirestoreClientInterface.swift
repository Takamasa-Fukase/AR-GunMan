//
//  FirestoreClientInterface.swift
//  Data
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation

public protocol FirestoreClientInterface {
    func getItems<ResponseEntity: Decodable>(collectionPath: String) async throws -> [ResponseEntity]
    func addItem(collectionPath: String, requestEntity: Encodable) async throws
}
