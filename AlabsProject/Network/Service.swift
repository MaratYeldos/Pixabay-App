//
//  ApiService.swift
//  AlabsProject
//
//  Created by Yeldos Marat on 19.01.2022.
//

import UIKit

class Service {
    
    static let share = Service()
    
    private let apiKey = "=25318104-9f52dc0cb31e62d06b78d8875"
    private let query = "&q="
    private let imageType = "&image_type=photo"
    private let photoAPI = "https://pixabay.com/api/?key"
    private let videoAPI = "https://pixabay.com/api/videos/?key"
    
    //imageCache
    var imageCache = NSCache<NSString, UIImage>()
    
    //MARK: - Image Data
    func fetchImageData(photoName: String, completion: @escaping(Result<[PhotoModel], Error>) -> ()) {
        
        let urlString = photoAPI + apiKey + query + photoName + imageType
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            if let err = err {
                completion(.failure(err))
                return
            }
            
            do {
                let photos = try JSONDecoder().decode(ImageHit.self, from: data!)
                completion(.success(photos.hits))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
        
    }
    
    //MARK: - Video Data
    func fetchVideoData(photoName: String, completion: @escaping(Result<[VideoModel], Error>) -> ())  {
        
        let urlString = videoAPI + apiKey + query + photoName
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            if let err = err {
                completion(.failure(err))
                return
            }
            
            do {
                let videos = try JSONDecoder().decode(VideoHit.self, from: data!)
                completion(.success(videos.hits))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
    
    //MARK: - create url for video img
    func creatVideoPictureLink(photoID: String) -> String {
        let imagesSite = "https://i.vimeocdn.com/video/"
        let imageDataType = ".jpg"
        return imagesSite + photoID + imageDataType
    }
    
    
    //MARK: - fetch image
    func fetchImage(url: String, activityIndicator: UIActivityIndicatorView, completion: @escaping (UIImage) -> Void) {
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        guard let url = URL(string: url) ?? URL(string: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fanwarpro18.blogspot.com%2F2017%2F12%2F32-not-found-icon.html&psig=AOvVaw0KOjW3P7fXEaCj9NDSbhgy&ust=1642773851743000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCOCSg9i_wPUCFQAAAAAdAAAAABAE") else { return }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                completion(cachedImage)
                activityIndicator.stopAnimating()
        } else {
            
            let request = URLRequest(url: url,
                                     cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10)
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil,
                      data != nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let self = self else {
                          DispatchQueue.main.async {
                              activityIndicator.stopAnimating()
                          }
                          return
                      }
                
                guard let image = UIImage(data: data!) else { return }
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    completion(image)
                }
            }
            dataTask.resume()
        }
    }
}
