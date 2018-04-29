---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

<section class="post-list">
  {% for post in site.posts limit:3 %}
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
      <div class="panel panel-default thumbnail well well-sm">
        <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">
        <div class="panel-heading">
          <h3 class="panel-title">
            <span class="post-meta date-label">{{ post.date | date: "%b %d" }}</span>
            <div class="article-title">{{ post.title }}</div>
          </h3>
        </div>
        </a>
        <div class="panel-body well well-sm">
          {{ post.content }}
        </div>
      </div>
    </article>
  {% endfor %}
</section>
<p class="text-center">
  <a class="btn btn-default" href="{{ site.url }}/blog" role="button">View more posts...</a>
</p>