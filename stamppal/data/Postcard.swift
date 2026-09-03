//
//  Postcard.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class Postcard {
    var id: UUID
    var imageName: String?
    var imageData: Data?
    var sender: String
    var recipient: String?
    var date: String
    var message: String
    var stampData: Data?
    var groupCode: String?
    var senderUsername: String?
    var senderDisplayName: String?

    var isRead: Bool = false

    init(
        id: UUID = UUID(),
        imageName: String? = nil,
        imageData: Data? = nil,
        sender: String,
        recipient: String? = nil,
        date: String,
        message: String,
        stampData: Data? = nil,
        groupCode: String? = nil,
        senderUsername: String? = nil,
        senderDisplayName: String? = nil,
        isRead: Bool = false
    ) {
        self.id = id
        self.imageName = imageName
        self.imageData = imageData
        self.sender = sender
        self.recipient = recipient
        self.date = date
        self.message = message
        self.stampData = stampData
        self.groupCode = groupCode
        self.senderUsername = senderUsername
        self.senderDisplayName = senderDisplayName
        self.isRead = isRead
    }
}
// MARK: - Sample Data
extension Postcard {
    static let samplePostcards: [Postcard] = [
        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            recipient: "User",
            date: "01 August 2026",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        ),
        Postcard(
            imageName: "placeholderImage",
            sender: "Alverz Belinza",
            recipient: "User",
            date: "01 August 2026",
            message: "Hello! I hope you are having a wonderful day."
        ),
        Postcard(
            imageName: "placeholderImage",
            sender: "Anita Michiko Tamala",
            recipient: "User",
            date: "01 August 2026",
            message: "Greetings from holiday! The view here is wonderful."
        )
    ]
}
