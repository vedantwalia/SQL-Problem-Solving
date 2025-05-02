-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
    test_assignment,
    COUNT(item_id) AS items,
    SUM(view_binary_30d) AS viewed_items,
    CAST(100*SUM(view_binary_30d)/COUNT(item_id) AS FLOAT) AS viewed_percent,
    SUM(views) AS views,
    SUM(views)/COUNT(item_id) AS average_views_per_item
FROM (
    SELECT
        f.test_assignment,
        f.item_id,
        MAX(CASE WHEN item_views.event_time > f.test_start_date THEN 1 ELSE 0 END) AS view_binary_30d,
        COUNT(item_views.event_id) AS views
    FROM
        dsv1069.final_assignments f
    LEFT OUTER JOIN (
        SELECT
            event_time,
            event_id,
            CAST(parameter_value AS INT) AS item_id
        FROM
            dsv1069.events
        WHERE
            event_name = 'view_item'
            AND parameter_name = 'item_id'
    ) item_views
    ON f.item_id = item_views.item_id
    AND item_views.event_time >= f.test_start_date
    AND DATE_PART('day', item_views.event_time - f.test_start_date) <= 30
    WHERE
        f.test_number = 'item_test_2'
    GROUP BY
        f.test_assignment,
        f.item_id
) item_orders
GROUP BY
    test_assignment;
  
--| test_assignment | items | viewed_items | viewed_percent | views | average_views_per_item |
--|-----------------|-------|--------------|----------------|--------|-------------------------|
--| 0               | 1130  | 918          | 81             | 1916   | 1.70                    |
--| 1               | 1068  | 890          | 83             | 1862   | 1.74                    |