//
//  ContentView.swift
//  NguliController
//
//  Created by Ahdan Amanullah on 09/11/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = MultipeerClientManager()
    @State private var code = ""

    var body: some View {
        VStack {
            if(!viewModel.isConnected){
                TextField("Enter Connection Code", text: $code)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            
            if !viewModel.isConnected {
                Button("Connect") {
                    viewModel.startConnect(code: code)
                    code = ""
                }
            } else {
                Button("Disconnect") {
                    viewModel.disconnect()
                }
            }
            
            if viewModel.isConnected {
                Text("Connected to Host!")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
