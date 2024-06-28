//
//  APIRequestor.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/6/24.
//

import RxSwift
import Firebase
import FirebaseFirestoreSwift

final class APIRequestor<ResponseEntity: Decodable> {
    private let firestoreDB = Firestore.firestore()
    
    func getItems(_ path: String) -> Single<[ResponseEntity]> {
        return Single.create { [weak self] observer in
            self?.firestoreDB
                .collection(path)
                .getDocuments { querySnapshot, error in
                    guard let querySnapshot = querySnapshot else {
                        if let error = error {
                            observer(.failure(CustomError.apiClientError(error)))
                        }else {
                            observer(.failure(CustomError.manualError(ErrorConst.unknownErrorMessage)))
                        }
                        return
                    }
                    let items = querySnapshot
                        .documents
                        .compactMap({ queryDocSnapshot in
                            return try? queryDocSnapshot.data(as: ResponseEntity.self)
                        })
                    observer(.success(items))
                }
            return Disposables.create()
        }
    }
    
    func postItem(_ path: String, parameters: [String: Any]) -> Single<Void> {
        return Single.create { [weak self] observer in
            self?.firestoreDB
                .collection(path)
                .document()
                .setData(parameters) { error in
                    if let error = error {
                        observer(.failure(CustomError.apiClientError(error)))
                    }else {
                        observer(.success(()))
                    }
                }
            return Disposables.create()
        }
    }
}
