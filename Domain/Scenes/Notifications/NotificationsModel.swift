//
//  NotificationsModel.swift
//  Chihu
//
//  
//
import Foundation
import TootSDK
import SwiftUI

enum Notifications {
    enum Load {
        struct Request: NotificationsRequestProtocol {
            let pageInfo: PagedInfo?
        }
        
        struct Response {
            let notifications: [TootNotification]
        }
        
        struct ViewModel {
            let notifications: [TootNotification]
            
            init(response: Response) {
                self.notifications = response.notifications
            }
        }
    }
}
