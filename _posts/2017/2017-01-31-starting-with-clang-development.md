---
layout: post
title: Starting With Clang Development
modified:
excerpt: "Out-of-the-tree development for Clang"
tags: [clang, llvm, development]
categories: blog
comments: true
crosspost_to_medium: true
date: 2017-01-31T16:24:47-05:00
---

In this post we'll setup Clang for out-of-the-tree development (3.9.0). 

* Table of Contents  
{:toc}

## HOW TO

I assume that clang/llvm is already compiled from source and it is installed as we covered in [building llvm with cmake]({{ site.url }}/blog/2016/02/27/building-llvm-with-cmake.html). Lets assume that the path for the llvm installation is `$HOME/opt/llvm`. Make sure you exported the following env to the shell:

    VERSION=3.9.0
    export LLVM_HOME=$HOME/opt/llvm
    export PATH=$LLVM_HOME/bin:$PATH
    export C_INCLUDE_PATH=$LLVM_HOME/include:$LLVM_HOME/lib/clang/$VERSION/include:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=$LLVM_HOME/include:$LLVM_HOME/lib/clang/$VERSION/include:$LLVM_HOME/include/c++/v1:$CPLUS_INCLUDE_PATH
    export LIBRARY_PATH=$LLVM_HOME/lib:$LIBRARY_PATH
    export DYLD_LIBRARY_PATH=$LLVM_HOME/lib:$DYLD_LIBRARY_PATH  

### Clone the Clang repo.

I forked the **clang** repo hosted in <a href="https://github.com/llvm-mirror/clang" target="_blank">github.com/llvm-mirror</a>. You can either clone the repo or fork it.

Since I intent to modify the source code, I located the cloned folder in my preferred location for programming projects (lets say it is at `$HOME/Dev/clang_dev`).

### Adding script to compile the project using cmake and ninja

I created a simple bash script that runs cmake to prepare for compilation and runs ninja for compiling the files. You need to replace `$PATH_TO_INSTALL` with the location of your choice.

    #!/bin/bash
    if [ -z "$1" ]; then
        echo "USAGE: compile.sh <phase> <dry_run>. It can be cmake, ninja_build, ninja_install"
        exit -1
    fi
    phase=$1
    dry_run=""
    TARGET_SRC=$PWD
    TARGET_BUILD=$TARGET_SRC/../clang_dev_build
    TARGET_INSTALL=$PATH_TO_INSTALL
    if [ "$#" -ge "2" ]; then
        dry_run="-n"
    fi
    mkdir $TARGET_BUILD
    echo Changing folders to $TARGET_BUILD...
    cd $TARGET_BUILD
    echo We\'re at $PWD
    if [ "$phase" == "cmake" ]; then
      cmake $TARGET_SRC -G "Eclipse CDT4 - Ninja" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=$TARGET_INSTALL 
    fi
    if [ "$phase" == "ninja_build" ]; then
      ninja $dry_run
    fi
    if [ "$phase" == "ninja_install" ]; then
      ninja install $dry_run -v
    fi

## Tested with...

* OSX 10.11.6
* Compiled with LLVM version 3.9.0 compiled from source code.
* cmake 3.6.2
* ninja 1.7.1
