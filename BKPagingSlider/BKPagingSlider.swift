
import UIKit
protocol BKPagingSliderDelegate {
    func canChangeSliderPosition(to index:Int,stepper:BKPagingSlider) -> Bool
}
@IBDesignable public class BKPagingSlider: UIView {
    
    @IBInspectable public var numberOfThumbs: Int = 2
    @IBInspectable public var thumbSize: Int = 10
    @IBInspectable public var thumbRadius: CGFloat = 5
    @IBInspectable public var barHeight: Int = 2
    @IBInspectable public var unFilledBarColor: UIColor = UIColor.gray
    @IBInspectable public var filledBarColor: UIColor = UIColor.green
    @IBInspectable public var unFilledThumbColor: UIColor = UIColor.gray
    @IBInspectable public var filledThumbColor: UIColor = UIColor.green
    @IBInspectable public var selectedImage: UIImage = UIImage(named:"selectedStepper")!
    @IBInspectable public var disabledImage: UIImage = UIImage(named:"disableStepper")!
    @IBInspectable public var completedImage: UIImage = UIImage(named:"completedStepper")!
    @IBInspectable public var shouldShowTitle: Bool = false
    @IBInspectable public var shouldShowImage: Bool = false
    @IBInspectable public var titleFont: UIFont = UIFont.systemFont(ofSize: 11.0)

