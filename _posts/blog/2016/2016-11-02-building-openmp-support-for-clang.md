---
layout: post
title: Building OpenMP Support for Clang
modified:
categories: blog
excerpt: 
tags: [clang, llvm, openmp]
image:
  feature:
date: 2016-11-02T21:34:50-04:00
comments: true
---

In this post we'll build the OpenMP support for clang/llvm (3.9.0) from the release source code. I assume that clang/llvm is already installed as we covered in [building llvm with cmake]({% post_url 2016-02-27-building-llvm-with-cmake %}).

## How to...

The following sections use bash scripts to install the OpenMP support for clang. It should work with linux and osx.

### Download the source code distribution.
We cover this in [building llvm with cmake]({% post_url 2016-02-27-building-llvm-with-cmake %}).

### Compile OpenMP support for CLANG/LLVM with CMake and ninja

We use a bash script to compile the OpenMP source code using cmake and ninja. Ninja is similar to gnu make but it claims that it is faster on large code base projects.

{% highlight bash %}
#!/bin/bash

if [ -z "$1" ]; then
    echo "USAGE: compile.sh <phase> <dry_run>. It can be cmake, ninja_build, ninja_install"
    exit -1
fi

phase=$1
dry_run=""

TARGET_SRC=${HOME}/local/llvm-out-of-tree/openmp
TARGET_BUILD=$TARGET_SRC/runtime/build
TARGET_INSTALL=${HOME}/local/llvm-oot-install

if [ "$#" -ge "2" ]; then
    dry_run="-n"
fi

mkdir $TARGET_BUILD
echo Changing folders to $TARGET_BUILD...
cd $TARGET_BUILD
echo We\'re at $PWD

if [ "$phase" == "cmake" ]; then
	cmake $TARGET_SRC -G "Eclipse CDT4 - Ninja" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=$TARGET_INSTALL -DCMAKE_OSX_ARCHITECTURES='i386;x86_64'
fi

if [ "$phase" == "ninja_build" ]; then
	ninja $dry_run
fi

if [ "$phase" == "ninja_install" ]; then
	ninja install $dry_run -v
fi
{% endhighlight %}

## Setting up the bash environment variables to work with this installation.

To use correctly clang/llvm with the openmp libraries you'll need to export the following variables. I'm using a simple tool to source user-defined environments <a target="null" href="https://github.com/spino327/sourcing_tool">sourcing_tool</a>. The following example should work on osx.

{% highlight bash %}
VERSION=3.9.0
export LLVM_HOME=$HOME/opt/llvm
export LLVM_BUILD=$HOME/local/llvm-build
export LLVM_OOT=$HOME/opt/llvm-oot
export PATH=$LLVM_HOME/bin:$PATH
#export LLVM_LIB_SEARCH_PATH=$LLVM_HOME/lib
export C_INCLUDE_PATH=$LLVM_HOME/include:$LLVM_HOME/lib/clang/$VERSION/include:$LLVM_OOT/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$LLVM_HOME/include:$LLVM_HOME/lib/clang/$VERSION/include:$LLVM_OOT/include:$LLVM_HOME/include/c++/v1:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$LLVM_HOME/lib:$LLVM_OOT/lib:$LIBRARY_PATH
export DYLD_LIBRARY_PATH=$LLVM_HOME/lib:$LLVM_OOT/lib:$DYLD_LIBRARY_PATH
{% endhighlight %}

## Scripts

I'm hosting the scripts in github at <a target="null" href="https://github.com/spino327/llvm_clang_install">https://github.com/spino327/llvm_clang_install</a>.

## Tested with...

* OSX 10.11.6
* Compiled with Apple LLVM version 7.3.0
* cmake 3.6.2
* ninja 1.7.1
