---
layout: post
title: Virtualenv
modified:
categories: blog
excerpt: "Using virtualenv to isolate python projects"
tags: [python]
image:
  feature:
date: 2015-11-25T22:20:39-05:00
---

Virtualenv allows you to isolate a python environment for your python project [^1]. This is useful in when several of your projects depend on different versions of the same library, which triggers a problem if you have a system/user wide installation of the particular library. Thus, by isolating the python environment you can install the required version of the library without worrying about whether or not you will break another project.

## How to...

You can install *virtualenv* using pip by `[sudo] pip install virtualenv`.

Then, for the basic usage you'll need to do two steps

1. `$ virtualenv ENV_PATH`, where *ENV_PATH* is a directory where the new virtual environment will be placed. The new environment will have *pip* and *setuptools* installed.
2. You will need to source your new environment by `$ source ENV_PATH/bin/activate`

Example:
{% highlight bash %}
$ virtualenv venv
$ source venv/bin/activate
{% endhighlight %}

### tested with
* OS X 10.11.1
* Python 2.7.10
* pip 7.1.2
* virtualenv 13.1.2

## References
[^1]: <a target="null" href="http://virtualenv.readthedocs.org/en/latest/userguide.html">Virtualenv docs</a>

