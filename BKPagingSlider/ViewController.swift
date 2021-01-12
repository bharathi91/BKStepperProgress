
import UIKit

class ViewController: UIViewController {
    @IBOutlet var steperView: BKPagingSlider!
    @IBOutlet var steperView2: BKPagingSlider!
    @IBOutlet var steperView3: BKPagingSlider!
    @IBOutlet var steperView4: BKPagingSlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BK Stepper Slider"
        steperView.sliderDelegate = self
        steperView2.sliderDelegate = self
        steperView3.sliderDelegate = self
        steperView4.sliderDelegate = self
        steperView.titleArray = ["Initial Info","Personal Details","Expenses","Documents"]
        steperView.layoutSubviews()
        
        // Do any additional setup after loading the view.
    }

}
extension ViewController: BKPagingSliderDelegate {
    func canChangeSliderPosition(to index: Int, stepper: BKPagingSlider) -> Bool {
        return true
    }
    
}
