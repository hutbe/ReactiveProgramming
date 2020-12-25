//
//  ViewController.swift
//  ReactiveProgramming
//
//  Created by Hut on 2020/12/24.
//

import UIKit
import Combine

class GameViewController: UIViewController {
    // MARK: - Variables
    var gameStatus: GameStatus = .stop {
        didSet {
            switch gameStatus {
            case .play:
                startGame()
            case .stop:
                stopGame()
            }
        }
    }
    var gameImages: [UIImage] = []
//    var gameTimer: Timer?
    var gameTimer: AnyCancellable?
    var gameScore = 0
    var gameLevel = 0
    
    var subcriptions: Set<AnyCancellable> = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - IB Outlet
    @IBOutlet weak var scroeLabel: UILabel!
    @IBOutlet var gameImageViews: [UIImageView]!
    @IBOutlet var gameImageIndicators: [UIActivityIndicatorView]!
    @IBOutlet var gameImageButtons: [UIButton]!
    @IBOutlet weak var gamePlayButton: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    
    
    // MARK: - IB Action
    @IBAction func gamePlayButtonDidClick(_ sender: Any) {
        gameStatus = gameStatus == .play ? .stop : .play
    }
    
    @IBAction func imageDidClick(_ sender: UIButton) {
        let selectedImages = gameImages.filter{ $0 == gameImages[sender.tag] }
        if selectedImages.count == 1 {
            startGame()
        } else {
            gameStatus = .stop
        }
        
    }
    
    // MARK: - Private Methods
    private func startGame() {
        gameTimer?.cancel()
        gamePlayButton.setTitle("Stop", for: .normal)
        
        scroeLabel.text = "Score: \(gameScore)"
        resetImages()
        startImageLoaderIndictors()
        
        let firstImage = UnsplashAPI.randomImage()
            .flatMap { randomImageResponse in
                ImageDownloader.downloadImage(url: randomImageResponse.urls.regular)
        }
        
        let sencondImage = UnsplashAPI.randomImage().flatMap { randomImageResponse in
            ImageDownloader.downloadImage(url: randomImageResponse.urls.regular)
        }
        
        firstImage.zip(sencondImage)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print("Error: \(error)")
                    self.gameStatus = .stop
                }
            } receiveValue: { [unowned self] first, second in
                guard let firstImg = first, let secondImg = second else {
                    print("Can not get the images")
                    return
                }
                self.gameImages = [firstImg, secondImg, secondImg, secondImg].shuffled()
                updateUI()
            }
            .store(in: &subcriptions)

        
//        UnsplashAPI.randomImage { [unowned self] randomImageResponse in
//            guard let randomImageResponse = randomImageResponse else {
//                DispatchQueue.main.async {
//                    self.gameStatus = .stop
//                }
//                return
//            }
//
//            ImageDownloader.downloadImage(url: randomImageResponse.urls.regular) { [unowned self] image in
//                guard let image = image else {return}
//                self.gameImages.append(image)
//
//                UnsplashAPI.randomImage { [unowned self] randomImageResponse in
//                    guard let randomImageResponse = randomImageResponse else {
//                        DispatchQueue.main.async {
//                            self.gameStatus = .stop
//                        }
//                        return
//                    }
//
//                    ImageDownloader.downloadImage(url: randomImageResponse.urls.regular) { [unowned self] image in
//                        guard let image = image else {return}
//                        self.gameImages.append(contentsOf:[image, image, image])
//                        self.gameImages.shuffle()
//
//                        updateUI()
//                    }
//                }
//            }
//        }
    }
    
    private func stopGame() {
        subcriptions.forEach { subcription in
            subcription.cancel()
        }
//        subcriptions.forEach { $0.cancel() }
        
        gameTimer?.cancel()
        gamePlayButton.setTitle("Play", for: .normal)
        gameLevel = 0
        gameScore = 0
        scroeLabel.text = "Score:  \(gameScore)"
        
        stopImageLoaderIndictors()
        resetImages()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.scroeLabel.text = "Score: \(self.gameScore)"
            self.gameLevel += 1
            self.levelLabel.text = "Level: \(self.gameLevel)"
            self.gameTimer = Timer.publish(every: 0.1, on: RunLoop.main, in: .common)
                .autoconnect()
                .sink(receiveValue: { [unowned self] _ in
                    self.scroeLabel.text = "Score: \(self.gameScore)"
                    self.gameScore += 1
                    if self.gameScore > 100 {
                        self.gameScore = 100
                        self.gameTimer?.cancel()
                    }
                })
            
//            self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats:true) {[unowned self] timer in
//                DispatchQueue.main.async {
//                    self.scroeLabel.text = "Score: \(self.gameScore)"
//                }
//                self.gameScore += 1
//                if self.gameScore > 100 {
//                    self.gameScore = 100
//                    timer.invalidate()
//                }
//            }
            
            self.stopImageLoaderIndictors()
            self.setImages()
        }
    }
    
    // MARK: - UI functions
    private func setImages() {
        if gameImages.count == 4 {
            for (index, gameImage) in gameImages.enumerated() {
                gameImageViews[index].image = gameImage
            }
        }
    }
    
    private func resetImages() {
        subcriptions = []
        gameImages = []
        gameImageViews.forEach{ $0.image = nil }
    }
    
    private func stopImageLoaderIndictors() {
        gameImageIndicators.forEach{ $0.stopAnimating() }
    }
    
    private func startImageLoaderIndictors() {
        gameImageIndicators.forEach{ $0.startAnimating() }
    }
    
}

