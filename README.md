k线图/kline/kchart，已经集成MA/EMA/MACD/KDJ/BOLL/RSI/WR/AVG等指标，新增指标及其方便。适用于股票/区块链交易所等种类App。Swift5编写，CPU/内存占用率极低，60FPS稳定运行。示例集成websocket，并接入币安数据（需VPN）。项目采用CAShapelayer+UIBezierPath进行图形绘制，采用CATextLayer进行文本绘制。

## KSChart 效果图
<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/time.jpg" alt="分时图" width="600" height="604" align="middle"/>

<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/tais.jpg" alt="指标菜单" width="600" height="604" align="middle"/>

<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/candle.jpg" alt="蜡烛图" width="600" height="604" align="middle"/>

<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/cross.jpg" alt="选中单个蜡烛图" width="600" height="604" align="middle"/>

### 500多条K线数据，真机示例内存占用为11.8M（其中KSChart占用3M），机型不同CPU占用差异会比较大，老设备在滑动时帧数会略有下降
<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/cpu.jpg" alt="cpu占用率" width="800" height="338.6" align="middle"/>

<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/memory.jpg" alt="memory占用率" width="800" height="458" align="middle"/>

### 如果觉得好用就打个赏呗
<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/Alipay.jpg" alt="Alipay" width="200" height="251" align="left"/>
<img src="https://gitee.com/saeipi/KSChart/raw/master/Resources/WeChatPay.jpeg" alt="WeChatPay" width="200" height="275" align="middle"/>

## 开发环境
- Xcode 11.0+
- Swift 5.1+

## CocoaPods安装
```
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
    pod 'KSChart', '~> 5.1.9'
end
```

## 示例
请参考KSKChartView.swift
```swift
class KSKChartView: KSBaseView {
    
    lazy var klineData = [KSChartItem]()
    lazy var configure: KSChartConfigure = KSChartConfigure.init()
    
    weak var delegate: KSKChartViewDelegate?
    
    lazy var chartView: KSKLineChartView = {
        let chartView         = KSKLineChartView(frame: self.bounds)
        let style             = configure.loadConfigure()
        chartView.style       = style
        chartView.delegate    = self
        self.addSubview(chartView)
        return chartView
    }()
    ......
}
```

## 版本更新说明
```
5.1.8 稳定版
1、进一步优化CPU和内存占用率，CPU使用率降低20%以上；
2、精简代码KSKLineChartView代码；
3、分层管理k线视图的绘制内容；
4、重构边框与Y轴数值绘制代码；
5、修复已知bug。

5.1.9
1、新增WR/AVG指标
2、精简代码
3、优化API
```

## 下个版本
```
1、重新添加最大最小值的显示
2、对外API优化
```

反馈/技术交流群:902071358
