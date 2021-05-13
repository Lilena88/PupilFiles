//
//  EditViewController.swift
//  PupilFiles
//
//  Created by Елена Ким on 11.05.2021.
//

import UIKit
import CoreData

protocol EditViewDelegate {
    func updateStudent(name: String, surname: String, score: Int64)
}

class EditViewController: UIViewController {
    var name = ""
    var surname = ""
    var score = ""
    var new: Bool = true
    var delegate: EditViewDelegate?
    let messageLanguage = "В полях Имя и Фамилия должны содержаться только русские или английские символы без пробелов"
    let messageScore = "Средний балл может быть от 1 до 5"
    let messageEmptyFields = "Заполните пустые поля"

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var scoreTextField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        surnameTextField.delegate = self
        scoreTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nameTextField.text = name
        surnameTextField.text = surname
        scoreTextField.text = score
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if nameTextField.text?.isEmpty == true || surnameTextField.text?.isEmpty == true || scoreTextField.text?.isEmpty == true {
            alertMessage(message: messageEmptyFields)
            return
        } else if checkScore() == false || checkLanguage(textField: nameTextField) == false || checkLanguage(textField: surnameTextField) == false {
            return
        } else if new {
            let student = Student(context: context)
            student.name = nameTextField.text!
            student.surname = surnameTextField.text!
            student.averageScore = Int64(scoreTextField.text!)!
            saveData()
        } else {
            delegate?.updateStudent(name: nameTextField.text!, surname: surnameTextField.text!, score: Int64(scoreTextField.text!)!)
            saveData()
        }
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error of saving item \(error)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func checkLanguage(textField: UITextField) -> Bool {
        if textField.text!.isLatin == true || textField.text!.isCyrillic == true && !textField.text!.contains(" ") {
            return true
        } else {
            alertMessage(message: messageLanguage)
            textField.backgroundColor = .red .withAlphaComponent(0.1)
        }
        return false
    }
    
    func checkScore() -> Bool {
        if scoreTextField.text?.isEmpty == true {
            scoreTextField.backgroundColor = .red .withAlphaComponent(0.1)
            return false
        } else if Int(scoreTextField.text!)! > 5 || Int(scoreTextField.text!)! == 0 {
            alertMessage(message: messageScore)
            scoreTextField.backgroundColor = .red .withAlphaComponent(0.1)
            return false
        }
        return true
    }
    
    func alertMessage(message: String) {
        let alert = UIAlertController(title: "Внимание!", message: message , preferredStyle: .alert)
        let action = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.backgroundColor = .none
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.last == " " {
            textField.text?.removeLast()
        }
    }
}

extension String {
    var isLatin: Bool {
        let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lower = "abcdefghijklmnopqrstuvwxyz"
        
        for c in self.map({ String($0) }) {
            if !upper.contains(c) && !lower.contains(c) {
                return false
            }
        }
        return true
    }

    var isCyrillic: Bool {
        let upper = "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЮЯ"
        let lower = "абвгдежзийклмнопрстуфхцчшщьюя"

        for c in self.map({ String($0) }) {
            if !upper.contains(c) && !lower.contains(c) {
                return false
            }
        }
        return true
    }

    var isBothLatinAndCyrillic: Bool {
        return self.isLatin && self.isCyrillic
    }
}
