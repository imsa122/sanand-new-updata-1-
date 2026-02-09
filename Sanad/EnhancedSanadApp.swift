//
//  EnhancedSanadApp.swift
//  Sanad
//
//  Enhanced main app entry point
//

import SwiftUI

@main
struct EnhancedSanadApp: App {
    
    init() {
        // إعداد المظهر العام - Setup Global Appearance
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            EnhancedMainView()
                .onAppear {
                    requestPermissions()
                }
        }
    }
    
    // MARK: - Setup Appearance
    
    private func setupAppearance() {
        // تخصيص مظهر التطبيق
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
    }
    
    // MARK: - Request Permissions
    
    private func requestPermissions() {
        // طلب إذن الموقع
        LocationManager.shared.requestPermission()
        
        // طلب إذن الإشعارات
        EnhancedReminderManager.requestPermission { granted in
            if granted {
                print("✅ تم منح إذن الإشعارات")
            } else {
                print("❌ تم رفض إذن الإشعارات")
            }
        }
        
        // طلب إذن التعرف على الصوت
        EnhancedVoiceManager.shared.requestPermission { granted in
            if granted {
                print("✅ تم منح إذن التعرف على الصوت")
            } else {
                print("❌ تم رفض إذن التعرف على الصوت")
            }
        }
    }
}
