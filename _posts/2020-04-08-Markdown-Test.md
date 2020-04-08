---
layout: default
title: Markdown test
mathjax: true
---

<h1>{{ page.title }}</h1>

# 一级标题

## 二级标题

### 三级标题

- bullet_name

- ~~被划掉的文字~~
- ~~被划掉的文字~~

1. number1
2. number2

- [x] 选中了的框
- [ ] 未选中的框

> 文字
> 文字

[文字内容](链接)

​```cpp
using int64 = long long;
int main() {
  cout << "hello world" << endl;
  return 0;
}
```

$$
a+b\le c
$$

$\int x^2 dx$


<hr>

Welcome to baihacker's Github Homepage
======================================

[baihacker.me](http://baihacker.me/)

[contact me](https://github.com/baihacker/main/issues/1)

My Blogs
=======

[GitHub Blog](http://baihacker.github.io/main/)
  * Project Euler badge, topcoder provile, soj profile
  * Solution to GCJ 2014 and GCJ 2015
  * Stop updating now
  
[CSDN Blog(Chinese)](http://blog.csdn.net/baihacker)
  * Algorithm
  * C++
  * Windows client application development

[Baidu Blog(Chinese)(Not available)](http://hi.baidu.com/feixue)
  * My articles from 2005 to 2014
  * This link is not available now since baidu didn't provide the service  from 2015

BBIC (baihacker's birthday invitation contest)
====

[bbic 2009](http://acm.scu.edu.cn/soj/contest/contest.action?cid=202)

[bbic 2010](http://acm.scu.edu.cn/soj/contest/contest.action?cid=249)

[bbic 2012](http://acm.scu.edu.cn/soj/contest/contest.action?cid=329)

[bbic 2014](http://acm.scu.edu.cn/soj/contest/contest.action?cid=346)

Others
======
[How to build chromium (chinese)](https://github.com/baihacker/main/tree/master/chromium)

<hr>

# sb
A very simple building system

## Introduction
* SB is a wrapper of compilers, you can
  * Use a simple wrapper command to compile/run your source code without writing long compiling options.
  * Run the binary automatically after success compiling just by adding an option.
  * Configure the compiler easily
    * Use Object Oriented way to organize compiler configurations.
    * Use variable to configure compilers.
    * Support variable override.
    * Support environment variable.
* Support nearly all kinds of compilers (easy to extend to other compiler/languages):
  * mingw: c, c++
  * tdm-mingw: c, c++
  * clang: c, c++
  * dcj: c++
  * python interpreter: python
  * go compiler: go
  * java compiler: java
  * scala interpreter: scala
  * ghc: haskell
  * vc: c, c++
* Work with [win_toolchain_2013e](http://yun.baidu.com/share/link?shareid=2799405881&uk=2684621311) without installing vs2013.
* Support Windows and Linux distributions.

## Installation
### Simple installation
* Install python 2.
* Put all the files in a directory and make sure that the `PATH` environment variable contains that directory.
* Edit configuration file `compilers.json`.
* Put `compilers.json` in a directory and the directory can be (first match):
  * `SB installation directory`
  * `%HOMEDIR%/config`
  * `%ROOTDIR%/config`
  * [Windows] `%APPDATA%/../LocalLow/dcfpe`
  * [Windows] `%APPDATA%`
  * The directories in `%PATH%`

### Install with pre-defined directory structures (recommended)
This installation uses this directory structures:
  * %ROOTDIR% is the root directory.
    * %ROOTDIR%/app the directory to install applications.
    * %ROOTDIR%/app/DevSoft development related software.
    * %ROOTDIR%/app/MathsSoft maths related software.
    * %ROOTDIR%/projects your work directory, visual studio code configuration file is initialized there (.vscode).
    * %ROOTDIR%/devices device dependent data. e.g. If you have two PCs, each PC has its own directory.
  * %HOMEDIR% is the home directory.
    * %HOMEDIR%/config will contain compilers.json and a copy of setup.py.
    * %HOMEDIR%/config/vsc_config a copy of vsc_config.
    * %HOMEDIR%/usr/bin/sb this script will copy the **sb system** there.

#### Install on windows

  * Prepare
    * Install git.
    * Clone sb to a directory.
    * Install python 2.
    * Make sure environment variable ROOTDIR and HOMEDIR are valid directory path.
      * No need to create the sub-directories of ROOTDIR OR HOMEDIR and they will be created automatically if not exist.
      * ROOTDIR and HOMEDIR may be the directory.
    * Make sure DEVPATH is a part of PATH, i.e PATH=%DEVPATH%;...
    * Check other configurations.
    * Note: Open and close the environment setting dialog to let the new created/updated environment variables take effect.
  * Install
    * Run cmd with administrator permission.
    * Enter sb directory.
    * Execute: python setup.py
  * After installing sb
    * Open and close the environment setting dialog to let the new created/updated environment variables take effect.

#### Install on linux

  * Prepare
    * Install git.
    * Clone sb to a directory.
    * Install python 2.
    * Make sure environment variable ROOTDIR and HOMEDIR are valid directory path. 
      * No need to create the sub-directories of ROOTDIR OR HOMEDIR and they will be created automatically if not exist.
      * ROOTDIR and HOMEDIR may be the directory.
    * Check other configurations
    * Append the following code (please modify `<home dir> and <root dir>`) to `~/.bashrc`
```bash
export HOMEDIR=<home dir>
export ROOTDIR=<root dir>

if [ -f ~/.sbrc ]; then
  . ~/.sbrc
fi

export PATH=$DEVPATH${PATH:+:${PATH}}
```

  * Install
    * Open terminal.
    * Enter sb directory.
    * Execute: python ./setup.py

#### Install on mac
Nearly the same as that on linux.
  * Append toe code to `~/.bash_profile` instead of `~/.bashrc`.
  * Remove `-fopenmp` from your compiler option.

#### Other configurations

  * [Windows] install MinGW under `%ROOTDIR%/app/DevSoft`.
    * Please make sure `%ROOTDIR%/app/DevSoft/MinGW-x86_64-8.1.0-posix-seh-rt_v6-rev0/mingw64/bin` exist because this script will add that path to environment variable list.
    * If the path doesn't sound good to you, please install it in another path but don't forget to edit setup.py (method: setup_environment_variables) and compilers.json (compiler: __compiler_base)
  * Configure compiler compilers.json.
    * Compiling options
      * You can customize the compile command there.
    * [C/C++] Linked lib
      * The `mingw64-pe` (Windows) will link to libs of GMP, BF, FLINT, MPFR, MPIR and `gcc-pe` will link to the lib of GMP.
        * Remove the libs you don't use.
        * Keep te libs you use.
        * Add more libs if necessary.
        * You can utilize the include path `%HOMEDIR%/usr/include` and the lib path `%HOMEDIR%/usr/lib` configured by setup.py to install libraries.
    * [pe](https://github.com/baihacker/pe) compatibility.
      * This script will install [pe](https://github.com/baihacker/pe) to `%HOMEDIR%/usr/include/pe` and **configure** it automatically.
      * In the auto configure process, it checks whether the header file of a library exists and `enable` the corresponding library if the header file is found.
        * For non-VC compilers, `enable` means to include the library header file and to enable the pe codes depend on them.
        * For VC compilers, `enable` means to include the library header file and to enable the pe codes depend on them and to add the corresponding link option.
      * You need to make sure that the pe configure is consistent with your compiler configurations when compiling a pe based source file
        * CPLUS_INCLUDE_PATH or the compiling option has the path of the header file of enabled library.
        * LIBRARY_PATH or the compiling option has the path of the lib of the enabled library (Some libraries don't have libs).
        * The compiling option has the lib of the enabled library (Some libraries don't have libs). As mentioned above, it is not necessary for VC compilers.

## Usage
* Command
  * Windows: pe++.py `<source file>`.
    * pe++ `<source file>` is available but it is not recommended.
  * Linux: pe++ `<source file>`.
  * pe++.py uses {'language':'cpp','name':'mingw64-pe'} to find the corresponding compiler.
  * dcj.py, jr.py, vc++.py, clang++ are similar to pe++.py but a different compiler spec to find the compiler, please see copmiler spec list.
  * pe++ (linux) will reuse pe++.py with another copmiler name gcc-pe.
* options
  * -o `<output file name>`
    * Specify the output file name. (Default = empty string and determined by compilers)
  * -debug
    * Enable debug mode.
  * -release
    * Enable release mode. (Default)
  * -r
    * Run the application after compiling your source code successfully. (Disabled by default)
  * -l
    * specify the language
  * -n
    * specify the name field in compiler spec.
  * -a
    * specify the arch field in compiler spec.
  * --
    * all the options after -- will be appended to the compiling command.
* Compiler spec list
  * clang++.py
    * {'language':'cpp','name':'clang-pe'}
  * dcj.py
    * {'language':'cpp','name':'dcj'}
  * jr.py
    * {'language':'java'}
  * pe++.py
    * {'language':'cpp','name':'mingw64-pe'}
  * vc++.py
    * {'language':'cpp','name':'vc','version':'14','arch':'x64'}


{% include mathjax.html %}