//
//  RootViewManager.swift
//  Dine
//
//  Created by doss-zstch1212 on 18/06/24.
//

import UIKit
import Toast

struct RootViewManager {
    static func didSignInSuccessfully() {
        // Create the new root view controller
        let mainAppController = TabBarHostingController()
        
        // Optionally add a transition animation
        let window = UIApplication.shared.windows.first
        let options: UIView.AnimationOptions = .curveEaseIn
        let duration: TimeInterval = 0.5
        
        
        // Ensure the window is key and visible
        window?.makeKeyAndVisible()
        
        // Update the root view controller with animation
        UIView.transition(with: window!,
                          duration: duration,
                          options: options,
                          animations: {
            window?.rootViewController = mainAppController
        },
                          completion: nil)
        
        
        // Set isUserLoggedIn -> true
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        let toast = Toast.default(image: UIImage(systemName: "person.fill.checkmark")!, title: "Logged In")
        toast.show(haptic: .success)
    }
    
    static func didLoggedOutSuccessfully() {
        // Create the new root view controller
        let loginViewController = LoginViewController()
        
        // Optionally add a transition animation
        let window = UIApplication.shared.windows.first
        let options: UIView.AnimationOptions = .curveEaseOut
        let duration: TimeInterval = 0.5
        
        // Ensure the window is key and visible
        window?.makeKeyAndVisible()
        
        // Update the root view controller with animation
        UIView.transition(with: window!,
                          duration: duration,
                          options: options,
                          animations: {
            window?.rootViewController = loginViewController
        },
                          completion: nil)
        // Set isUserLoggedIn -> false
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        let toast = Toast.default(image: UIImage(systemName: "checkmark")!, title: "Logged out")
        toast.show(haptic: .success)
    }
}