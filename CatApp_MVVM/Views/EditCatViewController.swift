//
//  EditCatViewController.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import Bond

protocol EditCatViewModelProtocol: class {

    var image: Observable<UIImage?> { get }
    var isProcessing: Observable<Bool> { get }
    
    var numberOfFilterSamples: Int { get }

    var onUpdateFilterSample: ((_ index: Int) -> Void)? { get set }
    var onDismiss: (() -> Void)? { get set }
    var onShowMessage: ((_ title: String?, _ message: String?, _ completion: (() -> Void)?) -> Void)? { get set }

    func filterSample(at index: Int) -> UIImage
    func applyFilter(at index: Int)
    func save()
    func cancel()
    func createFilterSamples()

}

final class EditCatViewController: UIViewController {

    var viewModel: EditCatViewModelProtocol! {
        didSet {
            if isViewLoaded {
                setupBindings()
            }
        }
    }

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.createFilterSamples()
    }

    private func setupBindings() {
        _ = viewModel.image.bind(to: imageView.reactive.image)
        _ = viewModel.isProcessing.observeNext { [weak self] (isProcessing) in
            guard let strongSelf = self else { return }
            strongSelf.saveButton.isEnabled = !isProcessing
            if isProcessing {
                strongSelf.activityIndicatorView.startAnimating()
            } else {
                strongSelf.activityIndicatorView.stopAnimating()
            }
        }
        viewModel.onUpdateFilterSample = { [weak self] index in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
        viewModel.onDismiss = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        viewModel.onShowMessage = { [weak self] (title, message, completion) in
            self?.presentAlert(with: title, message: message, completion: completion)
        }
    }

    private func presentAlert(with title: String?, message: String?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction private func cancelAction(_ sender: UIButton) {
        viewModel.cancel()
    }

    @IBAction private func saveAction(_ sender: UIButton) {
        viewModel.save()
    }

}

extension EditCatViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFilterSamples
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: ImageFilterCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ImageFilterCollectionViewCell
        cell.image = viewModel.filterSample(at: indexPath.item)
        return cell
    }

}

extension EditCatViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.applyFilter(at: indexPath.item)
    }

}
