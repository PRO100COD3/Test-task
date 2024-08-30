//
//  ToDoListViewController.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//
import UIKit

final class ToDoListViewController: UIViewController {
    
    let tableView = UITableView()
    private lazy var dataProvider = ToDoTaskStore(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if dataProvider.isContextEmpty(for: "Task") {
            dataProvider.loadTasksFromAPI()
        }
        setupNavBar()
        setupTableView()
    }
    
    private func setupTableView() {
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
}

// MARK: - UITableViewDelegate

extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}

// MARK: - UITableViewDataSource

extension ToDoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let record = dataProvider.object(at: indexPath) else { return UITableViewCell() }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ToDoListCell")
        cell.textLabel?.text = record.title
        cell.detailTextLabel?.text = record.details
        cell.backgroundColor = record.isCompleted ? UIColor.green : UIColor.white
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataProvider.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let record = dataProvider.object(at: indexPath) {
                dataProvider.delete(record: record)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editingController = EditingTaskViewController()
        editingController.dataProvider = self.dataProvider
        editingController.task = dataProvider.object(at: indexPath)
        navigationController?.pushViewController(editingController, animated: true)
        print("Cell clicked")
    }
}

// MARK: - DataProviderDelegate

extension ToDoListViewController: DataProviderDelegate {
    func didUpdate(_ update: ToDoTaskStoreUpdate) {
        tableView.performBatchUpdates({
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
            tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
        }, completion: nil)
    }
}

// MARK: - NewRecordViewControllerDelegate

extension ToDoListViewController: NewRecordViewControllerDelegate {
    func add(title: String, details: String) {
        dataProvider.add(title: title, details: details)
        dismiss(animated: true)
    }
}
