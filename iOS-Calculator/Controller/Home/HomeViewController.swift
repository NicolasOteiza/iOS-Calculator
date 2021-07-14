//
//  HomeViewController.swift
//  iOS-Calculator
//
//  Created by Nicolás Enrique Oteíza Vásquez on 02-07-21.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Outlets
    // result
    @IBOutlet weak var resultLabel: UILabel!
    // nuembers
    @IBOutlet weak var number0: UIButton!
    @IBOutlet weak var number1: UIButton!
    @IBOutlet weak var number2: UIButton!
    @IBOutlet weak var number3: UIButton!
    @IBOutlet weak var number4: UIButton!
    @IBOutlet weak var number5: UIButton!
    @IBOutlet weak var number6: UIButton!
    @IBOutlet weak var number7: UIButton!
    @IBOutlet weak var number8: UIButton!
    @IBOutlet weak var number9: UIButton!
    @IBOutlet weak var numberDecimal: UIButton!
    // operators
    @IBOutlet weak var operatorAC: UIButton!
    @IBOutlet weak var operatorPlusMinus: UIButton!
    @IBOutlet weak var operatorPorcent: UIButton!
    @IBOutlet weak var operatorDivision: UIButton!
    @IBOutlet weak var operatorMultiplication: UIButton!
    @IBOutlet weak var operatorSubstraction: UIButton!
    @IBOutlet weak var operatorAddition: UIButton!
    @IBOutlet weak var operatorResult: UIButton!
    
    // MARK: - Variables
    private var total:Double = 0                  // Total
    private var temp:Double = 0                   // Valor temporal
    private var operating = false                 // Indica si se ha seleccion un operador
    private var decimal = false                   // Indica si el valor es decimal
    private var operation: OperationType = .none  // Operación actual
    
    // MARK: - Constantes
    private let kDesimalSeparator = Locale.current.decimalSeparator!
    private let kMaxLength = 9
    private let kTotal = "total"
    
    
    private enum OperationType{
        case none, addition, substraction, multiplication, division, porcent
    }
    
    // Formateo de valor auxiliar
    private let auxFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Formateo de valor auxiliar cientifico
    private let auxTotalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.decimalSeparator = ""
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 100
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 100
        return formatter
    }()
    
    // Formateo de valor por pantalla por defecto
    private let printFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        let locale = Locale.current
        formatter.groupingSeparator = locale.groupingSeparator
        formatter.decimalSeparator = locale.decimalSeparator
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 9
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter
    }()
    
    // Formateo de valores por pantalla en formato cientifico
    private let printScientificFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 2
        formatter.exponentSymbol = "e"
        return formatter
    }()
        
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // identificar y colocar el separador decimal
        numberDecimal.setTitle(kDesimalSeparator, for: .normal)
        total = UserDefaults.standard.double(forKey: kTotal)
        result()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // redondeo de operadores
        operatorAC.round()
        operatorPlusMinus.round()
        operatorPorcent.round()
        operatorDivision.round()
        operatorMultiplication.round()
        operatorSubstraction.round()
        operatorAddition.round()
        operatorResult.round()
        // redondeo de numeros
        number0.round()
        number1.round()
        number2.round()
        number3.round()
        number4.round()
        number5.round()
        number6.round()
        number7.round()
        number8.round()
        number9.round()
        numberDecimal.round()
    }

    // MARK: - Button Actions
    @IBAction func operatorACAction(_ sender: UIButton) {
        clear()
        sender.shine()
    }
    
    @IBAction func operatorPlusMinusAction(_ sender: UIButton){
        temp = temp * (-1)
        resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
        sender.shine()
    }
    
    @IBAction func operatorPorcentAction(_ sender: UIButton){
        if operation != .porcent {
            result()
        }
        operating = true
        operation = .porcent
        result()
        sender.shine()
    }
    
    @IBAction func operatorDivisionAction(_ sender: UIButton){
        if operation != .none {
            result()
        }
        operating = true
        operation = .division
        sender.selectOperation(true)
        sender.shine()
    }
    
    @IBAction func operatorMultiplicationAction(_ sender: UIButton){
        if operation != .none {
            result()
        }
        operating = true
        operation = .multiplication
        sender.selectOperation(true)
        sender.shine()
    }
    
    @IBAction func operatorSubstractionAction(_ sender: UIButton){
        if operation != .none {
            result()
        }
        operating = true
        operation = .substraction
        sender.selectOperation(true)
        sender.shine()
    }
    
    @IBAction func operatorAdditionAction(_ sender: UIButton){
        if operation != .none {
            result()
        }
        operating = true
        operation = .addition
        sender.selectOperation(true)
        sender.shine()
    }
    
    @IBAction func operatorResultAction(_ sender: UIButton){
        result()
        sender.shine()
    }
    
    @IBAction func numberDecimalAction(_ sender: UIButton) {
        let currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
        resultLabel.text = resultLabel.text! + kDesimalSeparator
        decimal = true
        selectVisualOperation()
        sender.shine()
    }
    @IBAction func numberAction(_ sender: UIButton){
        operatorAC.setTitle("C", for: .normal)
        var currentTemp = auxTotalFormatter.string(from: NSNumber(value: temp))!
        if !operating && currentTemp.count >= kMaxLength {
            return
        }
        currentTemp = auxFormatter.string(from: NSNumber(value: temp))!
        // Hemos seleccionado una operación
        if operating {
            total = total == 0 ? temp: total
            resultLabel.text = ""
            currentTemp = ""
            operating = false
        }
        if decimal {
            currentTemp = "\(currentTemp)\(kDesimalSeparator)"
            decimal = false
        }
        let  number = sender.tag
        temp = Double(currentTemp + String(number))!
        resultLabel.text = printFormatter.string(from: NSNumber(value: temp))
        selectVisualOperation()
        print(number)
        sender.shine()
    }
    
    // Limpia los valores
    private func clear(){
        operation = .none
        operatorAC.setTitle("AC", for: .normal)
        if temp != 0 {
            temp = 0
            resultLabel.text = "0"
        }else{
            total = 0
            result()
        }
    }
    
    // Obtiene el resultado final
    private func result(){
        switch operation {
        case .none:
            // No hacemos nada
            break
        case .addition:
            total = total + temp
            break
        case .substraction:
            total = total - temp
            break
        case .multiplication:
            total = total * temp
            break
        case .division:
            total = total / temp
            break
        case .porcent:
            temp = temp / 100
            total = temp
            break
        }
         // formateo en pantalla
        if let currentTotal = auxTotalFormatter.string(from: NSNumber(value: total)), currentTotal.count > kMaxLength{
            resultLabel.text = printScientificFormatter.string(from: NSNumber(value: total))
        }else{
            resultLabel.text = printFormatter.string(from: NSNumber(value: total))
        }
        //operation = .none
        selectVisualOperation()
        UserDefaults.standard.set(total, forKey: kTotal)
        print("TOTAL: \(total)")
    }
    
    private func selectVisualOperation(){
        if !operating {
            //no estamos operando
            operatorAddition.selectOperation(false)
            operatorSubstraction.selectOperation(false)
            operatorDivision.selectOperation(false)
            operatorMultiplication.selectOperation(false)

        }else{
            switch operation {
            case .none,.porcent:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorDivision.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                break
            case .addition:
                operatorAddition.selectOperation(true)
                operatorSubstraction.selectOperation(false)
                operatorDivision.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                break
            case .substraction:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(true)
                operatorDivision.selectOperation(false)
                operatorMultiplication.selectOperation(false)
                break
            case .multiplication:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorDivision.selectOperation(false)
                operatorMultiplication.selectOperation(true)
                break
            case .division:
                operatorAddition.selectOperation(false)
                operatorSubstraction.selectOperation(false)
                operatorDivision.selectOperation(true)
                operatorMultiplication.selectOperation(false)
                break
            }
        }
    }
}
