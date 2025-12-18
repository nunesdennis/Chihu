//
//  NotificationsModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
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
