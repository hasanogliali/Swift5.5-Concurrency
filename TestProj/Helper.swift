//
//  Helper.swift
//  TestProj
//
//  Created by Ali Hasanoğlu on 26.01.2022.
//

import Foundation
import UIKit

let usersUrl = URL(string: "https://jsonplaceholder.typicode.com/users")!
let postsUrl = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let imageUrl = URL(string: "http://picsum.photos/v2/list?limit=10")!

struct User: Decodable {
    public let id: Int?
    public let name, userName: String?
}

struct Post: Decodable {
    public let id, userId: Int?
    public let title, body: String?
}

struct Todo: Decodable {
    let id, userId: Int?
    let title: String?
    let completed: Bool?
}

struct Image: Decodable {
    let download_url: String?
}

enum AppError: Error {
    case httpError
}

enum ContentProvider {
    case `default`
    
    func fetch<T: Decodable>(_ type: T.Type, url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AppError.httpError
        }
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func downloadImage(with url: URL) async throws -> UIImage {
        let imageRequest = URLRequest(url: url)
        let (data, imageResponse) = try await URLSession.shared.data(for: imageRequest)
        guard let image = UIImage(data: data),
                (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw AppError.httpError
        }
        return image
    }
}