    public var onSelect:  (_ value: Int) -> () = {_ in }
    //var presentingVC: HummApplicationFormViewController?
    private var viewWidth = 0
    private var viewHeight = 0
    private var distribution = 0
    private var bar = UIImageView()
    private var filledBar = UIImageView()
    private var thumbsCreated = false
    private var thumbs = [UIButton]()
    private var labels = [UILabel]()
    var sliderDelegate:BKPagingSliderDelegate?
    var titleArray: [String]? {
        didSet {
            self.layoutIfNeeded()
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.viewWidth = Int(self.frame.width)
        self.viewHeight = Int(self.frame.height)
        distribution = (self.viewWidth - thumbSize) / Int(numberOfThumbs - 1)
        createUnfilledBar()
        createFilledBar()
        createThumbs()
        bar.contentMode = .scaleAspectFit
        filledBar.contentMode = .scaleAspectFit
    }
    
    func createThumbs() {
        if thumbsCreated {
            return;
        }
        self.backgroundColor = UIColor.white
        switch numberOfThumbs {
        case 0:
            return;
        case 1:
            createButton(x: 0, tag: 0)
        case 2:
            for i in 0..<2 {
                createButton(x: i == 0 ? 0 : Int(self.viewWidth) - thumbSize, tag: i)
            }
        default:
            for i in 0..<numberOfThumbs {
                switch i {
                case 0:
                    createButton(x: 0, tag: i)
                case numberOfThumbs - 1:
                    createButton(x: Int(self.viewWidth) - thumbSize, tag: i)
                default:
                    createButton(x: distribution * i, tag: i)
                }
            }
        }
        adjustThumbsColor(tag: 0)
        thumbsCreated = true
    }
    
    func createUnfilledBar() {
        if (!self.subviews.contains(bar)) {
            bar.frame = CGRect(x: 15, y: (thumbSize / 2) - (barHeight / 2), width: Int(self.viewWidth - 30), height: barHeight)
            bar.backgroundColor = unFilledBarColor
            self.addSubview(bar)
        }
    }
    
    func createFilledBar() {
        if (!self.subviews.contains(filledBar)) {
            filledBar.frame = CGRect(x: 15, y: (thumbSize / 2) - (barHeight / 2), width: 0, height: barHeight)
            filledBar.backgroundColor = filledBarColor
            self.addSubview(filledBar)
        }
    }
    
    func resizeFilledBar(tag: Int) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                let filledBarNewWidth = self.distribution * tag
                self.filledBar.frame = CGRect(x: 15, y: (self.thumbSize / 2) - (self.barHeight / 2), width: filledBarNewWidth, height: self.barHeight)
            }
        }
    }
    
    func adjustThumbsColor(tag: Int) {
        if (self.thumbs.count > 0){
            for i in 0..<numberOfThumbs {
                if (i == tag) {
                    UIView.animate(withDuration: 0.25) {
                        self.thumbs[i].backgroundColor = self.filledThumbColor
                        if(self.shouldShowImage){
                            self.thumbs[i].setImage(self.selectedImage, for: .normal)
                        }
                        self.animateLogo(selectView:self.thumbs[i])
                        if(self.shouldShowTitle){
                            self.labels[i].textColor = self.selectedColor()
                        }
                    }
                }else if (i < tag) {
                    UIView.animate(withDuration: 0.25) {
                        self.thumbs[i].backgroundColor = self.unFilledThumbColor
                        if(self.shouldShowImage){
                            self.thumbs[i].setImage(self.completedImage, for: .normal)
                        }
                        if(self.shouldShowTitle){
                            self.labels[i].textColor = self.unSelectedColor()
                        }
                        
                    }
                }
                else {
                    UIView.animate(withDuration: 0.25) {
                        self.thumbs[i].backgroundColor = self.unFilledThumbColor
                        if(self.shouldShowImage){
                            self.thumbs[i].setImage(self.disabledImage, for: .normal)
                        }
                        if(self.shouldShowTitle){
                            self.labels[i].textColor = self.unSelectedColor()
                        }
                        
                    }
                }
            }
        }
    }
    func animateLogo(selectView:UIButton){
         selectView.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3 / 1.5, animations: {
            selectView.transform =
                CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { finished in
            UIView.animate(withDuration: 0.3 / 2, animations: {
                selectView.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }) { finished in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    selectView.transform = CGAffineTransform.identity
                })
            }
        }
    }
    func createButton(x: Int, tag: Int = 0) {
        
        let button = UIButton()
        button.frame = CGRect(x: x, y: 0, width: thumbSize, height: thumbSize)
        button.backgroundColor = unFilledThumbColor
        button.addTarget(self, action: #selector(onThumb), for: .touchUpInside)
        button.setTitle(nil, for: .normal)
        button.layer.cornerRadius = thumbRadius
        button.tag = tag
        thumbs.append(button)
        self.addSubview(button)
        if(shouldShowTitle) {
            let label = UILabel()
            label.font = titleFont
            label.textColor = self.unSelectedColor()
            label.frame = CGRect(x: ((x + (thumbSize/2)) - (thumbSize*2) + (thumbSize)), y: thumbSize + 8 , width: thumbSize * 3, height: 13)
            var width : CGFloat = 0.0
            if let title = titleArray?[tag] {
                label.text = title
            }else{
                label.text = "UnKnown"
            }
            label.tag = tag
            if let text = label.text {
                width = text.width(withConstrainedHeight: 30.0, font: titleFont)
            }else{
                width = CGFloat(thumbSize * 3)
            }
            label.frame = CGRect(x: CGFloat(x + (thumbSize/2)) - (width/2) , y: label.frame.origin.y, width: width, height: label.frame.size.height)
            labels.append(label)
            self.addSubview(label)
        }
    }
    
    @objc func onThumb (_ sender: UIButton) {
        guard let delegate = self.sliderDelegate else{
            return
        }
        if (delegate.canChangeSliderPosition(to: sender.tag,stepper: self)) {
            changeViewSelection(tag: sender.tag)
        }

    }
    func changeViewSelection(tag: Int){
        resizeFilledBar(tag: tag)
        adjustThumbsColor(tag: tag)
        onSelect(tag)
    }
    func selectedColor() -> UIColor {
        return UIColor(red: 1.00, green: 0.38, blue: 0.00, alpha: 1)
    }
    func unSelectedColor() -> UIColor {
        return UIColor(red: 0.61, green: 0.61, blue: 0.61, alpha: 1)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
           let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
           let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
           
           return ceil(boundingBox.height)
       }
       func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
           let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
           let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
           
           return ceil(boundingBox.width)
       }
}
