//
//  AdminController.swift
//  Dine
//
//  Created by doss-zstch1212 on 23/01/24.
//

import Foundation

protocol AdminPrivilages {
    func removeAccount(user: Account) throws
    func getAccounts() throws -> [Account]?
    func changePassword(for username: String, to newPassword: String) throws
}

struct AdminController: AdminPrivilages {
    private let accountService: AccountService
    init(accountService: AccountService) {
        self.accountService = accountService
    }
    
    func removeAccount(user: Account) throws {
        try accountService.delete(user)
    }
    
    func getAccounts() throws -> [Account]? {
        try accountService.fetch()
    }
    
    func changePassword(for username: String, to newPassword: String) throws {
        guard AuthenticationValidator.isStrongPassword(newPassword) else {
            throw AuthenticationError.notStrongPassword
        }
        /*let columnPair = ["Password": "'\(newPassword)'"]
        let whereCondition = "Username = '\(username)'"*/
        if let account = fetchUser(with: username) {
            account.updatePassword(newPassword)
            try accountService.update(account)
        } else {
            print("Failed to perform fetch/no accounts under the username \(username)")
        }
    }
    
    private func fetchUser(with username: String) -> Account? {
        do {
            guard let resultUsers = try accountService.fetch() else { return nil }
            guard let userIndex = resultUsers.firstIndex(where: { $0.username == username }) else { return nil }
            let user = resultUsers[userIndex]
            return user
        } catch {
            print("Failed to perform \(#function): \(error)")
        }
        return nil
    }
    
}
