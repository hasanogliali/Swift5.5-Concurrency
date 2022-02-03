//
//  GroupTaskViewController.swift
//  TestProj
//
//  Created by Ali Hasanoğlu on 26.01.2022.
//

import UIKit

class GroupTaskViewController: UIViewController {
        
    let calendar = Calendar.current
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSeveralThings()
    }
    
    typealias GroupTaskContent = (user: [User]?, post: [Post]?)
    
    func fetchContent() async throws -> GroupTaskContent {
        async let users = ContentProvider.default.fetch([User].self, url: usersUrl)
        async let posts = ContentProvider.default.fetch([Post].self, url: postsUrl)
        return (try await users, try await posts)
    }
    
    func fetchDatas(with ids: [String]) async throws -> [String: GroupTaskContent] {
        var output = [String: GroupTaskContent]()
        // 1
        
//        for id in ids {
//            output[id] = try await fetchContent()
//        }
        
        // 2
        try await withThrowingTaskGroup(of: (String, GroupTaskContent).self, body: { group in
            for id in ids {
                group.addTask {
                    return (id, try await self.fetchContent())
                }
                for try await (id, result) in group {
                    output[id] = result
                }
            }
        })
        
        return output
    }
    
    func getSeveralThings() {
        Task {
            do {
                let asyncAwaitStart = Date.now
                let _ = try await fetchDatas(with: ["1", "2", "3", "4", "5"])
                let asyncAwaitEnd = Date.now
                
                let asyncAwaitTime = calendar.dateComponents([.nanosecond], from: asyncAwaitStart, to: asyncAwaitEnd).nanosecond!
                print("**********************************************")
                print("Group task takes \(asyncAwaitTime) nanosecond")
                print("Group task has \(String(asyncAwaitTime).count) character")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}


//Non-Group task takes 969236816 nanosecond
//Non-Group task has 9 character
