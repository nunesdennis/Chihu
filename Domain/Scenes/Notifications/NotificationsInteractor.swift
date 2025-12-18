//
//  NotificationsInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//
import Foundation

protocol NotificationsBusinessLogic {
    func load(request: Notifications.Load.Request)
    func loadMore(request: Notifications.Load.Request)
}

final class NotificationsInteractor {
    typealias Request = Notifications.Load.Request
    typealias Response = Notifications.Load.Response
    var presenter: NotificationsPresentationLogic?
}

extension NotificationsInteractor: NotificationsBusinessLogic {
    func load(request: Request) {
        let worker = NotificationsNetworkingWorker()
        Task(priority: .background) {
            await worker.fetchNotifications(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
    
    func loadMore(request: Request) {
        let worker = NotificationsNetworkingWorker()
        Task(priority: .background) {
            await worker.fetchNotifications(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.presentMore(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
}
