//
//  ViewController.swift
//  AlabsProject
//
//  Created by Yeldos Marat on 19.01.2022.
//

import UIKit
import AVKit


class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //for searching state
    var searchText = ""
    var searchPhotoItems = [PhotoModel]()
    var searchVideoItems = [VideoModel]()
    var searching = false
    
    //pagination var
    var photosPerPages = 10
    var limit = 10
    var paginationPhotoArray = [PhotoModel]()
    var paginationVideoArray = [VideoModel]()
    
    //data
    var photoArray = [PhotoModel]()
    var videoArray = [VideoModel]()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        setupSegmentedControl()
        collectionView.register(UINib(nibName: "CustomCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    func setupSegmentedControl() {
        activityIndicator.isHidden = true
        segmentedControl.addTarget(self, action: #selector(segmentControlValueIsChanged), for: .valueChanged)
    }
    
    @objc func segmentControlValueIsChanged() {
        searchBar.text = ""
        collectionView.reloadData()
    }
    
    //set paginatin photodata it`s for Infinity scroll
    func setPagination<T>(photosPerPages: Int, paginationArray: inout [T], searchItems: [T]) {
        if photosPerPages >= limit {
            return
        } else if photosPerPages >= limit - 10 {
            for i in photosPerPages..<limit {
                paginationArray.append(searchItems[i])
            }
            self.photosPerPages += 10
        } else {
            for i in photosPerPages..<self.photosPerPages + 10 {
                paginationArray.append(searchItems[i])
            }
            self.photosPerPages += 10
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


//MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text ?? " "
        if segmentedControl.selectedSegmentIndex == 0 {
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            fetchData(searchText: searchText)
        } else {
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            fetchData(searchText: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if segmentedControl.selectedSegmentIndex == 0 {
                self.paginationPhotoArray.removeAll()
                self.searchText = searchText
                fetchData(searchText: searchText)
                self.searchPhotoItems = self.photoArray.filter({$0.tags.lowercased().contains(searchText.lowercased())})
                collectionView.reloadData()
            } else {
                self.paginationVideoArray.removeAll()
                self.searchText = searchText
                fetchData(searchText: searchText)
                self.searchVideoItems = self.videoArray.filter({$0.tags.lowercased().contains(searchText.lowercased())})
                collectionView.reloadData()
            }
        collectionView.reloadData()
    }
    
    func fetchData(searchText: String) {
        if segmentedControl.selectedSegmentIndex == 0 {
            Service.share.fetchImageData(photoName: searchText) { res in
                switch res {
                case .success(let photos):
                    self.searchPhotoItems = photos
                    
                    self.limit = self.searchPhotoItems.count
                    for i in 0..<self.searchPhotoItems.count {
                        self.paginationPhotoArray.append(self.searchPhotoItems[i])
                    }

                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.collectionView.reloadData()
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        } else {
            Service.share.fetchVideoData(photoName: searchText) { res in
                switch res {
                case .success(let videos):
                    self.searchVideoItems = videos
                    
                    self.limit = self.searchVideoItems.count
                    for i in 0..<self.searchVideoItems.count {
                        self.paginationVideoArray.append(self.searchVideoItems[i])
                    }

                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.collectionView.reloadData()
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
}


//MARK: - CollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return paginationPhotoArray.count
        } else {
            return paginationVideoArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionCell else { return UICollectionViewCell() }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            Service.share.fetchImage(url: paginationPhotoArray[indexPath.item].previewURL,
                                                activityIndicator: cell.activityIndicator,
                                                completion: { image in
                cell.img.image = image
            })
            cell.label.text = paginationPhotoArray[indexPath.item].tags
            cell.playView.isHidden = true
        } else {
            let urlVideoPicture = Service.share.creatVideoPictureLink(photoID: paginationVideoArray[indexPath.item].pictureID)
            Service.share.fetchImage(url: urlVideoPicture,
                                                activityIndicator: cell.activityIndicator,
                                                completion: { image in
                cell.img.image = image
            })
            cell.label.text = paginationVideoArray[indexPath.item].tags
//            if !cell.activityIndicator.isAnimating {
                cell.playView.isHidden = false
//            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            if let viewController = storyboard?.instantiateViewController(identifier: "DetailPhotoViewController") as? DetailPhotoViewController {
                let photo = paginationPhotoArray[indexPath.item]
                self.present(viewController, animated: true)
                Service.share.fetchImage(url: photo.largeImageURL,
                                         activityIndicator: viewController.activIndicator) { img in
                    viewController.img.image = img
                }
                viewController.downloadLabel.text = "\(photo.downloads)"
                viewController.viewsLabel.text = "\(photo.views)"
                viewController.likesLabel.text = "\(photo.likes)"
                
            }
        } else {
            let video = paginationVideoArray[indexPath.item]
            guard let urlVideo = URL(string: (video.videos.medium?.url)!) else { return }
            let player = AVPlayer(url: urlVideo)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 30) / 2
        return CGSize(width: size, height: size)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == collectionView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >=
                (scrollView.contentSize.height) {
                if segmentedControl.selectedSegmentIndex == 0 {
                    fetchData(searchText: self.searchText)
                    setPagination(photosPerPages: photosPerPages,
                                  paginationArray: &paginationPhotoArray,
                                  searchItems: searchPhotoItems)
                } else {
                    fetchData(searchText: self.searchText)
                    setPagination(photosPerPages: photosPerPages,
                                  paginationArray: &paginationVideoArray,
                                  searchItems: searchVideoItems)
                }
            }
        }
    }
}



//MARK: - UICollectionFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //          let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
    //          let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
    //          let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
    //          return CGSize(width: size, height: size)
    //      }
}




//    func setPaginationPhoto(photosPerPages: Int) {
//        if photosPerPages >= limit {
//            return
//        } else if photosPerPages >= limit - 10 {
//            for i in photosPerPages..<limit {
//                paginationPhotoArray.append(searchPhotoItems[i])
//            }
//            self.photosPerPages += 10
//        } else {
//            for i in photosPerPages..<self.photosPerPages + 10 {
//                paginationPhotoArray.append(searchPhotoItems[i])
//            }
//            self.photosPerPages += 10
//        }
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//    }
//
//    func setPaginationVideo(photosPerPages: Int) {
//        if photosPerPages >= limit {
//            return
//        } else if photosPerPages >= limit - 10 {
//            for i in photosPerPages..<limit {
//                paginationVideoArray.append(searchVideoItems[i])
//            }
//            self.photosPerPages += 10
//        } else {
//            for i in photosPerPages..<self.photosPerPages + 10 {
//                paginationVideoArray.append(searchVideoItems[i])
//            }
//            self.photosPerPages += 10
//        }
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//    }
    
