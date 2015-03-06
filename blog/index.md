---
layout: page
title: Blog
excerpt: "An archive of blog posts sorted by date."
image:
  feature: general/guajira.JPG
  credit: Camarones, Guajira (Colombia) by Sergio Pino
  creditlink: http://www.colombiaestuya.com
---

<ul class="post-list">
{% for post in site.categories.blog %} 
  <li><article><a href="{{ site.url }}{{ post.url }}">{{ post.title }} <span class="entry-date"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time></span></a></article></li>
{% endfor %}
</ul>
