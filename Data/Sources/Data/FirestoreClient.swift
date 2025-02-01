//
//  FirestoreClient.swift
//  Data
//
//  Created by ウルトラ深瀬 on 29/1/25.
//

import Foundation
import Core
import FirebaseFirestore

final class FirestoreClient {
    private let db = Firestore.firestore()
        
    func getItems<ResponseEntity: Decodable>(collectionPath: String) async throws -> [ResponseEntity] {
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
    
    func addItem(collectionPath: String, requestEntity: Encodable) async throws {
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
