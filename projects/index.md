---
layout: page
title: "Projects"
---

  <!-- Generates the projects thumbnails out of the _data/projects.yml  -->
  <div class="container-fluid">
    <div class="row">
      <!-- Iterates over projects -->
      {% for project in site.data.projects %}
      <!-- Adding thumbnail -->
      {% if project.url contains 'http' %}
        {% assign domain = '' %}
      {% else %}
        {% assign domain = site.url %}
      {% endif %}
      <a class="page-link" href="{{ domain }}{{ project.url }}" {% if project.url contains 'http' %} target="_blank"{% endif %}>
        <div class="col-md-4 col-sm-6 col-xs-12">
          <div class="panel panel-default thumbnail">
            <div class="panel-heading">{{ project.title }}</div>
            <div class="panel-body">
              <p>{{ project.description }}</p>
            </div>
          </div>
        </div>
      </a>
      {% endfor %}
    </div>
  </div>
