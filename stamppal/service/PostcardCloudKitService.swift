//
//  PostcardCloudKitService.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//


//
//  PostcardCloudKitService.swift
//  stamppal
//

import Foundation
import CloudKit

final class PostcardCloudKitService {

    static let shared = PostcardCloudKitService()

    private let container =
        CKContainer.default()

    private var privateDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    private var sharedDatabase: CKDatabase {
        container.sharedCloudDatabase
    }


    // MARK: - Save Postcard

    func savePostcard(
        _ postcard: Postcard
    ) async throws -> CKRecord {

        let recordID = CKRecord.ID(
            recordName: postcard.id.uuidString
        )

        let record = CKRecord(
            recordType: "Postcard",
            recordID: recordID
        )

        record["imageName"] =
        postcard.imageName as! any CKRecordValue as CKRecordValue

        record["sender"] =
            postcard.sender as CKRecordValue

        record["date"] =
            postcard.date as CKRecordValue

        record["message"] =
            postcard.message as CKRecordValue

        return try await privateDatabase.save(
            record
        )
    }


    // MARK: - Fetch Shared Postcards

    func fetchSharedPostcards()
    async throws -> [Postcard] {

        let query = CKQuery(
            recordType: "Postcard",
            predicate: NSPredicate(
                value: true
            )
        )

        let result =
            try await sharedDatabase.records(
                matching: query
            )

        return result.matchResults.compactMap {
            _, result in

            guard
                let record = try? result.get(),
                let imageName =
                    record["imageName"] as? String,
                let sender =
                    record["sender"] as? String,
                let date =
                    record["date"] as? String,
                let message =
                    record["message"] as? String
            else {
                return nil
            }

            guard let uuid =
                UUID(
                    uuidString: record.recordID.recordName
                )
            else {
                return nil
            }

            return Postcard(
                id: uuid,
                imageName: imageName,
                sender: sender,
                date: date,
                message: message
            )
        }
    }
}
