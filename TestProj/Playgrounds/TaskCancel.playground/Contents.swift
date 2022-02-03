import UIKit
import Foundation

let usersUrl = "https://jsonplaceholder.typicode.com/users/"

struct User: Decodable {
    public let id: Int?
    public let name, userName: String?
}


enum AppError: Error {
    case httpError
}

enum ContentProvider {
    case `default`
    
    private func fetch<T: Decodable>(_ type: T.Type, url: URL) async throws -> T {
        try Task.checkCancellation()
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AppError.httpError
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func fetchUsers(ids: [Int]) async throws -> [User] {
        var users: [User] = []
        for id in ids {
            let user = try await fetch(User.self, url: URL(string: "\(usersUrl)\(id)")!)
            users.append(user)
        }
        return users
    }
}

let userIds = [1, 2, 11, 3, 4, 5]
let task = Task {
    let users = try await ContentProvider.default.fetchUsers(ids: userIds)
    users.forEach { print("User: \($0.name ?? "")")}
}

func getUsersWithAsync() {
    userIds.forEach {
        if $0 > 10 { task.cancel() }
    }
    Task {
        do {
            try await task.result.get()
        } catch let error {
            print(error)
        }
    }
}

getUsersWithAsync()
