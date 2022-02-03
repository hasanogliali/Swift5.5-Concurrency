import UIKit

let todosUrl = URL(string: "https://jsonplaceholder.typicode.com/todos")!

struct Todo: Decodable {
    let id, userId: Int?
    let title: String?
    let completed: Bool?
}

enum AppError: Error {
    case httpError
    case decodingError
    case custom(value: Error)
    
    var value: String {
        switch self {
        case .httpError:
            return "http error"
        case .decodingError:
            return "decoding error"
        default:
            return ""
        }
    }
}

enum ContentProvider {
    case `default`
    
    func fetchTodo(completion: @escaping (Result<[Todo]?, AppError>) -> Void) {
        URLSession.shared.dataTask(with: todosUrl, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.custom(value: error)))
                }
            }
            completion(.failure(.httpError))
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.httpError))
                return
            }
            
            do {
                guard let responseData = data else { return }
                let model = try JSONDecoder().decode([Todo].self, from: responseData)
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
}

func getTodos() async throws -> [Todo]? {
    return try await withCheckedThrowingContinuation({ continuation in
        ContentProvider.default.fetchTodo { result in
            switch result {
            case let .success(response):
                continuation.resume(returning: response)
            case let .failure(error):
                continuation.resume(throwing: error)
            }
        }
    })
}

func getTodos() {
    Task {
        do {
            let result = try await getTodos()
            dump(result)
        }
        catch {
            print(error)
        }
    }
}

getTodos()
