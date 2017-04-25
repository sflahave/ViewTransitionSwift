import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var frontView: UIImageView!
    @IBOutlet var backView: UIImageView!
    
    @IBOutlet weak var fadeButton: UIBarButtonItem!
    @IBOutlet weak var flipButton: UIBarButtonItem!
    @IBOutlet weak var bounceButton: UIBarButtonItem!
    
    private var priorConstraints: [NSLayoutConstraint]?

    func constrainSubview(_ subview: UIView, toMatchWithSuperView superview: UIView) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary = ["subview": subview]
        
        let hConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[subview]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let vConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[subview]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let constraints = hConstraints + vConstraints
        
        superview.addConstraints(constraints)
        
        return constraints
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start off by using the front view (Palm trees)
        view.addSubview(frontView)
        
        // since frontView has no constraints set to match it's superview, we set them here
        priorConstraints = constrainSubview(frontView, toMatchWithSuperView: view)
        
        // configure our toolbar with the appropriate transition effects
        // note: the bounce button only shows for iOS 7.0 or later
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexItem, fadeButton, flipButton, bounceButton]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func performTransition(options: UIViewAnimationOptions) {
        var fromView: UIView!
        var toView: UIView!
        
        if frontView.superview != nil {
            fromView = frontView
            toView = backView
        } else {
            fromView = backView
            toView = frontView
        }
        
        UIView.transition(from: fromView, to: toView, duration: 1.0, options: options) { _ in
            if let constraints = self.priorConstraints {
                self.view.removeConstraints(constraints)
            }
        }
        
        priorConstraints = constrainSubview(toView, toMatchWithSuperView: view)
    }
    
    @IBAction func flipAction(_ sender: UIBarButtonItem) {
        performTransition(options: .transitionCrossDissolve)
    }
    
    @IBAction func fadeAction(_ sender: UIBarButtonItem) {
        let transitionOption: UIViewAnimationOptions = frontView.superview != nil ? .transitionFlipFromLeft : .transitionFlipFromRight
        performTransition(options: transitionOption)
    }
    
    @IBAction func bounceAction(_ sender: UIBarButtonItem) {
        var fromView: UIView!
        var toView: UIView!
        
        if frontView.superview != nil {
            fromView = frontView
            toView = backView
        } else {
            fromView = backView
            toView = frontView
        }
        
        var startFrame = view.frame
        var endFrame = startFrame
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = -startFrame.size.height
        endFrame.origin.y = 0
        
        toView.frame = startFrame
        
        view.addSubview(toView)
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 5.0,
            options: [],
            animations: {
                toView.frame = endFrame
            },
            completion: { _ in
                if let constraints = self.priorConstraints {
                    self.view.removeConstraints(constraints)
                }
                fromView.removeFromSuperview()
            }
        )
    }


}

