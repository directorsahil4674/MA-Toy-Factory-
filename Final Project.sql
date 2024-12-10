USE mavenfuzzyfactory;

-- GOAL: Picture high-growth and data-driven performance optimization.

-- 1. Quarterly total sessions and order volumes over 3 years
SELECT 
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    DATE(website_sessions.created_at) AS date,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    COUNT(DISTINCT orders.order_id) AS total_order_volume
FROM
    website_sessions
LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY year, quarter
ORDER BY year, quarter;

-- 2. Quarterly conversion rates showcasing efficiency improvements
SELECT 
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    DATE(website_sessions.created_at) AS date,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100 AS session_to_order_conv_rate,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM
    website_sessions
LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY year, quarter;

-- 3. Quarterly growth by channels (Gsearch, Bsearch, Brand, Organic, Direct)
SELECT 
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    DATE(website_sessions.created_at) AS date,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN orders.order_id ELSE NULL END) AS Gsearch_nonbrand,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN orders.order_id ELSE NULL END) AS Bsearch_nonbrand,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_campaign = 'brand'
        THEN orders.order_id ELSE NULL END) AS brand_search,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL
        THEN orders.order_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE
        WHEN utm_source IS NULL AND http_referer IS NULL
        THEN orders.order_id ELSE NULL END) AS direct_type_in
FROM
    website_sessions
LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY year, quarter;

-- 4. Quarterly session-to-order conversion rates by channel
SELECT 
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    DATE(website_sessions.created_at) AS date,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN website_sessions.website_session_id ELSE NULL END) * 100 AS Gsearch_nonbrand_conv_rate,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand'
        THEN website_sessions.website_session_id ELSE NULL END) * 100 AS Bsearch_nonbrand_conv_rate,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_campaign = 'brand'
        THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_campaign = 'brand'
        THEN website_sessions.website_session_id ELSE NULL END) * 100 AS brand_search_conv_rate,
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL
        THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE
        WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL
        THEN website_sessions.website_session_id ELSE NULL END) * 100 AS organic_search_conv_rate,
    COUNT(DISTINCT CASE
        WHEN utm_source IS NULL AND http_referer IS NULL
        THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE
        WHEN utm_source IS NULL AND http_referer IS NULL
        THEN website_sessions.website_session_id ELSE NULL END) * 100 AS direct_type_in_conv_rate
FROM
    website_sessions
LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY year, quarter
ORDER BY year, quarter;

-- 5. Product revenue and margins by month
SELECT 
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    DATE(created_at) AS date,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd ELSE 0 END) AS mr_fuzzy_rev,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd - cogs_usd ELSE 0 END) AS mr_fuzzy_marg,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd ELSE 0 END) AS loverbear_rev,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd - cogs_usd ELSE 0 END) AS loverbear_marg,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd ELSE 0 END) AS birthdaybear_rev,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd - cogs_usd ELSE 0 END) AS birthdaybear_marg,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd ELSE 0 END) AS minibear_rev,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd - cogs_usd ELSE 0 END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    orders
GROUP BY year, month
ORDER BY year, month;

-- 6. Product-to-order funnel analysis
CREATE TEMPORARY TABLE product_pages AS
SELECT 
    website_pageview_id AS pageviews, 
    website_session_id AS sessions, 
    created_at AS saw_product_page_at
FROM
    website_pageviews
WHERE
    pageview_url = '/products'
GROUP BY pageviews, sessions;

SELECT 
    YEAR(saw_product_page_at) AS year,
    MONTH(saw_product_page_at) AS month,
    DATE(saw_product_page_at) AS date,
    COUNT(DISTINCT product_pages.sessions) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT product_pages.sessions) AS clickthrough_rate,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT product_pages.sessions) * 100 AS products_to_order_rate
FROM
    product_pages
LEFT JOIN 
    website_pageviews ON website_pageviews.website_session_id = product_pages.sessions 
    AND website_pageviews.website_pageview_id > product_pages.pageviews
LEFT JOIN 
    orders ON orders.website_session_id = product_pages.sessions
GROUP BY year, month;

-- 7. Cross-selling behavior of products
CREATE TEMPORARY TABLE primary_products AS
SELECT 
    order_id, primary_product_id, created_at AS ordered_at
FROM
    orders
WHERE
    created_at > '2014-12-05';

SELECT 
    primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS xsold_p4
FROM
    (SELECT 
        primary_products.*,
        order_items.product_id AS cross_sell_product_id
    FROM
        primary_products
    LEFT JOIN 
        order_items ON primary_products.order_id = order_items.order_id
        AND order_items.is_primary_item = 0) AS primary_w_cross_sell
GROUP BY primary_product_id;


SELECT MIN(created_at), MAX(created_at) FROM website_sessions; 