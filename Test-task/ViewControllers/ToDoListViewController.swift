//
//  ToDoListViewController.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit


class ToDoListViewController: UIViewController {
    
    private let tableView = UITableView()
    var tasks: [Task] = []
    let taskStore = ToDoTaskStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTableView()
        
        fetchTasks()
        if tasks.isEmpty {
            loadTasksFromAPI()
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.topItem?.title = "To do list"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
    }
    
    func fetchTasks() {
        taskStore.fetchTasks()
        tasks = taskStore.tasks
        tableView.reloadData()
    }
    
    func loadTasksFromAPI() {
        taskStore.loadTasksFromAPI { [weak self] in
            self?.fetchTasks()
        }
    }
    
    private func showNewRecordViewController() {
        let viewControllerToPresent = NewRecordViewController()
        viewControllerToPresent.delegate = self
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    @objc
    private func didTapAddButton(_ sender: UIBarButtonItem) {
        showNewRecordViewController()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            taskStore.delete(record: tasks[indexPath.row])
            fetchTasks()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editTaskVC = EditingTaskViewController()
        editTaskVC.task = tasks[indexPath.row]
        editTaskVC.delegate = self
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
}


extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}


extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = tasks[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NotepadCell")
        cell.textLabel?.text = record.title
        cell.detailTextLabel?.text = record.details
        if (tasks[indexPath.row].isCompleted == true){
            cell.backgroundColor = UIColor.green
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
}

extension ToDoListViewController: NewRecordViewControllerDelegate {
    func add(title: String, details: String) {
        taskStore.add(title: title, details: details)
        fetchTasks()
        dismiss(animated: true)
    }
}

extension ToDoListViewController: DataProviderDelegate {
    func didUpdate(_ update: NotepadStoreUpdate) {
        tableView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
        }
    }
}
