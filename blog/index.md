---
layout: page
title: Blog
excerpt: "An archive of blog posts sorted by date."
---

<section class="post-list">
  <div class="container">
    {% for post in site.posts %}
      {% unless post.next %}
        <h2 class="category-title">{{ post.date | date: '%Y' }}</h2>
      {% else %}
        {% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
        {% capture nyear %}{{ post.next.date | date: '%Y' }}{% endcapture %}
        {% if year != nyear %}
          <h2 class="category-title">{{ post.date | date: '%Y' }}</h2>
        {% endif %}
      {% endunless %}
      <article class="post-item">
        <span class="post-meta date-label">{{ post.date | date: "%b %d" }}</span>
        <div class="article-title"><a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a></div>
        {% if post.excerpt %}
        <div><span style="margin-left:1em"><small>{{ post.excerpt | truncate: 300 }}</small></span></div>
        {% endif %}
      </article>
    {% endfor %}
  </div>

</section>
