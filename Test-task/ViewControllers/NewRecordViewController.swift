//
//  NewRecordViewController.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit


class ToDoTask {
    var title: String
    var details: String
    var isCompleted: Bool 
    var creationDate: Date
    
    
    init(title: String, details: String, isCompleted: Bool, creationDate: Date) {
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
        self.creationDate = creationDate
    }
}

protocol NewRecordViewControllerDelegate: AnyObject {
    func add(_ record: ToDoTask)
}

class NewRecordViewController: UIViewController {
    weak var delegate: NewRecordViewControllerDelegate?
}
