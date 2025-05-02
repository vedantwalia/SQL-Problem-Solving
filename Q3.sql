-- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2
SELECT
  test_assignment,
  COUNT(item_id) AS items,
  SUM(order_binary_30d) AS items_ordered_30d
FROM
  (
    SELECT
      f.test_assignment,
      f.item_id,
      MAX(
        CASE
          WHEN o.created_at > f.test_start_date THEN 1
          ELSE 0
        END
      ) AS order_binary_30d
    FROM
      dsv1069.final_assignments f
      LEFT OUTER JOIN dsv1069.orders o ON f.item_id = o.item_id
      AND o.created_at >= f.test_start_date
      AND date_part('day', o.created_at - f.test_start_date) <= 30
    WHERE
      f.test_number = 'item_test_2'
    GROUP BY
      f.test_assignment,
      f.item_id
  ) item_orders
GROUP BY
  test_assignment
  
  --| test_assignment | num_orders | sum_orders_bin_30d |
  --|------------------|-------------|----------------------|
  --| 0                | 1130        | 331                  |
  --| 1                | 1068        | 319                  |