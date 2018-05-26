:: Step 1: 配置环境变量`
set PATH=%~dp0depot_tools;%PATH%
set GYP_DEFINES=branding=Chromium buildtype=Official
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
:: VERSION >= 15.7.2
set GYP_MSVS_VERSION=2017


:: Step 2: 更新depot_tools
::如果出现cipd.ps1的错误，可以忽略
update_depot_tools


:: Step 3: 初始化.gclient并同步代码
:: 如果同步代码时失败可以通过gclient.py sync --nohooks重新同步
:: 不推荐用--no-history
fetch.py --nohooks chromium


:: Step 4: 切换到分支 可选
:: 4.1和4.2中选一个，推荐4.2（在Step 3中去掉--no-hisotyr后似乎只能用4.2）

:: Step 4.1: 获取tags后并checkout到tag
:: cd src
:: git fetch -t
:: git checkout -b <local-branch-name> tags/<tag name>
:: cd ..

:: Step 4.2: 根据tag的sha1值checkout到tag
:: tag to sha1参考 https://chromium.googlesource.com/chromium/src.git/+refs
:: 例如: git checkout -b build_57.0.2987.133 8a67263f2d4e0fcbf1675e08b7e24672046463d2
cd src
git fetch -t
:: 66.0.3359.181的hash值是 164c37e3f235134c88e80fac2a182cfba3f07f00
git checkout -b build_66.0.3359.181 164c37e3f235134c88e80fac2a182cfba3f07f00
cd ..


:: Step 5: 同步子projects, 该命令根据src\DEPS内的配置将依赖的库checkout到需要的版本
gclient.py sync --nohooks
:: Step 5.1 Fix sync过程中的错误
:: 如：在编译57.0.2987.133时遇到
:: fatal: reference is not a tree: 275c7b012d0d3f08d8ba7360784d731a62d32318
:: 的问题，后来在通过DEPS的log:
:: https://chromium.googlesource.com/chromium/src.git/+log/57.0.2987.133/DEPS
:: 找到了DPS文件关于webrtc的最后一次提交:
:: https://chromium.googlesource.com/chromium/src.git/+/6e0179d4ab24b7270b452e4cc4f7c43c29bbae9b
:: 到webrtc目录下执行
:: git checkout d68fcc42256f0f6483d562aa69531091560ff9f2
:: 用这个版本替换了DEPS文件中的版本

:: 66.0.3359.181中对应的commit 不存在,需要手动check out到指定commit
cd src\third_party\webrtc
git checkout 12c8110e8c717b7f0f87615d3b99caac2a69fa6c
cd ..
cd ..
cd ..


:: Step 6: runhooks 一些准备工作
:: 对于失败的runhooks可以通过将src\DEPS下对应的action删除掉，重新runhooks
:: 比如，src/build/android/play_services/update.py所在的action被我删除掉
gclient.py runhooks


:: Step 7: 修改编译配置

::启用official build
::修改src\build\config\BUILDCONFIG.gn，将is_official_build的值改为true

::去掉显示头文件的包含树
::修改src\build\toolchain\win\BUILD.gn，将/showIncludes删除掉


:: Step 8: 修改源文件以增加自定义功能


:: Step 7, 8 可以参考 changes_66.0.3359.181.diff


:: Step 9: 生成ninja编译脚本
cd src
gn gen out/Default


:: Step 10: 修改ninja编译参数，如target_os="win"，target_cpu="x64"等
:: 参考https://chromium.googlesource.com/chromium/src/+/master/tools/gn/docs/quick_start.md
gn args out/Default


:: Step 11: 编译
ninja -C out/Default chrome
