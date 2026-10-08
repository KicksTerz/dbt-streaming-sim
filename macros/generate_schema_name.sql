{#
  Use a custom schema name as-is instead of dbt's default <target_schema>_<custom>,
  so seeds land in STREAMIFY_RAW.PUBLIC, where sources.yml expects them.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
