//
//  FirestoreClient.swift
//  Data
//
//  Created by ウルトラ深瀬 on 29/1/25.
//

import Foundation
import FirebaseFirestore

public final class FirestoreClient {
    private let db = Firestore.firestore()
    
    public init() {}
    
    public func getItems<ResponseEntity: Decodable>(collectionPath: String) async throws -> [ResponseEntity] {
        // TODO: エラーをそのまま流すのではなく、ここでCustomErrorに変換する
        return try await db
            .collection(collectionPath)
            .getDocuments()
            .documents
            .compactMap { queryDocSnapshot in
                return try? queryDocSnapshot.data(as: ResponseEntity.self)
            }
    }
    
    public func addItem(collectionPath: String, requestEntity: Encodable) async throws {
        // TODO: エラーをそのまま流すのではなく、ここでCustomErrorに変換する
        try await db
            .collection(collectionPath)
            .document()
            .setData(requestEntity.toJson())
    }
}
