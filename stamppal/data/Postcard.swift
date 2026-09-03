//
//  Postcard.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import Foundation

struct Postcard: Identifiable, Equatable {
    
    let id: UUID
    
    let imageName: String
    let sender: String
    let date: String
    let message: String
    
    init(
        id: UUID = UUID(),
        imageName: String,
        sender: String,
        date: String,
        message: String
    ) {
        self.id = id
        self.imageName = imageName
        self.sender = sender
        self.date = date
        self.message = message
    }
}
