//
//  ToDoTaskStore.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit
import CoreData


struct ToDoTaskStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: ToDoTaskStoreUpdate)
}

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

final class ToDoTaskStore: NSObject, NewRecordViewControllerDelegate {
    
    weak var delegate: DataProviderDelegate?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    public static let shared = ToDoTaskStore()
    var tasks: [Task] = []
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    private override init() {}
    
    func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    func loadTasksFromAPI(completion: @escaping () -> Void) {
        fetchTodos { todos in
            for todo in todos {
                let newTask = Task(context: self.context)
                newTask.title = todo.todo
                newTask.creationDate = Date()
                newTask.isCompleted = todo.completed
            }
            
            self.saveContext()
            DispatchQueue.main.async {
                completion()
            }
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
    
    func saveContext() {
        if context.hasChanges{
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

extension ToDoTaskStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("началось обновление")
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("обновление закончилось")
        guard let insertedIndexes else { return }
        guard let deletedIndexes else { return }
        guard let updatedIndexes else { return }
        delegate?.didUpdate(ToDoTaskStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .delete:
                if let indexPath = indexPath {
                    print("Удаление")
                    
                    deletedIndexes?.insert(indexPath.item)
                }
            case .insert:
                if let indexPath = newIndexPath {
                    print("Вставка")
                    
                    insertedIndexes?.insert(indexPath.item)
                }
            case .update:
                if let indexPath = indexPath {
                    print("Обновление")
                    
                    updatedIndexes?.insert(indexPath.item)
                }
            default:
                break
        }
    }
}
