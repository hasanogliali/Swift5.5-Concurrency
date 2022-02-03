import UIKit
import Foundation

let usersUrl = URL(string: "https://jsonplaceholder.typicode.com/users")!
let postsUrl = URL(string: "https://jsonplaceholder.typicode.com/posts")!

struct User: Decodable {
    public let id: Int?
    public let name, userName: String?
}

struct Post: Decodable {
    public let id, userId: Int?
    public let title, body: String?
}

enum AppError: Error {
    case httpError
    case decodingError
    case custom(value: Error)
}


typealias Content = (users: [User]?, posts: [Post]?)
typealias ContentHandler = (Result<Content, Error>) -> Void


enum ContentProvider {
    case `default`

    private func fetch<T: Decodable>(
        _ type: T.Type,
        url: URL,
        completion: @escaping (Result<T?, AppError>) -> Void
    ) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.custom(value: error)))
                }
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.httpError))
                return
            }

            do {
                guard let responseData = data else { return }
                let model = try JSONDecoder().decode(T.self, from: responseData)
                DispatchQueue.main.async {
                    completion(.success(model))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }).resume()
    }
    
    func fetchContent(completion: @escaping ContentHandler) {
        // 1
        fetch([User].self, url: usersUrl) { result in
            // 3
            switch result {
            case let .success(users):
                let userList = users
                // 4
                fetch([Post].self, url: postsUrl) { result in
                    // 6
                    switch result {
                    case let .success(posts):
                        let postList = posts
                        completion(.success((userList, postList)))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
                // 5
            case let .failure(error):
                completion(.failure(error))
            }
        }
        // 2
    }
    
    func fetch<T: Decodable> (_ type: T.Type, url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AppError.httpError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetchContent() async throws -> Content {
        let users = try await fetch([User].self, url: usersUrl)
        let posts = try await fetch([Post].self, url: postsUrl)
        return (users, posts)
    }
}


func getContensUnstructured() {
    ContentProvider.default.fetchContent { result in
        switch result {
        case let .success(content):
            dump(content.users)
            dump(content.posts)
        case let .failure(error):
            print(error.localizedDescription)
        }
    }
}

func getContentAsync(){
    Task {
        do {
            let result = try await ContentProvider.default.fetchContent()
            dump(result)
        } catch {
            print(error.localizedDescription)
        }
    }
}

getContentAsync()
