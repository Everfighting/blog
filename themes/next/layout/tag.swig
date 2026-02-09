{% extends '_layout.swig' %}
{% import '_macro/post-collapse.swig' as post_template %}
{% import '_macro/sidebar.swig' as sidebar_template %}

{% block title %}
  {% if page.tag %}
    {{ __('title.tag') }}: {{ page.tag }} | {{ config.title }}
  {% else %}
    {{ __('title.tags') }} | {{ config.title }}
  {% endif %}
{% endblock %}

{% block content %}
  <div class="post-block tag">
    {% if not page.tag %}
      {###########################}
      {### TAGS CLOUD BLOCK ###}
      {###########################}
      <div class="tags-cloud">
        <div class="collection-title">
          <h2 class="collection-header">
            <i class="fa fa-tags fa-fw"></i> {{ __('title.tags') }}
            <small class="pull-right">{{ site.tags.length }} {{ __('title.tag') }}</small>
          </h2>
        </div>
        {% if site.tags.length > 0 %}
          <div class="tag-cloud-tags">
            {% set tags = site.tags.sort('name') %}
            {% for tag in tags %}
              <a href="{{ url_for(tag.path) }}" class="tag-cloud-tag">
                {{ tag.name }}
                <span class="tag-count">{{ tag.posts.length }}</span>
              </a>
            {% endfor %}
          </div>
        {% else %}
          <div class="no-tags">{{ __('state.no_tags') }}</div>
        {% endif %}
      </div>
    {% else %}
      {###########################}
      {### TAG POSTS BLOCK ###}
      {###########################}
      <div class="tag-posts">
        <div class="collection-title">
          <h2 class="collection-header">
            <i class="fa fa-tag fa-fw"></i> {{ __('title.tag') }}: {{ page.tag }}
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
