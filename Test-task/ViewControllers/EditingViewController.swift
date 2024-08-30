//
//  EditingViewController.swift
//  Test-task
//
//  Created by Вадим Дзюба on 29.08.2024.
//

import UIKit
import CoreData

final class EditingTaskViewController: UIViewController {
    
    var task: Task?
    var dataProvider: ToDoTaskStore?
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let bodyLabel = UILabel()
    private let textView = UITextView()
    private var saveButton: UIBarButtonItem!
    private let completeLabel = UILabel()
    private let completeSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        setupViews()
        populateFields()
        configureKeyboard()
    }
    
    private func setupViews() {
        titleLabel.text = "Заголовок"
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 24)
        ])
        
        view.addSubview(textField)
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        textField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.heightAnchor.constraint(equalToConstant: 32),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 24)
        ])
        
        bodyLabel.text = "Текст"
        view.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            bodyLabel.heightAnchor.constraint(equalToConstant: 32),
            bodyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bodyLabel.trailingAnchor, constant: 24)
        ])
        
        view.addSubview(textView)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 24),
            textView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        completeLabel.text = "Статус выполнения"
        view.addSubview(completeLabel)
        completeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 24),
            completeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
        ])
        
        view.addSubview(completeSwitch)
        completeSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeSwitch.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 24),
            completeSwitch.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])
    }
    
    private func configureKeyboard() {
        let toolbar = UIToolbar()
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(didTapSave))
        if (!textView.hasText) {
            saveButton.isEnabled = false
        }
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            saveButton
        ]
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func populateFields() {
        guard let task else { return }
        textField.text = task.title
        textView.text = task.details
        completeSwitch.isOn = task.isCompleted
    }
    
    @objc private func didTapSave() {
        guard let task else { return }
        task.title = textField.text ?? ""
        task.details = textView.text ?? ""
        task.isCompleted = completeSwitch.isOn
        dataProvider?.saveContext()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EditingTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
