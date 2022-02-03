//
//  ActorViewController.swift
//  TestProj
//
//  Created by Ali Hasanoğlu on 31.01.2022.
//

import UIKit

/*
 - Actors are new type(reference type) in Swift
 - Actors implement all the synchronization mechanisms behind the scenes, their data is isolated from the rest of the program so they protect mutable state
 - They prevent us from """DATA RACES""" while writing concurrent code (atomics, locks, barriers, semaphores etc.)
 - Actors cannot inherit or be inherited from
 - Actors can have methods, properties etc.
 - Actors can conform to protocols
 - Actors can be extend
 - Functions inside actors are normal, if you try to reach outside they take async on their func signature.
 
 - @MainActor -> main thread ( functions and classes )
*/

class ActorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let counter = Counter()
//
//        Task.detached {
//          print(counter.increment())
//        }
//
//        Task.detached {
//          print(counter.increment())
//        }
//
//        Task.detached {
//          print(counter.increment())
//        }
    
        let bankAccount = BankAccount()
        
        Task {
            do {
                try await bankAccount.withdrawAmount(70, tag: "Task 1")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        Task {
            do {
                try await bankAccount.withdrawAmount(80, tag: "Task 2")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

//class Counter {
actor Counter {
    var count = 0
    func increment() -> Int {
        count += 1
        return count
    }
}


// Reenterency
actor BankAccount {
    enum BankError: Error {
        case insufficientFund
        case processFail
    }
    
    private var balance: Double = 100
    
    func withdrawAmount(_ amount: Double, tag: String) async throws {
        print("\(tag) trying to withdraw \(amount)")
        
        guard hasEnoughFund(toWithdrawAmount: amount) else {
            print("\(tag) failed to withdraw \(amount) due to insufficient amount")
            throw BankError.insufficientFund
        }
        
        guard try await waitProcessCompletion() else {
            print("\(tag) process failed")
            throw BankError.processFail
        }
        print("\(tag) process succesfully completed")
        guard hasEnoughFund(toWithdrawAmount: amount) else {
            print("\(tag) failed to withdraw \(amount) due to insufficient amount")
            throw BankError.insufficientFund
        }
        balance -= amount
        print("New balance -> \(balance)")
        
    }
    
    func waitProcessCompletion() async throws -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return true
    }
    
    func hasEnoughFund(toWithdrawAmount amount: Double) -> Bool {
        amount <= balance
    }
}


// Andy Ibanez
// tundsdev
