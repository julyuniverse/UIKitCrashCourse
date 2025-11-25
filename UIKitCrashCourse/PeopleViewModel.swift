//
//  PeopleViewModel.swift
//  UIKitCrashCourse
//
//  Created by July universe on 11/22/25.
//

import Foundation

protocol PeopleViewModelDeletegate: AnyObject {
    func didFinish()
    func didFail(error: Error)
}

class PeopleViewModel {
    private(set) var people = [PersonResponse]()
    weak var deletegate: PeopleViewModelDeletegate?
    
    func getUsers() {
        Task { [weak self] in
            do {
                let url = URL(string: "https://reqres.in/api/users")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
                let (data, _) = try await URLSession.shared.data(for: request)
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                self?.people = try jsonDecoder.decode(UsersResponse.self, from: data).data
                self?.deletegate?.didFinish()
            } catch {
                self?.deletegate?.didFail(error: error)
            }
        }
    }
}
