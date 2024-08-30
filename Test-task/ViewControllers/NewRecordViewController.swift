//
//  NewRecordViewController.swift
//  Test-task
//
//  Created by Вадим Дзюба on 27.08.2024.
//

import UIKit


protocol NewRecordViewControllerDelegate: AnyObject {
    func add(title: String, details: String)
}

class NewRecordViewController: UIViewController, UITextViewDelegate {
    
    weak var delegate: NewRecordViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let textField = UITextField()
    private let textView = UITextView()
    private var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureKeyboard()
        setupTitleLabel()
        setupTextField()
        setupBodyLabel()
        setupTextView()
    }
    
    private func configureKeyboard() {
        let toolbar = UIToolbar()
        doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(didTapDone))
        doneButton.isEnabled = false
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
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
    
    private func setupTitleLabel() {
        titleLabel.text = "Заголовок"
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 24)
        ])
    }

    private func setupBodyLabel() {
        bodyLabel.text = "Текст"
        view.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            bodyLabel.heightAnchor.constraint(equalToConstant: 32),
            bodyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bodyLabel.trailingAnchor, constant: 24)
        ])
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        textField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 4
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.heightAnchor.constraint(equalToConstant: 32),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 24)
        ])
    }
    
    private func setupTextView() {
        view.addSubview(textView)
        textView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 24),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 24)
        ])
    }
    
    @objc private func didTapDone() {
        delegate?.add(title: textField.text ?? "", details: textView.text ?? "")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
