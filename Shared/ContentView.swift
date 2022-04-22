//
//  ContentView.swift
//  Shared
//
//  Created by Borna Libertines on 21/04/22.
//

import SwiftUI

struct ContentView: View {
   
   @StateObject var keychain: Keychain = Keychain()
   
    var body: some View {
       VStack{
          if keychain.haveUser{
             if let use = keychain.user{
                Text("\(use)")
             }
          }
       }.environmentObject(keychain)
       .onAppear{
          Task {
              //When `purchasedIdentifiers` changes, get the latest subscription status.
             //if let use = keychain.user{
             try await keychain.exists(account: "username")
             try await keychain.get(account: "username")
             //}else{
                //try await keychain.get(account: "username")
             //}
          }
          
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
