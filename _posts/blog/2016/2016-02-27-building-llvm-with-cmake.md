---
layout: post
title: Building LLVM With Cmake
modified:
categories: blog
excerpt: ""
tags: [clang, llvm]
image:
  feature:
date: 2016-02-27T22:32:49-05:00
---

In this post we'll build clang and llvm (3.9.0) from the release source code.

## How to...

The following sections use bash scripts to download and install llvm/clang. It should work with linux and osx.

### Download the source code distribution.

The easiest way is to download the source code from the <a target="null" href="http://llvm.org/releases/download.html#3.9.0">llvm release page</a>.

The following script can be used to download, extract, and copy the llvm source code into the appropriated location. For instance, clang source code should go in `llvm/tools/clang`. You can setup the script to install other version of llvm, by replacing the value of `VERSION`. I found that llvm kind of uses a naming standard for the projects that so far has been consistent, so I based the script on that "fact" (I may not work if they change this naming convention in the future). 


{% highlight bash %}
#!/bin/bash

VERSION=3.9.0
BASE_URL=http://llvm.org/releases
POSTFIX=.src.tar.xz

echo Downloading llvm-$VERSION sources

FILES=(
llvm
cfe
clang-tools-extra
compiler-rt
openmp
libcxx
libcxxabi
)

for file in ${FILES[@]}; do
    target_file=$file-$VERSION$POSTFIX
    if [ ! -f $target_file ]; then
        curl -O $BASE_URL/$VERSION/$target_file
    else
        echo Already downloaded: $target_file
    fi
done

echo untar

for file in ${FILES[@]}; do
    target_file=$file-$VERSION$POSTFIX
    if [ ! -d "$file-$VERSION.src" ]; then
        tar -xf $target_file
    else
        echo Already extracted: $target_file
    fi
done

echo symlink
ln -vsnf ./llvm-$VERSION.src ./llvm 

echo Moving source code to llvm root tree
[ ! -d "llvm/tools/clang" ] && (mv -v cfe-$VERSION.src llvm/tools/clang)
[ ! -d "llvm/tools/clang/tools/extra" ] && (mv -v clang-tools-extra-$VERSION.src llvm/tools/clang/tools/extra)
[ ! -d "llvm/projects/compiler-rt" ] && (mv -v compiler-rt-$VERSION.src llvm/projects/compiler-rt)
[ ! -d "llvm/projects/libcxx" ] && (mv -v libcxx-$VERSION.src llvm/projects/libcxx)
[ ! -d "llvm/projects/libcxxabi" ] && (mv -v libcxxabi-$VERSION.src llvm/projects/libcxxabi)

echo creating llvm-build and llvm-install
mkdir llvm-build
mkdir llvm-install

echo creating llvm-out-of-tree and llvm-oot-install
mkdir llvm-out-of-tree
mkdir llvm-oot-install

echo Moving openmp src to oot
[ ! -d "llvm-out-of-tree/openmp" ] && (mv -v openmp-$VERSION.src llvm-out-of-tree/openmp)
{% endhighlight %}

### Compile with CMake and ninja

Similarly, we use a bash script to compile the llvm source code using cmake and ninja. Ninja is similar to gnu make but it claims that it is faster on large code base projects (as in the case of clang/llvm). Notice that we're creating an eclipse project so that you can import it for development with eclipse. You can check the available and supported CMake Generators <a target="null" href="https://cmake.org/cmake/help/v3.6/manual/cmake-generators.7.html">here</a>.

{% highlight bash %}
#!/bin/bash

if [ -z "$1" ]; then
    echo "USAGE: compile.sh <phase> <dry_run>. It can be cmake, ninja_build, ninja_install"
    exit -1
fi

phase=$1
dry_run=""

TARGET_SRC=${HOME}/local/llvm
TARGET_BUILD=$TARGET_SRC-build
TARGET_INSTALL=$TARGET_SRC-install

if [ "$#" -ge "2" ]; then
    dry_run="-n"
fi

echo Changing folders to $TARGET_BUILD...
cd $TARGET_BUILD
echo We\'re at $PWD

if [ "$phase" == "cmake" ]; then
	cmake $TARGET_SRC -G "Eclipse CDT4 - Ninja" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=$TARGET_INSTALL
fi

if [ "$phase" == "ninja_build" ]; then
	ninja $dry_run
fi

if [ "$phase" == "ninja_install" ]; then
	ninja install $dry_run -v
fi
{% endhighlight %}

## Tested with...

* OSX 10.11.6
* Compiled with Apple LLVM version 7.3.0
* cmake 3.6.2
* ninja 1.7.1