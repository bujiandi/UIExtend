//
//  ImagePreViewController.swift
//  ImagePreviewController
//
//  Created by Steven on 2017/4/26.
//  Copyright © 2017 cn.steven. All rights reserved.
//

import UIKit

@objc protocol ImagePreviewControllerDelegate : class{//只能由类来实现加class {

    @objc optional func shouldDeleteOfIndex(_ index:Int)
    
}

public enum ImagePreviewKey:String {
    case url
    case img
    case placeholder
}


//public let k_ImagePreviewURL = "ImagePickerURL"
//public let k_ImagePreviewIMG = "ImagePickerIMG"
//public let k_ImagePreviewPlaceholder = "ImagePickerPlaceholder"


public class ImagePreViewController: UIViewController {

    public var isChildController:Bool = false
    public var imageSpace:CGFloat = 0
    public var currentIndex:Int = 0{
    
        didSet{
            setImageWithIndex(currentIndex, imageView: currentImageView!)
        }
    
    }
    public var images = [[ImagePreviewKey:Any]]()
    public var placeholdImage:UIImage?
    weak var delegate:ImagePreviewControllerDelegate?//代理
    
    public var currentImageView:UIImageView?{
        get{
            return imageViews?[index]
        }
    
    }
    public var nextImageView:UIImageView?{
        get{
            return imageViews?[index == 0 ? 1 : 0]
        }
        
    }
    
    
    //私有属性
    fileprivate var beganFrame : CGRect = CGRect.zero
    fileprivate var beganPoint : CGPoint = CGPoint.zero
    fileprivate var beganScale : CGFloat = 0
    
    fileprivate var index:Int = 0
    fileprivate var imageViews : Array?
        = [UIImageView]()
    
    fileprivate var naviBarHidden = false
    fileprivate var toolBatHidden = false
    fileprivate var isHidden = false
    fileprivate var cancelTap = false
    fileprivate var doubleTapTimes:Int = 0
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.title
        view.clipsToBounds = true
        view.backgroundColor = UIColor.black
        
