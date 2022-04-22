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
            if let use = keychain.user {
               Text("\(use)")
            }
            HStack{
               HStack(){
                  Button(action: {
                     Task {
                        try await keychain.delete(account: "username")
                     }
                  }) {
                     HStack {Text("Delete User")}.padding(10.0)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(lineWidth: 2.0))
                  }.padding(.trailing,10)
               }
               Spacer()
               HStack(){
                  Button(action: {
                     Task {
                        try await keychain.deleteAll()
                     }
                  }) {
                     HStack {Text("Delete All")}.padding(10.0)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(lineWidth: 2.0))
                  }.padding(.trailing,10)
               }
            }.padding()
         }else{
            // MARK: Inserstion Sort
            HStack(alignment: .center, spacing: 8, content: {
               HStack(){
                  Button(action: {
                     Task {
                        try await keychain.exists(account: "username")
                        try await keychain.add(value: UUID().uuidString.data(using: .utf8)!, account: "username")
                     }
                  }) {
                     HStack {Text("Create User")}.padding(10.0)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(lineWidth: 2.0))
                  }.padding(.leading)
               }
               //Spacer()
               
            })
         }
         
      }.environmentObject(keychain)
         .onAppear{
            Task {
               try await keychain.exists(account: "username")
               
            }
            
         }
         .hideNavigationBar()
         .edgesIgnoringSafeArea(.all)
         .navigationViewStyle(StackNavigationViewStyle())
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}

extension View {
   func hideNavigationBar() -> some View {
      modifier(HideNavigationBarModifier())
   }
}
struct HideNavigationBarModifier: ViewModifier {
   func body(content: Content) -> some View {
      content
         .navigationBarBackButtonHidden(true)
         .navigationBarHidden(true)
         .navigationBarTitle("")
   }
}
