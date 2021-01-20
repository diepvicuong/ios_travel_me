import UIKit
//import AMPopTip

@IBDesignable
class CustomTextField: UITextField {

    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 8
    
//    let popTip = PopTip()
    var popTipContent: String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        popTip.bubbleColor = UIColor.flatRed()
//        popTip.textColor = .white
//        popTip.cornerRadius = 8
//        popTip.font = UIFont.systemFont(ofSize: 12.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 29, height: 29))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 29, height: 29))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
        
    }
    
    func showPopTip(isShow: Bool, text: String?) {
//        if isShow {
//            if (!popTip.isVisible){
//                displayPopTip(text: text ?? "")
//            } else {
//                if popTipContent != text {
//                    displayPopTip(text: text ?? "")
//                }
//            }
//        } else {
//            rightImage = nil
//            popTip.hide()
//            popTipContent = ""
//        }
    }
    
//    func displayPopTip(text: String) {
//        rightImage = UIImage(icon: .googleMaterialDesign(.error), size: CGSize(width: 24, height: 24), textColor: UIColor.flatRed(), backgroundColor: .clear)
//        popTip.show(text: text, direction: .up, maxWidth: 200.0, in: self, from: rightViewRect(forBounds: bounds).offsetBy(dx: 0, dy: -(superview!.bounds.height-bounds.height)/2))
//        popTipContent = text
//    }

}

