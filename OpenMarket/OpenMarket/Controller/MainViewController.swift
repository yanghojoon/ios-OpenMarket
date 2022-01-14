import UIKit

class MainViewController: UIViewController {
    @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
    private let listViewStoryboardName = "ProductsTableView"
    private let gridViewStoryboardName = "ProductsCollectionView"
    private let listViewControllerIdentifier = "ListViewController"
    private let gridViewControllerIdentifier = "GridViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        loadViewController()
    }
    
    private func setupSegmentedControl() {
        viewSegmentedControl.selectedSegmentTintColor = .systemBlue
        viewSegmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        viewSegmentedControl.layer.borderWidth = 1.0
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemBlue],
            for: .normal
        )
    }
    
    private func loadViewController() {
        children.forEach { children in
            children.removeFromParent()
        }
        view.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
        if viewSegmentedControl.selectedSegmentIndex == 0 {
            let listViewStoryboard = UIStoryboard(name: listViewStoryboardName, bundle: nil)
            let listViewController = listViewStoryboard.instantiateViewController(
                withIdentifier: listViewControllerIdentifier
            )
            addChild(listViewController)
            view.addSubview(listViewController.view)
        } else if viewSegmentedControl.selectedSegmentIndex == 1 {
            let gridViewStoryboard = UIStoryboard(name: gridViewStoryboardName, bundle: nil)
            let gridViewController = gridViewStoryboard.instantiateViewController(
                withIdentifier: gridViewControllerIdentifier
            )
            addChild(gridViewController)
            view.addSubview(gridViewController.view)
        }
    }
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        loadViewController()
    }
}
