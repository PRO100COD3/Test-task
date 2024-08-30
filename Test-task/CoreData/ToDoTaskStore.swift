//
//  ToDoTaskStore.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit
import CoreData

// MARK: - DataProviderDelegate

struct ToDoTaskStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: ToDoTaskStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Task?
    func add(title: String, details: String)
    func delete(record: NSManagedObject)
}
// MARK: - Todo Models

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TodoList: Codable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - ToDoTaskStore

final class ToDoTaskStore: NSObject, NewRecordViewControllerDelegate {
    
    weak var delegate: DataProviderDelegate?
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: DataProviderDelegate) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.delegate = delegate
        self.context = context
    }
    
    func loadTasksFromAPI() {
        fetchTodos { todos in
            for todo in todos {
                let newTask = Task(context: self.context)
                newTask.title = todo.todo
                newTask.creationDate = Date()
                newTask.isCompleted = todo.completed
            }
            
            self.saveContext()
        }
    }
    
    func isContextEmpty(for entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 1  
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Ошибка при проверке данных в контексте: \(error)")
            return true
        }
    }
    
    private func fetchTodos(completion: @escaping ([Todo]) -> Void) {
        let url = URL(string: "https://dummyjson.com/todos")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let todosResponse = try JSONDecoder().decode(TodoList.self, from: data)
                    DispatchQueue.main.async {
                        completion(todosResponse.todos)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

extension ToDoTaskStore: DataProviderProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func add(title: String, details: String) {
        let newTask = Task(context: context)
        newTask.title = title
        newTask.details = details
        newTask.creationDate = Date()
        newTask.isCompleted = false
        saveContext()
    }
    
    func delete(record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Task? {
        fetchedResultsController.object(at: indexPath)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ToDoTaskStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("началось обновление")
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("обновление закончилось")
        
        guard let insertedIndexes = insertedIndexes,
              let deletedIndexes = deletedIndexes,
              let updatedIndexes = updatedIndexes else {
            return
        }
        
        delegate?.didUpdate(ToDoTaskStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes))
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.item)
                }
            case .insert:
                if let indexPath = newIndexPath {
                    insertedIndexes?.insert(indexPath.item)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.item)
                }
            default:
                break
        }
    }
}
