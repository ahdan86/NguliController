//
//  ContentView.swift
//  NguliController
//
//  Created by Ahdan Amanullah on 09/11/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MultipeerClientManager()
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var code = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.background)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()

                VStack(alignment: .center, spacing: 20) {
                    // Animated logo image
                    Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: viewModel.isConnected
                                ? geometry.size.width * 0.1
                                : geometry.size.width * 0.3
                        )
                        .animation(.easeInOut, value: viewModel.isConnected)

                    if !viewModel.isConnected {
                        // Connection setup UI
                        VStack(spacing: 20) {
                            TextField("Enter Controller Code", text: $code)
                                .font(.balooBhaijaan(.bold, 32, .callout))
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .frame(width: geometry.size.width * 0.7)
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(10)

                            if viewModel.isConnecting {
                                Text("Connecting...")
                                    .balooBhaijaan(.bold, 40)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 60)
                                    .background(Color(hex: "#FFBD05"))
                                    .cornerRadius(20)
                                    .opacity(code.isEmpty ? 0.5 : 1.0)
                            } else {
                                Button {
                                    if !code.isEmpty {
                                        withAnimation {
                                            viewModel.startConnect(code: code)
                                        }
                                        code = ""
                                    }
                                } label: {
                                    Text("PLAY")
                                        .balooBhaijaan(.bold, 40)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 100)
                                        .background(Color(hex: "#FFBD05"))
                                        .cornerRadius(20)
                                }
                                .disabled(code.isEmpty)
                                .opacity(code.isEmpty ? 0.5 : 1.0)
                            }
                        }
                    } else {
                        // Connected UI with animated button
                        Button {
                            withAnimation {
                                viewModel.disconnect()
                            }
                        } label: {
                            Text("Disconnect")
                                .balooBhaijaan(.bold, 16)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 8)
                                .background(Color(hex: "#FF2B05"))
                                .cornerRadius(10)
                        }
                        .transition(.opacity.combined(with: .scale))

                        Text("Connected to Host!")
                            .font(.title)
                            .padding()
                    }
                }
                .padding(.bottom, keyboardObserver.keyboardHeight)
                .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
            }
        }
    }
}

#Preview {
    ContentView()
}