        //如果有移除事件
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onDeleteCurrentImage))
        if self.navigationController != nil && self.navigationController?.viewControllers.first === self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel))
            
        }else if navigationController == nil && !isChildController {
            let size = view.bounds.size
            let side : CGFloat = 50
            let button = UIButton(frame: CGRect(x: (size.width - side) / 2, y: size.height - CGFloat(100), width: side, height: side))
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
            button.titleLabel?.textAlignment = .center
            button.alpha = 0.7
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.white.cgColor
            
            button.layer.cornerRadius = side / 2.0
            button.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin,UIView.AutoresizingMask.flexibleLeftMargin,UIView.AutoresizingMask.flexibleRightMargin]
            view.addSubview(button)
   
        }
        
        //缩放手势
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onPinch(_:)))
        view.addGestureRecognizer(pinch)
        
        // 双击手势
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        tap2.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap2)
        
        //轻触手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        
        view.addGestureRecognizer(tap)
        
        //拖拽手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        view.addGestureRecognizer(pan)
        
        //长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        view.addGestureRecognizer(longPress)
        
        naviBarHidden = (navigationController?.isNavigationBarHidden)!
        toolBatHidden = (navigationController?.isToolbarHidden)!
        if isChildController {
            return
        }

        changeHidden()
    }

    public override func viewWillAppear(_ animated: Bool) {
        let currentImageView = createImageByFactory()
        let nextImageView = createImageByFactory()
        imageViews = [currentImageView,nextImageView]
        for imageView in imageViews! {
            view.insertSubview(imageView, at: 0)
        }
        
        if currentIndex >= images.count {
            currentIndex = 0
        }
        
        if images.count == 0 {
            return
        }
        
        setImageWithIndex(currentIndex, imageView: currentImageView)
        super.viewWillAppear(animated)
        if isChildController {
            return
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isHidden = true
        changeHidden()
    }
    public override func viewDidDisappear(_ animated: Bool) {
        _ = imageViews?.map{ $0.removeFromSuperview() }
        imageViews = nil
        super.viewDidDisappear(animated)
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public static func createWithImages(_ array:Array<Any>,urlsBlock:(Any,Int) -> Array<URL>) -> ImagePreViewController{
        var images = [[ImagePreviewKey:Any]]()
        
        for row in 0..<array.count {
            
            let urls = urlsBlock(array[row],row)
            
            for url in urls {
                let key = "key"//添加SDwebimage的库之后进行
                //SDWebImageManager.shared.cacheKey(url)
                
                
                let image:UIImage? = UIImage()//添加SDWebImage库之后添加代码
                //SDImageCache.shared.imageFromDiskCache(key)
                
                //如果图片尚未缓存，则使用url
                if image != nil {
                    images.append([.img:image, .url:url])
                }else{
                    images.append([.url:url])
                }
  
            }
 
        }
        
        let picker = ImagePreViewController()
        picker.images = images
        picker.imageSpace = 15
        return picker
    }
    
    public static func createWithimages(_ array:Array<Any>,urlBlock:@escaping (Any,Int) -> URL) -> ImagePreViewController{
    
        return createWithImages(array, urlsBlock: { (obj, index) -> Array<URL> in
            return [urlBlock(array[index],index)]
        })
        
        
    }

}

extension ImagePreViewController{
    static let lastTimestamp : TimeInterval = 0

    func setImageWithIndex(_ index:Int,imageView:UIImageView) {
        
        imageView.image = nil
        if index > images.count {
            return
        }
        let data = images[index]
        //如果有图片则直接显示
        if let item = data[.img] as? UIImage {
            imageView.image = item
            return
        }
        
        //否则先获取缩略图
        let placeholderImage = data[.placeholder] as? UIImage ?? self.placeholdImage
        
        let item = data[.url]!
        if item != nil && item is URL {
            
            // 如果缓存中存在此图片, 则更新源
            //添加SDWebImage代码
            
  
        }
        
    }

    //系统方法
    public override var shouldAutorotate: Bool{
        get{
            return true
        }
        
    }
    
    //屏幕支持的方向
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        
    }

    @objc func onDeleteCurrentImage() {
        //防止点击过快动画未完成
        var nowTimestamp = CACurrentMediaTime()
        if nowTimestamp - ImagePreViewController.lastTimestamp > 0.5{
            return
        }
        nowTimestamp = ImagePreViewController.lastTimestamp
        
        //如果索引超出边界hulue
        if currentIndex < 0 || currentIndex >= images.count {
            return
        }
        //如果委托对象未实现此方法则忽略
        delegate?.shouldDeleteOfIndex?(currentIndex)
       
        
        let size = view.bounds.size
        var nextFrame = view.bounds
        let center = view.center
        
        // 如果当前是最后一张 则使用前一张图片 否则使用下一张图片
        if currentIndex == images.count - 1 {
            nextFrame.origin.x = -size.width - imageSpace
            setImageWithIndex(currentIndex - 1, imageView: nextImageView!)
        }else{
            nextFrame.origin.x = size.width + imageSpace
            setImageWithIndex(currentIndex + 1, imageView: nextImageView!)
        
        }
        
        nextImageView?.frame = nextFrame
        
        UIView.animate(withDuration: 0.3, animations: { 
            UIView.setAnimationCurve(.easeInOut)
            self.currentImageView?.frame = CGRect(x: center.x, y: center.y, width: 0, height: 0)
        }) { (finished) in
            self.currentImageView?.frame = nextFrame
            self.currentImageView?.image = nil
        }
        
        UIView.animate(withDuration: 0.3, animations: { 
            UIView.setAnimationCurve(.easeInOut)
            UIView.setAnimationDelay(0.2)
            self.nextImageView?.frame = self.view.bounds
        }) { (finished) in
            let index = self.currentIndex
            if index == self.images.count - 1{
                self.currentIndex -= 1
            }
            
            self.images.remove(at: index)
            self.index = self.index == 0 ? 1 : 0
            self.nextImageView?.image = nil
            
            if self.images.count == 0{
                self.onCancel()
            }
            
       
        }
    }
    
    
    @objc func onCancel() {
        if isChildController {
            return
        }
        if navigationController != nil && navigationController?.viewControllers.first !== self {
            navigationController?.popViewController(animated: true)
        }else if self.navigationController != nil{
            navigationController?.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    
    
    func changeHidden() {
        if isChildController {
            return
        }
        isHidden = !isHidden
        
        if isHidden {
            navigationController?.setNavigationBarHidden(isHidden, animated: true)
            navigationController?.setToolbarHidden(isHidden, animated: true)
        }else{
            navigationController?.setNavigationBarHidden(naviBarHidden, animated: true)
            navigationController?.setToolbarHidden(toolBatHidden, animated: true)
        }

        
    }
    
    
    func createImageByFactory() -> UIImageView {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        return imageView
    }
    func replaceDataImageWithIdex(_ image:UIImageView,index:Int) {
        
        if index >= images.count{
            return
        }
        var newData = images[index]
        newData[.img] = image
        images[index] = newData
        
    }


}

//手势

extension ImagePreViewController{
    
    
    @objc func onPinch(_ pinch:UIPinchGestureRecognizer) {
        let scale = pinch.scale
        let velocity = pinch.velocity
        switch pinch.state {
        case .began:
            beganScale = scale
            beganFrame = (currentImageView?.frame)!
            doubleTapTimes = 0
            break
        case .changed:
            setFrameWithScale(Double(scale))
            break
        case .ended:
            setFrameWithScale(Double(scale))
            var frame = currentImageView?.frame ?? CGRect.zero
            if velocity < -20 {
                frame = view.bounds
            }else if frame.width < view.frame.width && frame.height < view.frame.height{

                frame = self.view.bounds
            
            }else if frame.minX > CGFloat(0){
                frame.origin.x = 0
            
            }
            UIView.animate(withDuration: 0.3, animations: { 
                UIView.setAnimationCurve(.easeInOut)
                self.currentImageView?.frame = frame
            })
        
            beganScale = 1;
            beganFrame = CGRect.zero
            break
        default:
            break
        }
    }
    
    @objc func onPan(_ pan:UIPanGestureRecognizer) {
        let point = pan.location(in: self.view)
        switch pan.state {
        case .began:
            beganPoint = point
            beganFrame = currentImageView?.frame ?? CGRect.zero
            currentImageView?.tag = 0
            nextImageView?.tag = 0
            doubleTapTimes = 0
            break
            
        case .changed:
            setFrameWithPoint(point)
            break
        case .ended:
            var duration : CGFloat = 0.3
            let velocity = pan.location(in: view)
            setFrameWithPoint(point)
            var nextFrame = nextImageView?.frame ?? CGRect.zero
            var currFrame = currentImageView?.frame ?? CGRect.zero
            let maxX = nextFrame.maxX
            let minX = nextFrame.minX
            let width = view.frame.width
            let width_1_3 = view.frame.width / 3.0
            //如果上下超出视图边界则对其到边界
            if currFrame.minY > CGFloat(0) {
                currFrame.origin.y = 0
            }else if currFrame.maxY < view.frame.height{
                currFrame.origin.y = view.frame.height - currFrame.height
            }
            
            
            
            if maxX + velocity.x * duration > width_1_3 && maxX < width && currentIndex > 0 {
                //显示上一张图片，如果速率够高，则减小动画时间
                duration = min(duration, abs(300 / velocity.x))
                
                currentIndex -= 1
                index = index == 0 ? 1 : 0
                
                currFrame = self.view.bounds
                nextFrame = self.view.bounds
                nextFrame.origin.x = width + imageSpace
                setImageWithIndex(currentIndex, imageView: currentImageView!)
                
            }else if minX > CGFloat(0) && minX + velocity.x * duration < width_1_3 * CGFloat(2) && currentIndex < images.count - 1{
                // 显示下一张图片 如果速率够高 则减小动画时间
                duration = min(duration, abs(300 / velocity.x))
                currentIndex -= 1
                index = index == 0 ? 1 : 0
                currFrame = self.view.bounds
                nextFrame = self.view.bounds
                nextFrame.origin.x = -width - imageSpace
                setImageWithIndex(currentIndex, imageView: currentImageView!)
            }else if minX > 0 && minX < width + imageSpace{
                // 恢复本张图片 next 为下一张
                currFrame.origin.x = width - currFrame.width
                nextFrame = self.view.bounds
                
                nextFrame.origin.x = width + imageSpace
      
            }else if maxX < width && maxX > CGFloat(0) - imageSpace{
                // 恢复本张图片 next 为上一张
                currFrame.origin.x = 0
                nextFrame = self.view.bounds
                nextFrame.origin.x = -width - imageSpace

            }else{
                //let velocity2 = pan.location(in: self.view)
                currFrame.origin.x = max(min(currFrame.origin.x + (velocity.x * duration * CGFloat(0.3)), 0), width - currFrame.width)
                currFrame.origin.y = max(min(currFrame.origin.y + (velocity.y * duration * CGFloat(0.3)), 0), self.view.frame.height - currFrame.height)
                nextFrame = self.view.bounds
                nextFrame.origin.x = currFrame.maxX + imageSpace
                duration = min(duration, abs(300 / velocity.x))
         
            }
            
            currentImageView?.tag = 0
            nextImageView?.tag = 0
            UIView.animate(withDuration: TimeInterval(duration), animations: { 
                UIView.setAnimationCurve(.easeOut)
                self.currentImageView?.frame = currFrame
                self.nextImageView?.frame = nextFrame
            })
            
            beganPoint  = CGPoint.zero
            beganFrame = CGRect.zero
            break
        default:
            break
        }
        
        //如果不是结束状态则跳过
        if pan.state != .ended {
            return
        }
        
    }

    @objc func onDoubleTap(_ tap:UITapGestureRecognizer) {
        cancelTap = true
        beganFrame = currentImageView?.frame ?? CGRect.zero
        if beganFrame.width == view.frame.width {
            UIView.animate(withDuration: 0.3, animations: { 
                UIView.setAnimationCurve(.easeInOut)
                self.setFrameWithScale(2.0)
            })

        }else{
            UIView.animate(withDuration: 0.3, animations: { 
                UIView.setAnimationCurve(.easeInOut)
                self.currentImageView?.frame = self.view.bounds
            })
        
        }
        
        beganFrame = CGRect.zero
        if doubleTapTimes + 1 >= 3 {
            onCancel()
        }

        
    }
    
    
    @objc func onTap(_ tap:UITapGestureRecognizer) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { 
            if self.cancelTap{
                self.cancelTap = false
                return
            }
            
            
            
            //如果没处理删除事件，则点击直接关闭
//            if !self.delegate.responds(to: #selector(ImagePreviewControllerDelegate.shouldDelegateOfIndex(_:))){
//            
//                self.onCancel()
//            }else{
//                self.doubleTapTimes = 0
//                self.changeHidden()
//            }
            
            self.doubleTapTimes = 0
            self.changeHidden()
            
        }
        
    }
    
    @objc func onLongPress(_ longPress:UILongPressGestureRecognizer){
        
        if longPress.state == .began{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "保存到相册", style: .destructive, handler: { (action) in
                UIImageWriteToSavedPhotosAlbum((self.currentImageView?.image)!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        }
        
        
    }
    
    
    func setFrameWithScale(_ scale:Double) {
        let screenSize = view.bounds.size
        var size = beganFrame.size
        let center = currentImageView?.center
        size.width = ceil(max(screenSize.width / 2, size.width * CGFloat(scale)))
        
        size.height = ceil(max(screenSize.height / 2, size.height * CGFloat(scale)))
        
        var frame = currentImageView?.frame
        frame?.size = size
        currentImageView?.frame = frame!
        currentImageView?.center = center!
        
    }
    
    func setFrameWithPoint(_  point:CGPoint) {
        var frame = beganFrame
        let size = view.bounds.size
        var offset = CGPoint.zero
        offset.x = ceil(point.x - beganPoint.x)
        offset.y = ceil(point.y - beganPoint.y)
        frame.origin.x += offset.x
        
        if (currentImageView?.frame.size.equalTo(size))! {
            frame.origin.y += offset.y
        }
        
        if frame.maxX < view.bounds.width {
            nextImageView?.frame = CGRect(x: frame.maxX + imageSpace, y: 0, width: size.width, height: size.height)
            
            if nextImageView?.tag != 1{
                setImageWithIndex(currentIndex + 1, imageView: nextImageView!)
            }
            nextImageView?.tag = 1
            
        }else if frame.minX > 0{
            nextImageView?.frame = CGRect(x: frame.minX - imageSpace - size.width, y: 0, width: size.width, height: size.height)
            if nextImageView?.tag != 1 {
                setImageWithIndex(currentIndex - 1, imageView: nextImageView!)
                
            }
            nextImageView?.tag = -1
        
        }else{
            nextImageView?.frame = CGRect(x: size.width + imageSpace, y: 0, width: size.width, height: size.height)
            if nextImageView?.tag != 0 {
                //sdWebImage框架补充代码
//                nextImageView.sd_cancelCurrentImageLoad
                nextImageView?.image = nil
            }
            nextImageView?.tag = 0
        }
        currentImageView?.frame = frame

    }
    
    //Swift实现:
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil {
            
        } else {
            
        }
    }
    
    
    
}








