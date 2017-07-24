---
layout: page
title: Blog
excerpt: "An archive of blog posts sorted by date."
search_omit: true
---

<h1 class="page-heading">Posts</h1>

<ul class="post-list">
  {% for post in site.posts %}
    <li>
      {% assign date_format = site.minima.date_format | default: "%b %-d, %Y" %}
      <span class="post-meta">{{ post.date | date: date_format }}</span>
      <h2>
        <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title }}</a>
      </h2>
    </li>
  {% endfor %}
</ul>

<nav class="navbar navbar-default navbar-fixed-bottom">
  <div class="container">
    ...
  </div>
</nav>

<ul class="nav nav-pills">
  <li role="presentation" class="active"><a href="#">Home</a></li>
  <li role="presentation"><a href="#">Profile</a></li>
  <li role="presentation"><a href="#">Messages</a></li>
</ul>
