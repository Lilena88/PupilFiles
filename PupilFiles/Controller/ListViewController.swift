//
//  ViewController.swift
//  PupilFiles
//
//  Created by Елена Ким on 11.05.2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    
    var studentsList = [Student]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var indexPathRow = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список учеников"
        tableView.register(UINib(nibName: "StudentCell", bundle: nil), forCellReuseIdentifier: "studentCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        let request : NSFetchRequest<Student> = Student.fetchRequest()
        do {
            studentsList = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToEdit", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! EditViewController
        let backItem = UIBarButtonItem()
            backItem.title = "Назад"
            navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "goToEditFromCell" {
            destinationVC.name = studentsList[indexPathRow].name!
            destinationVC.surname = studentsList[indexPathRow].surname!
            destinationVC.score = String(studentsList[indexPathRow].averageScore)
            destinationVC.new = false
            destinationVC.delegate = self
            destinationVC.title = "Изменить"
        } else {
            destinationVC.title = "Добавить"
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") as! StudentCell
        cell.nameLabel.text =  studentsList[indexPath.row].name
        cell.surnameLabel.text = studentsList[indexPath.row].surname
        cell.scoreLabel.text = String(studentsList[indexPath.row].averageScore)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathRow = indexPath.row
        performSegue(withIdentifier: "goToEditFromCell", sender: tableView)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(studentsList[indexPath.row])
            studentsList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension ListViewController: EditViewDelegate {
    func updateStudent(name: String, surname: String, score: Int64) {
        studentsList[indexPathRow].name = name
        studentsList[indexPathRow].surname = surname
        studentsList[indexPathRow].averageScore = score
    }
}
