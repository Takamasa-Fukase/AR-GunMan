//
//  FirestoreClient.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/05/30.
//

import Foundation
import Core
import Data
import FirebaseFirestore

public final class FirestoreClient: FirestoreClientInterface {
    private let db = Firestore.firestore()
    
    public init() {}
        
    public func getItems<ResponseEntity: Decodable>(collectionPath: String) async throws -> [ResponseEntity] {
        do {
            return try await db
                .collection(collectionPath)
                .getDocuments()
                .documents
                .map { queryDocSnapshot in
                    return try queryDocSnapshot.data(as: ResponseEntity.self)
                }
        } catch {
            throw CustomError.apiClientError(error)
        }
    }
    
    public func addItem(collectionPath: String, requestEntity: Encodable) async throws {
        do {
            try await db
                .collection(collectionPath)
                .document()
                .setData(requestEntity.toJson())
        } catch {
            throw CustomError.apiClientError(error)
        }
    }
}
