//
//  Model.swift
//  UIKitCrashCourse
//
//  Created by July universe on 11/22/25.
//

import Foundation

struct UsersResponse: Codable {
    let data: [PersonResponse]
}

struct PersonResponse: Codable {
    let email: String
    let firstName: String
    let lastName: String
}
