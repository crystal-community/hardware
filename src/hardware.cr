require "./*"
{% if flag?(:win32) %}
  require "./unix/*"
{% else %}
  require "./win32/*"
{% end %}

module Hardware
end
