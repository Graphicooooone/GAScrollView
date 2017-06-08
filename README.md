# GAScrollView

## 一个无限轮播组件 (基于UICollectionView实现 重用、高效、可深度自定义) </br></br>


> 与传统的取余实现无限轮播不同 </br>
&emsp;&emsp;该组件实现无限轮播的思路为collectionView的真实indexPath和对外逻辑indexPath进行转换 </br></br>


> 该组件还支持多图片框架兼容 (使用 GACacheImageScheme 枚举进行指定) </br>
&emsp;&emsp;支持YYImage SDWebImage AFNetworking-UIKit GAScrollView自带的双层缓存机制 </br></br>

> 保留属性 : GAScrollViewTransformStyle </br>
&emsp;&emsp;为后续提供更多转换动画保留的接口
