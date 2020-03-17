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
- Xcode 11.0
- Swift 5.1

## 添加指数指标
```swift
enum KSIndexAlgorithm {
    case none //无算法
    case timeline //时分
    case ma(Int, Int, Int) //简单移动平均数
    case ema(Int, Int, Int) //指数移动平均数
    case kdj //随机指标
    case macd(Int, Int, Int) //指数平滑异同平均线
    case boll(Int, Int) //布林线
    case rsi(Int, Int, Int) //RSI指标公式
    case avg(Int) //自定义均线
}

class KSCalculator: NSObject {

    class func ks_calculator(algorithm: KSIndexAlgorithm, index: Int = 0, datas: [KSChartItem]) -> [KSChartItem] {
        switch algorithm {
        case .none:
            return datas
        case .timeline:
            return datas
        case let .ma(small, middle, big):
            return ks_calculateMA(index: index, small: small, middle: middle, big: big, datas: datas)
        case let .ema(emaSmall, emaMiddle, emaBig):
            return ks_calculateEMA(index: index, emaSmall: emaSmall, emaMiddle: emaMiddle, emaBig: emaBig, datas: datas)
        case .kdj:
            return ks_calculateKDJ(index: index, datas: datas)
        case let .macd(emaSmall, emaBig, dea):
            return ks_calculateMACD(from: index, emaSmall: emaSmall, emaBig: emaBig, dea: dea, datas: datas)
        case let .boll(num,arg):
            return ks_calculateBOLL(index: index, num: num, arg: arg, datas: datas)
        case let .rsi(avgSmall, avgMiddle, avgBig):
            return ks_calculateRSI(index: index, avgSmall: CGFloat(avgSmall), avgMiddle: CGFloat(avgMiddle), avgBig: CGFloat(avgBig), datas: datas)
        case let .avg(num):
            return ks_calculateAvgPrice(index: index, num: num, datas: datas)
        }
    }
}
```
