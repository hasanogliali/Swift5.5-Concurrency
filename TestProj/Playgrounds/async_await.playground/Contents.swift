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
    
    func fetchTodo() async throws -> [Todo]? {
        let (data, response) = try await URLSession.shared.data(from: todosUrl)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AppError.httpError
        }
        return try JSONDecoder().decode([Todo].self, from: data)
    }
}

func getTodosWithClosures() {
    ContentProvider.default.fetchTodo { result in
        switch result {
        case let .success(response):
            dump(response)
        case let .failure(error):
            print(error.localizedDescription)
        }
    }
}

func getTodosWithAsync() {
    Task {
        do {
            let result = try await ContentProvider.default.fetchTodo()
            dump(result)
        } catch {
            print(error.localizedDescription)
        }
    }
}

getTodosWithAsync()



/*
 *** async/await vs closures ***
 
 - readability
 - weak references
 - all possible case need to complete in closures
 - order of execution
 - performance (pizza hazırlama örneği)
*/
