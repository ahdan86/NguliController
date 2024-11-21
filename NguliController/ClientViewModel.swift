//
//  ClientViewModel.swift
//  NguliController
//
//  Created by Ahdan Amanullah on 11/11/24.
//

import SwiftUI
import MultipeerConnectivity
import AVFoundation
import GameController
import os

struct GamepadInput: Codable {
    var leftThumbstickX: Float
    var leftThumbstickY: Float
    var buttonAPressed: Bool
    var buttonBPressed: Bool
    var buttonYPressed: Bool
}

class MultipeerClientManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    static let shared = MultipeerClientManager()
    
    @Published var isConnected = false
    @Published var enteredCode: String = ""
    
    private var session: MCSession!
    private var peerID: MCPeerID!
    private var browser: MCNearbyServiceBrowser!
    private var virtualController: GCVirtualController?
    
    override init() {
        super.init()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    // MARK: - Connection Methods
    
    func startConnect(code: String) {
        startBrowsing(code: code)
    }
    
    func disconnect() {
        session.disconnect()
        deactivateVirtualController()
        enteredCode = ""
    }
    
    func startBrowsing(code: String) {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "game-controller")
        browser.delegate = self
        browser.startBrowsingForPeers()
        enteredCode = code
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }
    
    // MARK: - GCVirtualController Setup
    
    func setupVirtualController() {
        let configuration = GCVirtualController.Configuration()
        configuration.elements = [GCInputLeftThumbstick, GCInputButtonA, GCInputButtonB, GCInputButtonY]
        
        virtualController = GCVirtualController(configuration: configuration)
        virtualController?.connect()
        
        virtualController?.controller?.extendedGamepad?.valueChangedHandler = { [weak self] gamepad, _ in
            self?.sendControllerInput(gamepad: gamepad)
        }
    }
    
    func deactivateVirtualController() {
        virtualController?.disconnect()
        virtualController = nil
    }
    
    private func sendControllerInput(gamepad: GCExtendedGamepad) {
        let inputState = GamepadInput(
            leftThumbstickX: gamepad.leftThumbstick.xAxis.value,
            leftThumbstickY: gamepad.leftThumbstick.yAxis.value,
            buttonAPressed: gamepad.buttonA.isPressed,
            buttonBPressed: gamepad.buttonB.isPressed,
            buttonYPressed: gamepad.buttonY.isPressed
        )
        
        if let data = try? JSONEncoder().encode(inputState) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                print("Sent data to host")
            } catch {
                print("Error sending data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if let discoveredCode = info?["code"], discoveredCode == enteredCode {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
    // MARK: - MCSessionDelegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
            print("Connection state changed: \(state.rawValue)")
            if state == .connected {
                self.setupVirtualController()
            } else {
                self.deactivateVirtualController()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data from \(peerID.displayName)")
    }
    
    // Unused MCSessionDelegate methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}


