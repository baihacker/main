:: Step 1: 配置环境变量`
set PATH=%~dp0depot_tools;%PATH%
set GYP_DEFINES=branding=Chromium buildtype=Official
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
:: VERSION >= 15.7.2
set GYP_MSVS_VERSION=2017


:: Step 2: 更新depot_tools
::如果出现cipd.ps1的错误，可以忽略
update_depot_tools


:: Step 3: 初始化gclient的配置,并sync代码.
:: 在第一次运行本脚本时执行
fetch.py --nohooks chromium


:: Step 4: 获取所有tag及相应数据
cd src
git fetch -t
cd ..


:: Step 5: 根据对应tag,新建并切换到build分支
cd src
git checkout -b build_69.0.3497.100 tags/69.0.3497.100
cd ..


:: Step 6: 同步子projects, 该命令根据src\DEPS内的配置将依赖的库checkout到需要的版本
:: 修改src/DEPS, webrtc的版本号从9110a54a60d9e0c69128338fc250319ddb751b5a修改
:: 为881fe53d1faefe135c0d6959794da91a25e247f2
:: 因为9110a54这个commit不存在,通过
:: https://chromium.googlesource.com/chromium/src.git/+log/69.0.3497.100/DEPS
:: 找到最近一个webrtc的修改是
:: https://chromium.googlesource.com/chromium/src.git/+/833067b432bf6306c62474d3ff5d5f6fc6ff84dd
:: 进而在
:: https://webrtc.googlesource.com/src.git/+log/0f5400acfa40..881fe53d1fae
:: 中找到用来替代的版本9110a54
:: 在这一步完成后会提示
:: 'src\third_party\webrtc' is no longer part of this client.
:: It is recommended that you manually remove it.
:: 但实际上并不能删除,而需要同步到前文提到的版本,否则在生成编译脚本时会发现
:: 对webrtc的依赖,webrtc中缺乏被依赖的项.
gclient.py sync --nohooks


:: Step 7: runhooks 一些准备工作
:: 对于失败的runhooks可以通过将src\DEPS下对应的action删除掉，重新runhooks
:: 比如，src/build/android/play_services/update.py所在的action被我删除掉
:: 对于69.0.3497.100,我没有遇到失败的情况
gclient.py runhooks


:: Step 8: 修改编译配置

::启用official build
::修改src\build\config\BUILDCONFIG.gn，将is_official_build的值改为true

::去掉显示头文件的包含树
::修改src\build\toolchain\win\BUILD.gn，将/showIncludes删除掉


:: Step 9: 修改源文件以增加自定义功能


:: Step 6, 8, 9 可以参考 changes_69.0.3497.100.diff


:: Step 10: 生成ninja编译脚本
cd src
gn gen out/Default


:: Step 11: 修改ninja编译参数，如target_os="win"，target_cpu="x64"等
:: 参考https://chromium.googlesource.com/chromium/src/+/master/tools/gn/docs/quick_start.md
gn args out/Default


:: Step 12: 编译
ninja -C out/Default chrome