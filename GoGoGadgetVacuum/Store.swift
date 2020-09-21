//
//  Store.swift
//  GoGoGadgetVacuum
//
//  Created by Vipul Delwadia on 21/07/19.
//  Copyright © 2019 Vipul Delwadia. All rights reserved.
//

import CloudKit

class Store {
    static let shared = Store()
    static let recordName = "GoGoGadgetVacuum"

    var subscription: CKSubscription?

    init() {
//        updateFromiCloud()
        updateFromCloudKit()

//        NotificationCenter.default.addObserver(self, selector: #selector(updateFromiCloud), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private(set) var lastCommand: Command? {
        didSet {
            if let command = lastCommand {
                AudioPlayer.shared.handleCommand(command)
            }
        }
    }

    func setCommand(_ command: Command?) {
        lastCommand = command
//        updateiCloud()
        updateCloudKit()
    }

    func updateCloudKit() {
        let database = CKContainer.default().privateCloudDatabase
        let recordID = CKRecord.ID(recordName: Store.recordName)
        database.fetch(withRecordID: recordID) { [weak self] record, error in
            var newRecord: CKRecord?
            if let error = error {
                print("failed to fetch record, error:", error)
                if error.localizedDescription.contains("Record not found") {
                    newRecord = self?.createRecord()
                }
            }
            if let record = record ?? newRecord {
                record.setObject(self?.lastCommand?.rawValue as NSString?, forKey: RemoteClientStatus.playingStatus)
                database.save(record) { record, error in
                    if let error = error {
                        print("failed to save record, error:", error)
                    }
                    if let record = record {
                        print("woo-hoo, saved record:", record)
                    }
                }
            }
        }
    }

    func updateFromCloudKit(with recordID: CKRecord.ID = CKRecord.ID(recordName: Store.recordName)) {
        let database = CKContainer.default().privateCloudDatabase
        database.fetch(withRecordID: recordID) { [weak self] record, error in
            if let error = error {
                print("failed to find record, error:", error)
            }
            else if let record = record, let self = self {
                print("found record:", record)
                if self.subscription == nil {
                    self.setupSubscription(with: record.recordID)
                }
                if let status = record.object(forKey: RemoteClientStatus.playingStatus) as? String,
                    let command = Command(rawValue: status) {
                    self.lastCommand = command
                }
            }
        }
    }

    func setupSubscription(with recordID: CKRecord.ID) {
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let predicate = NSPredicate(format: "recordID = %@", reference)
        let subscription = CKSubscription(recordType: RemoteRecord.ClientStatus, predicate: predicate, options: [.firesOnRecordUpdate])
        let info = CKSubscription.NotificationInfo()
        info.desiredKeys = [RemoteClientStatus.playingStatus]
        info.shouldBadge = true
        subscription.notificationInfo = info

        CKContainer.default().privateCloudDatabase.save(subscription) { [weak self] subscription, error in
            if let error = error {
                print("failed to save subscription:", error)
            }
            else if let subscription = subscription {
                self?.subscription = subscription
                print("saved subscription:", subscription)
            }
        }
    }

    private func createRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: Store.recordName)
        let record = CKRecord(recordType: RemoteRecord.ClientStatus, recordID: recordID)
        record.setObject(lastCommand?.rawValue as NSString?, forKey: RemoteClientStatus.playingStatus)
        return record
    }


//    func updateiCloud() {
//        NSUbiquitousKeyValueStore.default.set(lastCommand?.rawValue, forKey: Command.StorageKey)
//        NSUbiquitousKeyValueStore.default.synchronize()
//    }
//
//    @objc
//    func updateFromiCloud(_ notification: NSNotification? = nil) {
//        if let commandValue = NSUbiquitousKeyValueStore.default.string(forKey: Command.StorageKey) {
//            lastCommand = Command(rawValue: commandValue)
//        }
//    }
}
