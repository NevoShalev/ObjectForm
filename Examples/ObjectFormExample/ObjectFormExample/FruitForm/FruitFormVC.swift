//
//  FruitFormVC.swift
//  Mocha
//
//  Created by Jake on 2/12/20.
//  Copyright © 2020 Mocha. All rights reserved.
//

import ObjectForm
import UIKit

class FruitFormVC: UIViewController {

    private var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.rowHeight = UITableView.automaticDimension
        view.keyboardDismissMode = .onDrag
        return view
    }()

    private let dataSource: FruitFormData

    init(_ fruit: Fruit) {
        dataSource = FruitFormData(fruit)

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
    }

    @objc private func saveButtonTapped() {
        guard dataSource.validateData() else {
            tableView.reloadData()
            return
        }

        navigationController?.popViewController(animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implementef")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FruitFormVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = dataSource.row(at: indexPath)
        switch row {
        case let stringSelectRow as SelectRow<String>:
            stringSelectRow.cell.showPicker(in: self)
            
        case let textViewRow as TextViewRow:
            textViewRow.cell.showTextView(in: self)

        case let buttonRow as ButtonRow:
            showAlert(title: "Button tapped", message: "ActionTag: \(buttonRow.actionTag)")

        default:
            break
        }
    }

    private func showAlert(title: String, message: String?) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        self.present(alertView, animated: true)
    }

}

extension FruitFormVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.numberOfRows(at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = dataSource.row(at: indexPath)
        row.baseCell.setup(row)
        row.baseCell.delegate = self
        return row.baseCell
    }
}

extension FruitFormVC: FormCellDelegate {
    func cellDidChangeValue(_ cell: UITableViewCell, value: Any?) {
        let indexPath = tableView.indexPath(for: cell)!
        _ = dataSource.updateItem(at: indexPath, value: value)
    }
}
