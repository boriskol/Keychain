//
//  KeychainMVVM.swift
//  Keychain
//
//  Created by Borna Libertines on 21/04/22.
//


import Foundation
import Security


class Keychain: ObservableObject {
   
   @Published private(set) var user: String?
   @Published var haveUser: Bool = false
   
   private let service: String = "UserMWM"
   //private var user = UUID().uuidString
   
   init() {
      Task {
         //Initialize the store by starting a product request.
         //try await add(value: UUID().uuidString.data(using: .utf8)!, account: "username")
      }
   }

    /// Does a certain item exist?
    @MainActor
    func exists(account: String) async throws {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: false,
            ] as NSDictionary, &result)
        if status == errSecSuccess {
           self.haveUser = true
           try await get(account: "username")
           
        } else if status == errSecItemNotFound {
           self.haveUser = false
           self.user = nil
        } else {
            throw Errors.keychainError
        }
    }
   @MainActor
   private func existsUser(account: String) async throws -> Bool {
           let status = SecItemCopyMatching([
               kSecClass: kSecClassGenericPassword,
               kSecAttrAccount: account,
               kSecAttrService: service,
               kSecReturnData: false,
               ] as NSDictionary, nil)
           if status == errSecSuccess {
               return true
           } else if status == errSecItemNotFound {
               return false
           } else {
               throw Errors.keychainError
           }
       }
    
   /// Adds an item to the keychain.
   @MainActor
   func add(value: Data, account: String) async throws {
        var result: AnyObject?
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
         // Allow background access:
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: value,
            ] as NSDictionary, &result)
      if status == errSecSuccess {
         //self.haveUser = true
         debugPrint(result.debugDescription)
         
         try await get(account: "username")
         
      } else if status == errSecItemNotFound {
         self.haveUser = false
         self.user = nil
      } else {
          throw Errors.keychainError
      }
    }
    
   /// Updates a keychain item.
   @MainActor
    func update(value: Data, account: String) async throws {
       //var result: AnyObject?
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            ] as NSDictionary, [
            kSecValueData: value,
            ] as NSDictionary)
       if status == errSecSuccess {
          self.haveUser = true
          try await self.get(account: account)
       } else if status == errSecItemNotFound {
          self.haveUser = false
          self.user = nil
       } else {
           throw Errors.keychainError
       }
    }
    
    /// Stores a keychain item.
   @MainActor
    func set(value: Data, account: String) async throws {
        
       if try await existsUser(account: account) {
          try await update(value: value, account: account)
        } else {
           try await add(value: value, account: account)
        }
    }
    
    // If not present, returns nil. Only throws on error.
   
   @MainActor
    func get(account: String) async throws {
        var result: AnyObject?
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecReturnData: true,
            ] as NSDictionary, &result)
        if status == errSecSuccess {
           self.haveUser = true
           //if result != nil{
              let stringValue = String(decoding: (result as? Data)!, as: UTF8.self)
              self.user = stringValue//result as? Data
           //}
        } else if status == errSecItemNotFound {
           self.haveUser = false
           self.user = nil
        } else {
            throw Errors.keychainError
        }
    }
    
    /// Delete a single item.
   @MainActor
    func delete(account: String) async throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: service,
            ] as NSDictionary)
       if status == errSecSuccess {
          debugPrint("delete user errSecSuccess")
          self.haveUser = false
          self.user = nil
       } else if status == errSecItemNotFound {
          self.haveUser = false
          self.user = nil
       } else {
           throw Errors.keychainError
       }
    }
    
    /// Delete all items for my app. Useful on eg logout.
   @MainActor
    func deleteAll() async throws {
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            ] as NSDictionary)
       if status == errSecSuccess {
          self.haveUser = false
          debugPrint("delete user errSecSuccess")
          self.user = nil
       } else if status == errSecItemNotFound {
          self.haveUser = false
          self.user = nil
       } else {
           throw Errors.keychainError
       }
    }
    
    enum Errors: Error {
        case keychainError
    }
}

