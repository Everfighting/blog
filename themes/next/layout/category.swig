{% extends '_layout.swig' %}
{% import '_macro/post-collapse.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}
  {% if page.category %}
    {{ __('title.category') }}: {{ page.category }} | {{ config.title }}
  {% else %}
    {{ __('title.categories') }} | {{ config.title }}
  {% endif %}
{% endblock %}

{% block content %}
  <div class="post-block category">
    {% if not page.category %}
      {##############################}
      {### CATEGORIES LIST BLOCK ###}
      {##############################}
      <div class="categories-all-page">
        <div class="collection-title">
          <h2 class="collection-header">
            <i class="fa fa-folder-open fa-fw"></i> {{ __('title.categories') }}
            <small class="pull-right">{{ site.categories.length }} {{ __('title.category') }}</small>
          </h2>
        </div>
        {% if site.categories.length > 0 %}
          <div class="categories-list">
            {% set categories = site.categories.sort('name') %}
            {% for category in categories %}
              <div class="category-item">
                <a href="{{ url_for(category.path) }}" class="category-list-link">
                  {{ category.name }}
                </a>
                <span class="category-list-count">{{ category.posts.length }}</span>
                {# 可选：显示分类下的子分类/文章数（官方标准版含此逻辑） #}
                {% if category.children.length > 0 %}
                  <ul class="category-list-child">
                    {% for child in category.children %}
                      <li>
                        <a href="{{ url_for(child.path) }}" class="category-list-link">
                          {{ child.name }}
                        </a>
                        <span class="category-list-count">{{ child.posts.length }}</span>
                      </li>
                    {% endfor %}
                  </ul>
                {% endif %}
              </div>
            {% endfor %}
          </div>
        {% else %}
          <div class="no-categories">{{ __('state.no_categories') }}</div>
        {% endif %}
      </div>
    {% else %}
      {##############################}
      {### CATEGORY POSTS BLOCK ###}
      {##############################}
      <div class="category-posts">
        <div class="collection-title">
          <h2 class="collection-header">
            <i class="fa fa-folder fa-fw"></i> {{ __('title.category') }}: {{ page.category }}
            <small class="pull-right">{{ page.posts.length }} {{ __('title.post') }}</small>
          </h2>
        </div>
        {% if page.posts.length > 0 %}
          <div class="posts-collapse">
            {% for post in page.posts %}
              {{ post_template.render(post) }}
            {% endfor %}
          </div>
          {% include '_partials/pagination.swig' %}
        {% else %}
          <div class="no-posts">{{ __('state.no_posts') }}</div>
        {% endif %}
      </div>
    {% endif %}
  </div>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
