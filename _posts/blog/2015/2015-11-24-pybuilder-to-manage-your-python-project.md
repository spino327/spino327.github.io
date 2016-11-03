---
layout: post
title: "PyBuilder to Manage Your Python Project"
modified:
categories: blog
excerpt: "how to use PyBuilder with a python project"
tags: [python, software development]
image:
  feature:
date: 2015-11-24T10:01:45-05:00
---

In java it is common to use build systems such as maven. I wanted to explore an similar utility for python 2.x.

PyBuilder is a software build tool that is based on the concept of dependency based programming [^1].

* Table of Contents
{:toc}

## Getting ready

We'll use PyBuilder in a virtual environment. This will allow us to install any specific version of a dependency library without interfering with the user environment.

Create a folder for your project. In my case is lldecaf.

{% highlight bash %}
$ cd lldecaf
$ virtualenv venv
$ source venv/bin/activate
$ pip install pybuilder
{% endhighlight %}

## How to...




Similar to maven you can start by providing a directory structure to your project. I'm working on a toy compiler so my project's directory looks like:

{% highlight bash %}

lldecaf/
|
+--README.md
+--setup.py
+--frontend
    |
    +--__init__.py
+--backend
    |
    +--__init__.py

{% endhighlight %}

Notice that we'll place all our python module in the folders *frontend* and *backend*, and that the *Distutils* script is **setup.py**.  

### setup.py

The *setup.py* can be seen as a normal python module that has as first line:

{% highlight python %}
from distutils.core import setup
{% endhighlight %}

A simple setup.py for my project can be:

{% highlight python %}
from distutils.core import setup

setup(
    name = "lldecaf",
    packages = ["frontend", "backend"],
    version = "0.1.0",
    description = "...",
    author = "Some Guy",
    author_email = "some@mail.com",
    url = "..."
    )
{% endhighlight %}

You can run *setup.py* as an usual python program. If you want to check what standard commands you can invoke by `python setup.py <cmd>`, then run `python setup.py --help-commands`. For instance, some of the possible commands are:

* build: build everything needed to install
* clean: clean up temporary files from 'build' command
* install: install everything from build directory
* sdist: create a source distribution (tarball, zip file, etc.)
* bdist: create a built (binary) distribution
* check: perform some checks on the package

### adding dependencies


### Adding resources

You can use the `copy_resources` plugin to include non-source files in a distribution. In the example, we want to include the file *README.md* and the folder *resources/samples/* * into the root folder of the distribution. Add to the *build.py* the following:

{% highlight python %}
...
# add copy_resources plugin
use_plugin("copy_resources")
...
@init
def initialize(project):
    ...
    # add properties to the project
    project.set_property("copy_resources_target", "$dir_dist")
    list_res = []
    res_path = "resources/samples/"
    list_res.append(res_path + "*.decaf")
    list_res.append(res_path + "*.out")
    list_res.append("README.md")
    project.set_property("copy_resources_glob", list_res)
{% endhighlight %}



## References
[^1]: <a target="null" href="https://docs.python.org/2/distutils/introduction.html#distutils-specific-terminology">Python documentation. Distributing Python Modules</a>
<!--[^2]: <a target="null" href="http://docs.activestate.com/activepython/3.2/diveintopython3/html/packaging.html">Dive into python 3. Chapter 16. Packaging python libraries</a>-->
