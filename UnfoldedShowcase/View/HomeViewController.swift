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

final class HomeViewController: UITableViewController {

  private static let showDeckSegueIdentifier = "ShowDeck"

  private static let deckglExampleSection = 0

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier ?? "" {

    case Self.showDeckSegueIdentifier:
      guard let deckViewController = segue.destination as? DeckViewController else {
        fatalError("Unexpected Destination: \(segue.destination)")
      }
      guard let deck = sender as? DeckWrapper else { fatalError("Deck data not provided") }

      deckViewController.deckWrapper = deck

    default:
      fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")

    }
  }

  // MARK: - UITableViewController overrides

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case Self.deckglExampleSection:
      performSegue(withIdentifier: Self.showDeckSegueIdentifier, sender: createDeck(for: indexPath.row))
    default:
      break
    }
  }

  // MARK: - Utility methods

  private func createDeck(for row: Int) -> DeckWrapper {
    switch row {
    case 0: return ManhattanPopulationDeck()
    case 1: return HeathrowFlightsDeck()
    case 2: return VancouverBlocksDeck()
    default: fatalError("Unknown deck index")
    }
  }

}
