//
//  ViewController.swift
//  TestProj
//
//  Created by Ali Hasanoğlu on 1.12.2021.
//

import UIKit

class AsyncLetController: UIViewController {

    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let asyncAwaitStart = Date.now
                let _ = try await ContentProvider.default.fetch([User].self, url: usersUrl)
                let _ = try await ContentProvider.default.fetch([Post].self, url: postsUrl)
                let asyncAwaitEnd = Date.now
                let asyncAwaitTime = calendar.dateComponents([.nanosecond], from: asyncAwaitStart, to: asyncAwaitEnd).nanosecond!
                print("**********************************************")
                print("async-await takes \(asyncAwaitTime) nanosecond")
                print("async-await has \(String(asyncAwaitTime).count) character")
                
                let asyncLetStart = Date.now
                async let users = ContentProvider.default.fetch([User].self, url: usersUrl)
                async let posts = ContentProvider.default.fetch([Post].self, url: postsUrl)
                let _ = try await [users, posts] as [Any]
                
                let asyncLetEnd = Date.now
                let asyncLetTime = calendar.dateComponents([.nanosecond], from: asyncLetStart, to: asyncLetEnd).nanosecond!
                print("**********************************************")
                print("async-await takes \(asyncLetTime) nanosecond")
                print("async-await has \(String(asyncLetTime).count) character")
            } catch {
                print(error)
            }
        }
    }
}
