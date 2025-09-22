-- top 5 of 50 by rating
-- create table top_five as (
-- select 
--   name, 
--   rating, 
--   review_count,
--   categories,
--   transactions,
--   price,
--   price_tier, 
--   address,
--   city, 
--   state,
--   zip_code
-- from matcha_businesses
-- order by 
--   rating desc,
--   review_count desc
-- LIMIT 5
-- );
-- select * from top_five;

/* creating table for top 5/50 */
-- create table top50_ranked as
-- with fact as (
--   select *
--   from matcha_businesses
--   where rating is not null
--   order by rating desc, review_count desc
--   LIMIT 50
-- )
-- select
--   a.*,
--   rank() over (order by rating desc, review_count desc) as rnk,
--   (rank() over (order by rating desc, review_count desc) <= 5) as is_top5
-- from fact a;

-- select * from top50_ranked;

-- create table zip_code_to_district_table as (
--     select distinct zip_code, null as district
--     from matcha_businesses
--     order by 1
-- );
-- select distinct x.zip_code, x.district from (
-- create table zip_code_to_district_table as (
-- select a.name, a.price, a.rating, b.district, a.zip_code
-- from matcha_businesses as a
-- join zip_code_to_district_dim as b 
--     on a.zip_code = b.zip_code
-- );
-- ) x
-- order by 1
-- ;

-- update matcha_business where zip_code=94102

-- create table zip_code_to_district_dim as (
--     select * from zip_code_to_district_table
-- );

-- select * from zip_code_to_district_dim;

-- select * from zip_code_to_district_table;

/* highly rated shops with low review count or over hyped ones with lower ratings */
-- average for whole city
-- select
--     a.name,
--     a.rating,
--     b.rating_avg,
--     round((a.rating-b.rating_avg)::numeric, 1) as diff,
--     c.district
-- from (
--     (select 
--         name, 
--         rating, 
--         null, 
--         1 as blah, 
--         zip_code
--     from 
--         matcha_businesses) as a
--     join 
--     (select  
--         round(avg(rating)::numeric, 1) as rating_avg, 
--         1 as blah
--     from matcha_businesses) as b
--         on a.blah = b.blah
--     left join
--     zip_code_to_district_dim as c
--         on a.zip_code = c.zip_code
-- );
-- select min(rating), max(rating), avg(rating)


-- average based on district
-- create table business_rating_vs_district_stats_table as (

    
--     with cte as (
--         select 
--             fact.name, 
--             fact.rating, 
--             fact.district, 
--             avg.rating_avg,
--             round((fact.rating-avg.rating_avg)::numeric, 1) as rating_diff
--         from (
--             select 
--                 a.name, 
--                 a.rating,
--                 b.district
--             from 
--                 matcha_businesses a
--                 join zip_code_to_district_dim b
--                     on a.zip_code = b.zip_code
--         ) as fact
--         join (
--             select 
--                 y.district,
--                 round(avg(z.rating)::numeric,1) as rating_avg
--             from 
--                 matcha_businesses z
--                 join zip_code_to_district_dim y
--                     on z.zip_code = y.zip_code
--             group by y.district
--         ) as avg
--             on fact.district = avg.district
--     )
--     select 
--         cte.name, 
--         cte.rating, 
--         cte.district, 
--         cte.rating_avg,
--         cte.rating_diff,
--         case 
--             when rating_diff = 0 then 'On Average'
--             when rating_diff > 0 then 'Above Average'
--             else 'Below Average'
--         end as rating_phrase
--     from cte
-- );

-- select * from business_rating_vs_district_avg_table;


/* ============================================================
   SECTION I — Box & Whisker stats by District (min/q1/median/q3/max/avg)
   ============================================================ */

-- Creates a fresh table with five-number summary + average per district
-- Source: matcha_businesses + zip_code_to_district_dim (via ZIP join)
-- Rounds to 1 decimal to match your other outputs

-- CREATE TABLE district_rating_five_number_summary_table AS (
--   WITH fact AS (
--     SELECT
--       z.district,
--       (a.rating)::numeric AS rating
--     FROM matcha_businesses a
--     JOIN zip_code_to_district_dim z
--       ON a.zip_code = z.zip_code
--     WHERE a.rating IS NOT NULL
--   ),
--   pct AS (
--     SELECT
--       district,
--       COUNT(*) AS n,
--       MIN(rating) AS min_rating,
--       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY rating) AS q1,
--       PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY rating) AS median_rating,
--       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY rating) AS q3,
--       MAX(rating) AS max_rating,
--       AVG(rating) AS avg_rating
--     FROM fact
--     GROUP BY district
--   )
--   SELECT
--     district,
--     n,
--     ROUND(min_rating::numeric, 1)     AS min_rating,
--     ROUND(q1::numeric, 1)             AS q1,
--     ROUND(median_rating::numeric, 1)  AS median_rating,
--     ROUND(q3::numeric, 1)             AS q3,
--     ROUND(max_rating::numeric, 1)     AS max_rating,
--     ROUND(avg_rating::numeric, 1)     AS avg_rating
--   FROM pct
--   ORDER BY district
-- );

-- -- Quick check
-- SELECT * FROM district_rating_five_number_summary_table ORDER BY median_rating DESC;

