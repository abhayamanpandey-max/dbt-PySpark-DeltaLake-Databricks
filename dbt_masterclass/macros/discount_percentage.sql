{% macro discount_percentage(gross_amount_col, discount_amount_col) %}
    case
        when {{ gross_amount_col }} = 0 then 0
        else round(({{ discount_amount_col }} / {{ gross_amount_col }}) * 100, 2)
    end
{% endmacro %}
