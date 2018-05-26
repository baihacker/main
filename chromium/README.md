本目录介绍如何编译chromium并提供对应的编译脚本(包含对原有配置的修改以及一些新功能的添加).

本文上一个版本:[Windows下vs2015编译Chromium[2017/04/01]](https://blog.csdn.net/baihacker/article/details/68948978)

已编译好的binary可以在[这里](http://pan.baidu.com/share/link?shareid=288371&uk=2684621311#path=%252F%25E8%25BD%25AF%25E4%25BB%25B6%25E5%25BC%2580%25E5%258F%2591%25E8%25B5%2584%25E6%2596%2599%252Fchrome%252Fbin)找到。

准备
===
* python2
* git
* windows7 64或更高的64位windows
* vs2017（记得安装sdk，15.7.2或更新版本）
* 配置：60G+ssd，32G+ ram

步骤
===
 * 选择你需要编译的版本
   * 在[http://omahaproxy.appspot.com/](http://omahaproxy.appspot.com/)能找到不同平台上的最新版本的情况，比如release，beta，alpha之类的
   * 在[https://chromium.googlesource.com/chromium/src.git/+refs](https://chromium.googlesource.com/chromium/src.git/+refs)能找到更多的tags
 * 准备必要的文件
   * 新建chromium目录
   * 在该目录下解压好[depot_tools bundle](https://storage.googleapis.com/chrome-infra/depot_tools.zip) 即chromium\depot_tools\gclient.py为一个合法路径
   * 在chromium下建立[build脚本](https://github.com/baihacker/main/blob/master/chromium/build_66.0.3359.181.bat)
 * 检查build脚本根据脚本注释作出必要的修改后执行脚本
