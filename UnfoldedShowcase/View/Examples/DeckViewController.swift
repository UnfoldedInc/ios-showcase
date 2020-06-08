// Copyright (c) 2020 Unfolded Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

final class DeckViewController: UIViewController {

  var deckWrapper: DeckWrapper!

  // MARK: - Outlets

  @IBOutlet private var mtkView: MTKView! {
    didSet {
      // We want to control the animation loop manually
      mtkView.isPaused = true;
      mtkView.enableSetNeedsDisplay = false;
    }
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    deckWrapper.run(mtkView)
  }

  deinit {
    deckWrapper.stop()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    deckWrapper.setWidth(Int32(mtkView.bounds.width), height: Int32(mtkView.bounds.height))
  }

  // MARK: - User Actions

  @IBAction private func onCloseTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

}
