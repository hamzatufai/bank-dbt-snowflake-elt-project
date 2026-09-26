{#
    By default, dbt builds custom schemas as "<target_schema>_<custom_schema>"
    (e.g. "DBT_SILVER"). That's usually fine, but for this learning project we
    want the layers to be named exactly SILVER and GOLD to match the
    architecture diagram. This macro override does that.

    Concept practiced: dbt macros (reusable Jinja) + overriding built-in dbt macros.
#}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
