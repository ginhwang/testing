
------------------dwh_clients
--SMOKE
--metadata
-- ER - all specififed columns in the table
SELECT table_name, column_name, is_nullable, data_type, character_maximum_length 
FROM information_schema."columns" c 
WHERE table_name = 'dwh_clients';

--check for keys
--ER - primary key on cliend_id and  PRIMARY KEY in constraint_type
SELECT constraint_name, table_name, constraint_type 
FROM information_schema.table_constraints
WHERE table_name = 'dwh_clients'

--count to check that the table is not empty
-- ER - number > 0
SELECT count(client_id)
FROM dwh_clients;



--CRITICAL
--duplicates
--ER - nothing
SELECT client_src_id, first_name, middle_name, last_name, email, phone_numbers, valid_from, valid_to, is_valid, first_purchase
FROM dwh_clients
GROUP BY client_src_id, first_name, middle_name, last_name, email, phone_numbers, valid_from, valid_to, is_valid, first_purchase
HAVING count (*) > 1
;

--check that every ID is in both sources (row by row)
--check for inconsistencies in dwh_clients compared to lnd
--ER - nothing
SELECT client_src_id
FROM dwh_clients
EXCEPT
SELECT client_id FROM 
(SELECT client_id
FROM lnd_s1_clients
UNION all
SELECT client_id
FROM lnd_s2_clients) AS uni;

--check for inconsistencies in lnd compared to dwh_cliendts
--ER - nothing
SELECT client_id FROM 
(SELECT client_id
FROM lnd_s1_clients
UNION ALL 
SELECT client_id
FROM lnd_s2_clients) AS uni
except
SELECT client_src_id
FROM dwh_clients;

--business rules (inner join because we-ve already checked exceptions)
--rule for phone numbers in s2
--ER - nothing
SELECT 	dwh_clients.client_id, 
		dwh_clients.phone_number, 
		lnd_s2_clients.phone_code,
		lnd_s2_clients.phone_number
FROM dwh_clients
JOIN lnd_s2_clients
ON dwh_clients.cliend_src_id = lnd_s2_clients.client_id
WHERE dwh_clients.phone_number != lnd_s2_clients.phone_code || lnd_s2_clients.phone_number

--rule for is_valid 
--ER - nothing
SELECT client_id, valid_to, is_valid
FROM dwh_clients
WHERE is_valid NOT IN ('N', 'Y') 
UNION ALL 
SELECT client_id, valid_to, is_valid
FROM dwh_clients
WHERE is_valid != 'Y' AND valid_to > '2021-01-20'::date

--rule for valid_to and valid_from
--ER - nothing
SELECT client_id, 
FROM dwh_clients
WHERE valid_to < '2000-01-01'::date OR valid_from > '2100-01-01'::date OR valid_from =< valid_to;

--EXTENDED 
--check middle name
SELECT 	dwh_clients.client_id, 
		lnd_s2_clients.client_id AS s2_client_src_id
		dwh_clients.middle_name
FROM dwh_clients
JOIN lnd_s2_clients
ON dwh_clients.cliend_src_id = lnd_s2_clients.client_id
WHERE dwh_clients.middle_name != 'N/A'



------------------dwh_channels
--SMOKE
--metadata
SELECT table_name, column_name, is_nullable, data_type, character_maximum_length 
FROM information_schema."columns" c 
WHERE table_name = 'dwh_channels';

--check for keys
--ER - primary key on channel_id and  PRIMARY KEY in constraint_type and location_id with FOREIGN KEY in constraint_type
SELECT constraint_name, table_name, constraint_type 
FROM information_schema.table_constraints
WHERE table_name = 'dwh_channels'

--count to check that the table is not empty
-- ER - number > 0
SELECT count(channel_id)
FROM dwh_channels;



--CRITICAL
--duplicates
--ER - nothing
SELECT channel_src_id, channel_name, location_id
FROM dwh_channels
GROUP BY channel_src_id, channel_name, location_id
HAVING count (*) > 1
;

--check that every ID is in both sources (row by row)
--check for inconsistencies in dwh_channels compared to lnd
--ER - nothing
SELECT channel_src_id
FROM dwh_channels
EXCEPT
SELECT channel_id FROM 
(SELECT channel_id
FROM lnd_s1_channels
UNION all
SELECT channel_id
FROM lnd_s2_channels) AS uni;

--check for inconsistencies in lnd compared to dwh_channels
--ER - nothing
SELECT channel_id FROM 
(SELECT channel_id
FROM lnd_s1_channels
UNION ALL 
SELECT channel_id
FROM lnd_s2_channels) AS uni
except
SELECT channel_src_id
FROM dwh_channels;

