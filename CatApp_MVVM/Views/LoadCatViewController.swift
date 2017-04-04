//
//  LoadViewController.swift
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

protocol LoadCatViewModelProtocol {

    var isLoading: Observable<Bool> { get }
    var isEditable: Observable<Bool> { get }
    var title: Observable<String?> { get }
    var imageData: Observable<Data?> { get }

    var editCatViewModel: EditCatViewModelProtocol? { get }

    func loadNextCat()
    func cancelCurrentDownloading()

}

final class LoadCatViewController: UIViewController {

    var viewModel: LoadCatViewModelProtocol! {
        didSet {
            if isViewLoaded {
                setupBindings()
            }
        }
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var loadButton: UIBarButtonItem!
    @IBOutlet private var editButton: UIBarButtonItem!
    @IBOutlet private var cancelButton: UIBarButtonItem!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editCatViewController = segue.destination as? EditCatViewController {
            editCatViewController.viewModel = viewModel.editCatViewModel
        }
    }

    private func setupBindings() {
        _ = viewModel.isLoading.observeNext { [weak self] (value) in
            if value {
                self?.activityIndicatorView.startAnimating()
            } else {
                self?.activityIndicatorView.stopAnimating()
            }
            self?.loadButton.isEnabled = !value
            self?.cancelButton.isEnabled = value
        }
        _ = viewModel.title.bind(to: titleLabel.reactive.text)
        _ = viewModel.imageData.observeNext { [weak self] (data) in
            if let data = data {
                self?.imageView.image = UIImage(data: data)
            } else {
                self?.imageView.image = nil
            }
        }
        _ = viewModel.isEditable.bind(to: editButton.reactive.isEnabled)
    }

    @IBAction private func loadAcion(_ sender: UIBarButtonItem) {
        viewModel.loadNextCat()
    }
    
    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        viewModel.cancelCurrentDownloading()
    }

}
