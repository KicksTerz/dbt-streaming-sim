{#
  Override dbt's default schema naming so a model/seed with +schema: X
  lands in exactly schema X (not target_schema_X). This lets our seeds go
  into STREAMIFY_RAW.PUBLIC so sources.yml resolves cleanly.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
