//
//  View+Extension.swift
//  NguliController
//
//  Created by Ahdan Amanullah on 18/11/24.
//

import SwiftUI

enum Orientation: Int, CaseIterable {
    case landscapeLeft
    case landscapeRight
    
    var title: String {
        switch self {
        case .landscapeLeft:
            return "LandscapeLeft"
        case .landscapeRight:
            return "LandscapeRight"
        }
    }
    
    var mask: UIInterfaceOrientationMask {
        switch self {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        }
    }
}

extension View {
    @ViewBuilder
    func forceRotation(orientation: UIInterfaceOrientationMask) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.onAppear() {
                AppDelegate.orientationLock = orientation
            }
            // Reset orientation to previous setting
            let currentOrientation = AppDelegate.orientationLock
            self.onDisappear() {
                AppDelegate.orientationLock = currentOrientation
            }
        } else {
            self
        }
    }
}

enum FontWeight {
    case regular
    case medium
    case semiBold
    case bold
    case black
}

extension Font {
    static let balooBhaijaan: (FontWeight, CGFloat, TextStyle) -> Font = { fontType, size, textStyle in
        switch fontType {
        case .regular:
            Font.custom("BalooBhaijaan2-Regular", size: size, relativeTo: textStyle)
        case .medium:
            Font.custom("BalooBhaijaan2-Medium", size: size, relativeTo: textStyle)
        case .semiBold:
            Font.custom("BalooBhaijaan2-SemiBold", size: size, relativeTo: textStyle)
        case .bold:
            Font.custom("BalooBhaijaan2-Bold", size: size, relativeTo: textStyle)
        case .black:
            Font.custom("BalooBhaijaan2-ExtraBold", size: size, relativeTo: textStyle)
        }
    }
    
    static let tiny5: (FontWeight, CGFloat, TextStyle) -> Font = { fontType, size, textStyle in
        switch fontType {
        case .regular:
            Font.custom("Tiny5-Regular", size: size, relativeTo: textStyle)
        case .medium:
            Font.custom("Tiny5-Medium", size: size, relativeTo: textStyle)
        case .semiBold:
            Font.custom("Tiny5-SemiBold", size: size, relativeTo: textStyle)
        case .bold:
            Font.custom("Tiny5-Bold", size: size, relativeTo: textStyle)
        case .black:
            Font.custom("Tiny5-ExtraBold", size: size, relativeTo: textStyle)
        }
    }
}

extension Text {
    func balooBhaijaan(_ fontWeight: FontWeight? = nil, _ size: CGFloat? = nil, _ textStyle: Font? = nil) -> Text {
        return self.font(.balooBhaijaan(fontWeight ?? .regular, size ?? 16, .callout))
    }
    
    func tiny5(_ fontWeight: FontWeight? = nil, _ size: CGFloat? = nil, _ textStyle: Font? = nil) -> Text {
        return self.font(.tiny5(fontWeight ?? .regular, size ?? 16, .callout))
    }
    
    func whiteOutlined() -> some View {
        self.modifier(TextOutlinedModifier(color: .white))
    }
}

struct TextOutlinedModifier: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: 1, x: 1, y: 1)
            .shadow(color: color, radius: 1, x: -1, y: -1)
            .shadow(color: color, radius: 1, x: 1, y: -1)
            .shadow(color: color, radius: 1, x: -1, y: 1)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
        
    }
}
