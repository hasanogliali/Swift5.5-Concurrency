//
//  ViewController.swift
//  TestProj
//
//  Created by Ali Hasanoğlu on 25.01.2022.
//

import UIKit

@MainActor
class UnstructuredTasksViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnDownload: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDownload.setTitle("Download", for: .normal)
    }
    
//    var downloadAndShowTask: Task<Void, Never>? {
    var downloadAndShowTask: Task<Image, Error>? {
        didSet {
            if downloadAndShowTask == nil {
                btnDownload.setTitle("Download", for: .normal)
            } else {
                btnDownload.setTitle("Cancel", for: .normal)
            }
        }
    }
    
    func beginDownloadImage() {
        let randomIndex = Int.random(in: 0...9)
        
        downloadAndShowTask = Task {
            let images = try await ContentProvider.default.fetch([Image].self, url: imageUrl)
            Task.detached(priority: .background) {
                // write to disk
            }
            return images[randomIndex]
        }
    }
    
    func downloadImages() async {
        beginDownloadImage()
        do {
            if let url = try await URL(string: downloadAndShowTask?.value.download_url ?? "") {
                imageView.image = try await ContentProvider.default.downloadImage(with: url)
            }
        } catch {
            print(error.localizedDescription)
        }
        downloadAndShowTask = nil
    }
    
    // 1
//    func downloadImages() async {
//        let randomIndex = Int.random(in: 0...9)
//        downloadAndShowTask = Task {
//            do {
//                let images = try await ContentProvider.default.fetch([Image].self, url: imageUrl)
//                let url = URL(string: images[randomIndex].download_url ?? "")!
//                let image = try await ContentProvider.default.downloadImage(with: url)
//                imageView.image = image
//            } catch {
//                print(error)
//            }
//            downloadAndShowTask = nil
//        }
//    }
    
    @IBAction func triggerButtonTouchUpInside(_ sender: Any) {
        if downloadAndShowTask == nil {
            Task {
                await downloadImages()
            }
        } else {
            cancelDownload()
        }
    }
    
    func cancelDownload() {
        downloadAndShowTask?.cancel()
        //TODO: neden cancel edilmedi.
    }
}
