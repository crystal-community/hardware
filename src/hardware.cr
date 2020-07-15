require "./*"
{% if flag?(:win32) %}
  require "./win32/*"
{% else %}
  require "./unix/*"
{% end %}

module Hardware
end