--check referencial integrity with dwh_locations
--ER - nothing
SELECT dwh_channels.channel_id
FROM dwh_channels
LEFT JOIN dwh_locations
ON dwh_channels.location_id = dwh_locations.location_id
WHERE dwh_channels.location_id != dwh_locations.location_id


------------------dwh_products
--SMOKE
--metadata
SELECT table_name, column_name, is_nullable, data_type, character_maximum_length 
FROM information_schema."columns" c 
WHERE table_name = 'dwh_products';

--check for keys
--ER - primary key on product_id and  PRIMARY KEY in constraint_type 
SELECT constraint_name, table_name, constraint_type 
FROM information_schema.table_constraints
WHERE table_name = 'dwh_products'

--count to check that the table is not empty
-- ER - number > 0
SELECT count(product_id)
FROM dwh_products;



--CRITICAL
--duplicates
--ER - nothing
SELECT product_src_id, product_name, product_cost
FROM dwh_products
GROUP BY product_src_id, product_name, product_cost
HAVING count (*) > 1
;

--check that every ID is in both sources (row by row)
--check for inconsistencies in dwh_products compared to lnd
--ER - nothing
SELECT product_src_id
FROM dwh_products
EXCEPT
SELECT product_id FROM 
(SELECT product_id
FROM lnd_s1_products
UNION all
SELECT DISTINCT product_id
FROM lnd_s2_client_sales) AS uni;

--check for inconsistencies in lnd compared to dwh_products
--ER - nothing
SELECT product_id FROM 
(SELECT product_id
FROM lnd_s1_products
UNION all
SELECT DISTINCT product_id
FROM lnd_s2_client_sales) AS uni
except
SELECT product_src_id
FROM dwh_products;

------------------dwh_locations

--SMOKE
--metadata
SELECT table_name, column_name, is_nullable, data_type, character_maximum_length 
FROM information_schema."columns" c 
WHERE table_name = 'dwh_locations';

--check for keys
--ER - primary key on location_id and  PRIMARY KEY in constraint_type
SELECT constraint_name, table_name, constraint_type 
FROM information_schema.table_constraints
WHERE table_name = 'dwh_locations'

--count to check that the table is not empty
-- ER - number > 0
SELECT count(location_id)
FROM dwh_locations;



--CRITICAL
--duplicates
--ER - nothing
SELECT location_src_id, location_name
FROM dwh_locations
GROUP BY  location_src_id, location_name
HAVING count (*) > 1
;

--check that every ID is in both sources (row by row)
--check for inconsistencies in dwh_locations compared to lnd
--ER - nothing
SELECT location_src_id, location_name
FROM dwh_locations
EXCEPT
SELECT product_id FROM 
(SELECT DISTINCT  'N/A', channel_location
FROM lnd_s1_channels
UNION all
SELECT DISTINCT location_id, location_name
FROM lnd_s2_locations) AS uni;

--check for inconsistencies in lnd compared to dwh_products
--ER - nothing
SELECT * FROM 
(SELECT DISTINCT  'N/A', channel_location
FROM lnd_s1_channels
UNION all
SELECT DISTINCT location_id, location_name
FROM lnd_s2_locations) AS uni;
except
SELECT location_src_id, location_name
FROM dwh_locations;



------------------dwh_sales

--SMOKE
--metadata
SELECT table_name, column_name, is_nullable, data_type, character_maximum_length 
FROM information_schema."columns" c 
WHERE table_name = 'dwh_sales';

--check for keys
--ER - primary key on sale_id and  PRIMARY KEY in constraint_type
SELECT constraint_name, table_name, constraint_type 
FROM information_schema.table_constraints
WHERE table_name = 'dwh_sales'

--count to check that the table is not empty
-- ER - number > 0
SELECT count(sale_is)
FROM dwh_sales;



--CRITICAL
--duplicates
--ER - nothing
SELECT client_id, channel_id, product_id, order_created_order_completed, quantity
FROM dwh_sales
GROUP BY client_id, channel_id, product_id, order_created_order_completed, quantity
HAVING count (*) > 1
;

--check referencial integrity
--ER - nothing
SELECT dwh_sales.sale_id, dwh_clients.client_id , dwh_channels.channel_id, dwh_products.product_id
FROM dwh_sales
LEFT JOIN dwh_clients
ON dwh_sales.client_id = dwh_clients.client_id
LEFT JOIN dwh_channels
ON dwh_sales.channel_id = dwh_channels.channel_id
LEFT JOIN dwh_products
ON dwh_sales.product_id = dwh_products.product_id
WHERE dwh_sales.client_id != dwh_clients.client_id 
OR dwh_sales.channel_id != dwh_channels.channel_id
OR dwh_sales.product_id != dwh_products.product_id

--EXTENDED
--check validity of dates
--ER - nothing
SELECT sale_id, order_created, order_completed
FROM dwh_sales
WHERE order_completed < order_created;


