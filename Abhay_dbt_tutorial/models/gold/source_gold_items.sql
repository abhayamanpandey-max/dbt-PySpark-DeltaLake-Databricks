with deduped_query as (
     select 
         *,
         row_number() over (partition by id order by updatedDate desc) as deduplication_id
     from {{ source('source', 'items') }}
 )
 select 
     id,
     name,
     category,
     updatedDate
 from deduped_query
 where deduplication_id = 1
 