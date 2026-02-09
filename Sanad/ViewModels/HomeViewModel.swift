//
//  HomeViewModel.swift
//  Sanad
//
//  ViewModel for home screen
//

import Foundation
import Combine
import SwiftUI

/// نموذج عرض الشاشة الرئيسية - Home View Model
class HomeViewModel: ObservableObject {
    
    @Published var emergencyContacts: [Contact] = []
    @Published var isEmergencyActive: Bool = false
    @Published var showEmergencyAlert: Bool = false
    @Published var showFallAlert: Bool = false
    @Published var settings: AppSettings = .default
    
    private let storageManager = StorageManager.shared
    private let locationManager = LocationManager.shared
    private let emergencyManager = EnhancedEmergencyManager.shared
    private let fallDetectionManager = FallDetectionManager.shared
    private let voiceManager = EnhancedVoiceManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupObservers()
        setupServices()
    }
    
    // MARK: - Setup
    
    /// تحميل البيانات - Load Data
    private func loadData() {
        emergencyContacts = storageManager.getEmergencyContacts()
        settings = storageManager.loadSettings()
    }
    
    /// إعداد المراقبين - Setup Observers
    private func setupObservers() {
        // مراقبة حالة الطوارئ
        emergencyManager.$isEmergencyActive
            .assign(to: &$isEmergencyActive)
        
        // مراقبة كشف السقوط
        NotificationCenter.default.publisher(for: .fallDetected)
            .sink { [weak self] _ in
                self?.handleFallDetection()
            }
            .store(in: &cancellables)
        
        // مراقبة الأوامر الصوتية
        NotificationCenter.default.publisher(for: .voiceCommandReceived)
            .sink { [weak self] notification in
                if let command = notification.object as? VoiceCommand {
                    self?.handleVoiceCommand(command)
                }
            }
            .store(in: &cancellables)
    }
    
    /// إعداد الخدمات - Setup Services
    private func setupServices() {
        // طلب الأذونات
        locationManager.requestPermission()
        EnhancedReminderManager.requestPermission { _ in }
        
        // بدء خدمات الموقع
        locationManager.startUpdatingLocation()
        
        // بدء كشف السقوط إذا كان مفعلاً
        if settings.fallDetectionEnabled {
            fallDetectionManager.startMonitoring()
        }
        
        // إعداد السياج الجغرافي إذا كان محدداً
        if let homeLocation = settings.homeLocation {
            locationManager.setupGeofence(
                center: homeLocation.coordinate,
                radius: settings.geofenceRadius
            )
        }
        
        // جدولة تذكيرات الأدوية
        EnhancedReminderManager.shared.scheduleAllMedicationReminders()
    }
    
    // MARK: - Actions
    
    /// الاتصال بالعائلة - Call Family
    func callFamily() {
        guard let firstContact = emergencyContacts.first else {
            voiceManager.speak("لا توجد جهات اتصال محفوظة")
            return
        }
        
        makePhoneCall(to: firstContact)
    }
    
    /// إرسال الموقع - Send Location
    func sendLocation() {
        guard let locationText = locationManager.getLocationText() else {
            voiceManager.speak("لا يمكن الحصول على الموقع")
            return
        }
        
        // في التطبيق الحقيقي، سيتم إرسال الموقع عبر الرسائل
        print("📍 إرسال الموقع:")
        print(locationText)
        
        voiceManager.speak("تم إرسال موقعك للعائلة")
        
        // إرسال للجميع
        for contact in emergencyContacts {
            print("📱 إرسال إلى: \(contact.name) - \(contact.phoneNumber)")
        }
    }
    
    /// طلب المساعدة الطارئة - Request Emergency Help
    func requestEmergencyHelp() {
        showEmergencyAlert = true
        emergencyManager.startEmergencyCheck(timeout: settings.emergencyTimeout)
    }
    
    /// إلغاء الطوارئ - Cancel Emergency
    func cancelEmergency() {
        showEmergencyAlert = false
        emergencyManager.cancelEmergency()
    }
    
    /// تأكيد الطوارئ - Confirm Emergency
    func confirmEmergency() {
        showEmergencyAlert = false
        emergencyManager.activateEmergencyNow()
    }
    
    // MARK: - Fall Detection
    
    /// معالجة كشف السقوط - Handle Fall Detection
    private func handleFallDetection() {
        showFallAlert = true
        voiceManager.speak("هل أنت بخير؟")
    }
    
    /// الرد على تنبيه السقوط - Respond to Fall Alert
    func respondToFallAlert(isOkay: Bool) {
        showFallAlert = false
        
        if isOkay {
            emergencyManager.cancelEmergency()
            voiceManager.speak("الحمد لله على سلامتك")
        } else {
            emergencyManager.activateEmergencyNow()
        }
    }
    
    // MARK: - Voice Commands
    
    /// معالجة الأمر الصوتي - Handle Voice Command
    private func handleVoiceCommand(_ command: VoiceCommand) {
        switch command {
        case .callFamily, .callSon, .callDaughter:
            callFamily()
        case .sendLocation:
            sendLocation()
        case .emergency:
            requestEmergencyHelp()
        case .showMedications:
            // سيتم التعامل معه في الواجهة
            break
        }
    }
    
    /// بدء الاستماع للأوامر الصوتية - Start Listening for Voice Commands
    func startVoiceListening() {
        guard settings.voiceCommandsEnabled else {
            voiceManager.speak("الأوامر الصوتية غير مفعلة")
            return
        }
        
        do {
            try voiceManager.startListening()
        } catch {
            print("خطأ في بدء الاستماع: \(error.localizedDescription)")
            voiceManager.speak("عذراً، لا يمكن تفعيل الأوامر الصوتية")
        }
    }
    
    /// إيقاف الاستماع - Stop Listening
    func stopVoiceListening() {
        voiceManager.stopListening()
    }
    
    // MARK: - Phone Call
    
    /// إجراء مكالمة هاتفية - Make Phone Call
    private func makePhoneCall(to contact: Contact) {
        let phoneNumber = contact.phoneNumber.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            voiceManager.speak("جاري الاتصال بـ \(contact.name)")
        } else {
            voiceManager.speak("لا يمكن إجراء المكالمة")
        }
    }
}
