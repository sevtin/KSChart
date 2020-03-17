# KSChart
![time](https://github.com/saeipi/KSChart/blob/master/Resources/time.jpg)

![candle](https://github.com/saeipi/KSChart/blob/master/Resources/candle.jpg)

![Cross](https://github.com/saeipi/KSChart/blob/master/Resources/Cross.png)

### 以下为模拟器数据，真机示例内存占用为12M（500多条K线数据），机型不同CPU占用差异会比较大，老设备在滑动时帧数会有所下降
![cpu](https://github.com/saeipi/KSChart/blob/master/Resources/cpu.jpeg)
![memory](https://github.com/saeipi/KSChart/blob/master/Resources/memory.jpeg)

反馈/技术交流群:902071358

### 如果觉得好用就打个赏呗
![Alipay](https://github.com/saeipi/KSChart/blob/master/Resources/Alipay.jpg)
![WeChatPay](https://github.com/saeipi/KSChart/blob/master/Resources/WeChatPay.jpeg)

## 开发环境
- Xcode 11.0+
- Swift 5.1+

## 示例
请参考KSKChartView.swift
```swift
class KSKChartView: KSBaseView {
    
    var klineData = [KSChartItem]()
    var configure: KSChartConfigure = KSChartConfigure.init()
    
    weak var delegate: KSKChartViewDelegate?
    
    lazy var chartView: KSZeroChartView = {
        let chartView         = KSZeroChartView(frame: self.bounds)
        let style             = configure.loadConfigure()
        chartView.style       = style
        chartView.delegate    = self
        self.addSubview(chartView)
        return chartView
    }()
    ......
}
```
