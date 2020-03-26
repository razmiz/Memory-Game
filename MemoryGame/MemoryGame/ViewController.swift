//
//  ViewController.swift
//  MemoryGame
//
//  Created by Raz on 19/03/2020.
//  Copyright © 2020 Raz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highestScoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var emojiArray: [String] = ["🐶", "🐸", "🐣", "🐱", "🐠", "🦞", "🐝", "🐳", "🦄", "🐓"]
    var tagsArray: [Int] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
    var cardsTuple: (card1Tag: Int, card1Emoji: String, card2Tag: Int , card2Emoji: String) = (0, " ", 0, " ")
    var taps: Int = 0
    var currentScore: Int = 0
    var highestScore: Int = 0
    let preferences = UserDefaults.standard
    
    var timer:Timer?
    var timeLeft = 60
    
    var currentTag1: Int = -1
    var currentTag2: Int = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shuffleCards()
        configureButton()
        setScore()
        sethighestScore()
        startTimer()
    }
    
    @IBAction func cardButtonTapped(_ sender: UIButton) {
        let emoji = emojiArray[sender.tag]
        if sender.getTitle() != emoji {
            sender.setTitle(emoji)
            
            
            switch taps {
            case 0:
                cardsTuple.card1Tag = sender.tag
                cardsTuple.card1Emoji = emoji
                taps += 1
                currentTag1 = sender.tag
            case 1:
                view.isUserInteractionEnabled = false
                cardsTuple.card2Tag = sender.tag
                cardsTuple.card2Emoji = emoji
                currentTag2 = sender.tag
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.checkMatch()
                    self.cardsTuple = (0, " ", 0, " ")
                    self.checkEndOfGame()
                    self.view.isUserInteractionEnabled = true
                }
                fallthrough
            default:
                taps = 0
                
            }
        }else {
            resetShape(button: sender)
        }
    }
    
    func checkMatch(){
        if !checkCardsEmoji() {
            clearCards()
            animateMismatchCards(cardsToAnimate: [cardButtons[currentTag1],cardButtons[currentTag2]])
        } else {
            tagsArray[cardsTuple.card1Tag] = -1
            tagsArray[cardsTuple.card2Tag] = -1
            showToast(message: "YAY 😊!!!")
            animateMatchCards()
            currentScore += 5
            setScore()
        }
    }
    
    func checkCardsEmoji() -> Bool{
        guard cardsTuple.card2Emoji != " " && cardsTuple.card1Emoji != " " else { return false }
        return cardsTuple.card1Emoji == cardsTuple.card2Emoji
    }
    
    func clearCards(){
        for button in cardButtons{
            if tagsArray.contains(button.tag){
                button.setTitle(" ")
            }
        }
        currentScore -= 1
        setScore()
    }
    
    func shuffleCards(){
        emojiArray += emojiArray
        emojiArray.shuffle()
    }
    
    func configureButton(){
        var number = 0
        for button in cardButtons{
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            button.tag = tagsArray[number]
            number += 1
            resetShape(button: button)
        }
    }
    
    func checkEndOfGame(){
        if currentScore > highestScore{
            sethighestScore()
        }
        if tagsArray.sorted().last == -1{
            showAlert(title: "Well Done! 🙂", message: "play again?", exitCode: 0)
            timer!.invalidate()
            timer = nil
        }
        
    }
    
    func resetGame(){
        saveScore(scoreToSave: highestScore)
        tagsArray = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
        emojiArray = ["🐶", "🐸", "🐣", "🐱", "🐠", "🦞", "🐝", "🐳", "🦄", "🐓"]
        clearCards()
        currentScore = 0
        timeLeft = 60
        taps = 0
        animateMismatchCards(cardsToAnimate: cardButtons)
        viewDidLoad()
    }
    
    func setScore(){
        if currentScore < 0 {
            currentScore = 0
        }
        scoreLabel.text = "Score: \(currentScore) "
    }
    
    func sethighestScore(){
        highestScore = getSavedScore
        if currentScore > highestScore{
            highestScore = currentScore
        }
        highestScoreLabel.text = "Highest Score: \(highestScore)"
    }
    
    
    func saveScore(scoreToSave: Int){
        preferences.set(scoreToSave, forKey: UserDefaultCodingKeys.currentScore.rawValue)
        preferences.synchronize()
    }
    
    var getSavedScore: Int {
        return preferences.integer(forKey: UserDefaultCodingKeys.currentScore.rawValue)
    }
    
    func showAlert(title: String, message: String, exitCode: Int){
        let alertConroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            self.resetGame()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            UIAlertAction in
            if exitCode == 0{
                exit(0)
            } else{
                self.dismiss(animated: true, completion: nil)
                self.continueGame()
            }
        })
        alertConroller.addAction(okButton)
        alertConroller.addAction(cancelButton)
        
        self.present(alertConroller, animated: true, completion: nil)
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        timerLabel.text = "Timer: 01:00"
    }
    
    @objc func onTimerFires(){
        timeLeft -= 1
        
        if timeLeft < 60 && timeLeft >= 10 {
            timerLabel.text = "Timer: 00:\(timeLeft)"
        }
        if timeLeft < 10 {
            timerLabel.text = "Timer: 00:0\(timeLeft)"
        }
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            showAlert(title: "Times Up!", message: "Try again?", exitCode: 0)
        }
    }
    
    func animateMatchCards (){
        UIView.animate(withDuration: 0.3, animations: {
            self.cardButtons[self.currentTag1].transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.cardButtons[self.currentTag2].transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in UIView.animate(withDuration: 0.3){
            self.cardButtons[self.currentTag1].transform = CGAffineTransform.identity
            self.cardButtons[self.currentTag2].transform = CGAffineTransform.identity
            }
        })
    }
    
    func resetShape (button: UIButton){
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in UIView.animate(withDuration: 0.1){
            button.transform = CGAffineTransform.identity
            }
        })
    }
    
    
    func animateMismatchCards(cardsToAnimate: [UIButton]){
        cardsToAnimate.forEach {
            UIView.transition(with: cardButtons[$0.tag],
                              duration: 0.4,
                              options: [.transitionFlipFromLeft ],
                              animations: nil,
                              completion: nil)
        }
    }
    
    @IBAction func resetGameButton(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        showAlert(title: "Reset Game", message: "Are You Sure?", exitCode: -1)
    }
    
    func continueGame(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
}


extension ViewController{
    enum UserDefaultCodingKeys: String {
        case currentScore
    }
}


extension UIButton{
    func setTitle(_ title: String){
        self.setTitle(title, for: .normal)
    }
    
    func getTitle() -> String? {
        return self.title(for: .normal)
    }
}



extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.01, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

