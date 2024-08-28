//
//  ToDoTaskStore.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit
import CoreData


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

public final class ToDoTaskStore: NSObject {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    public static let shared = ToDoTaskStore()
    var tasks: [Task] = []
    
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
