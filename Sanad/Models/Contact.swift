//
//  Contact.swift
//  Sanad
//
//  Model for family contacts
//

import Foundation

/// نموذج جهة الاتصال - Contact Model
struct Contact: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String // مثل: ابن، ابنة، زوج، زوجة
    var isEmergencyContact: Bool
    var photoData: Data? // صورة الشخص
    
    init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        relationship: String,
        isEmergencyContact: Bool = false,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isEmergencyContact = isEmergencyContact
        self.photoData = photoData
    }
}

// MARK: - Sample Data for Preview
extension Contact {
    static let sampleContacts: [Contact] = [
        Contact(
            name: "أحمد محمد",
            phoneNumber: "+966501234567",
            relationship: "ابن",
            isEmergencyContact: true
        ),
        Contact(
            name: "فاطمة أحمد",
            phoneNumber: "+966507654321",
            relationship: "ابنة",
            isEmergencyContact: true
        ),
        Contact(
            name: "سارة علي",
            phoneNumber: "+966509876543",
            relationship: "زوجة",
            isEmergencyContact: false
        )
    ]
}
