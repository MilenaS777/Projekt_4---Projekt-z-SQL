--
-- Pomocný krok - zjištění společného období pro tabulky czechia_price a czechia_payroll:
SELECT * FROM czechia_price ORDER BY date_from;
SELECT * FROM czechia_payroll ORDER BY payroll_year;	
-- Tabulky cen potravin a průměrných mezd se prolínají v letech 2006 - 2018

-- Tabulka 1:
 
CREATE TABLE t_milena_sedlarova_project_SQL_primary_final AS 
SELECT 
	cpc.name AS food_category,
	cpc.price_value,
	cpc.price_unit,
	cp.value AS price,
	cp.date_from,
	cpay.payroll_year AS `year`,
    cpay.payroll_quarter,
	cpay.value AS avg_wages,
	cpib.name AS industry_branch
FROM czechia_price cp
JOIN czechia_payroll cpay 
	ON YEAR(cp.date_from) = cpay.payroll_year
	AND cpay.value_type_code = 5958
	AND cpay.calculation_code = 200
	AND cp.region_code IS NULL
JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code 
JOIN czechia_payroll_industry_branch cpib 
	ON cpay.industry_branch_code = cpib.code
    AND cpay.industry_branch_code IS NOT NULL
ORDER BY cpc.name, cp.date_from;

SELECT * FROM t_milena_sedlarova_project_sql_primary_final
ORDER BY date_from, food_category;

-- Tab.2:
CREATE OR REPLACE TABLE t_milena_sedlarova_project_sql_secondary_final AS
SELECT
	c.country,
	e.`year`,
	c.population,
	e.GDP,
	e.gini 
FROM countries c
JOIN economies e ON e.country = c.country 
WHERE e.`year` BETWEEN 2006 AND 2018
	AND c.continent = 'Europe'
GROUP BY e.`year`, c.country;

SELECT * FROM t_milena_sedlarova_project_sql_secondary_final 


/* otázka 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

 Q1 - průměrné mzdy r.2006-2018 pro jednotlivá odvětví s vyznačením nárůstu mezd (sloupec is_rising = 'Yes'), 
poklesu nebo stagnace mezd ('No'), hodnota 0 - nebyla předchozí hodnota pro porovnání
*/
CREATE OR REPLACE TEMPORARY TABLE t_t_czechia_payroll AS
SELECT
	cpay.payroll_year AS 'year',
	cpib.name AS 'industry_branch',
	round(avg(cpay.value)) AS 'avg_payroll_value' 
FROM czechia_payroll cpay
JOIN czechia_payroll_industry_branch cpib
    ON cpay.industry_branch_code = cpib.code
WHERE cpay.value_type_code = 5958 AND cpay.calculation_code = 200 AND cpay.payroll_year BETWEEN 2006 AND 2018
	AND cpay.industry_branch_code IS NOT NULL
GROUP BY cpib.name, cpay.payroll_year
ORDER BY cpib.name, cpay.payroll_year

-- úplná tabulka s přehledem vývoje mezd v r.2006-2018:
SELECT 
	`year`,
	industry_branch,
	avg_payroll_value,
	LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) AS previous_payroll,
	CASE 
		WHEN LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) < avg_payroll_value THEN 'Yes'-- mzda stoupá oproti minulému roku
		WHEN LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) >= avg_payroll_value THEN 'No'-- mzda klesá nebo je stejná jako minulý rok
		ELSE 0
	END is_rising
FROM t_t_czechia_payroll
GROUP BY industry_branch, `year`;

-- výpis hodnot pro odvětví, kde mzdy nerostou:
WITH q1_answer AS (
SELECT 
	`year`,
	industry_branch,
	avg_payroll_value,
	LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) AS previous_payroll,
	CASE 
		WHEN LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) < avg_payroll_value THEN 'Yes'-- mzda stoupá oproti minulému roku
		WHEN LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) >= avg_payroll_value THEN 'No'-- mzda klesá nebo je stejná jako minulý rok
		ELSE 0
	END is_rising
FROM t_t_czechia_payroll
GROUP BY industry_branch, `year`
)
SELECT * FROM q1_answer
WHERE previous_payroll IS NOT NULL AND is_rising = 'No'
ORDER BY `year`;


-- otázka 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

SELECT
food_category, price_unit, 
ROUND(AVG(price),2) AS avg_food_price,
ROUND(AVG (cpay_value),0) AS avg_wages,
ROUND(AVG (cpay_value)/AVG (price),0) AS amount_to_buy,
`year`
FROM t_milena_sedlarova_project_sql_primary_final
WHERE food_category IN ('Chléb konzumní kmínový','Mléko polotučné pasterované') 
	  AND `year` IN ('2006','2018')
GROUP BY `year`,
		 food_category
ORDER BY date_from, food_category;

-- otázka 3: - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- vytvořím si pomocnou dočasnou tabulku
CREATE OR REPLACE TEMPORARY TABLE t_t_food_category_price AS
SELECT
	YEAR(cp.date_from) AS 'year', 
	cpc.name AS food_category,
	round(AVG(cp.value),2) AS 'avg_price_value', 
	cpc.price_unit 
FROM czechia_price cp
JOIN czechia_price_category cpc
	ON cp.category_code = cpc.code
GROUP BY YEAR(cp.date_from), name; 

-- pomocí funkce LAG zjišťuji cenu předchozí a porovnávám se současnou cenou, doplním o procentuální nárůst (pokles) a zjistím průměrnou roční cenu potravin
WITH q3 AS (
SELECT
		`year`,
		food_category,
		lag(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`) AS previous_price,
		(avg_price_value - lag(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`))/lag(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`)*100 AS perc_difference
FROM t_t_food_category_price
GROUP BY food_category, `year`
)	
SELECT 
	food_category,
	round(avg(perc_difference),2) AS avg_perc_difference
FROM q3
WHERE 1=1
GROUP BY food_category
ORDER BY avg_perc_difference ASC;

/* Otázka 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

 Vycházím z dotazu pro ot. č.1 - průměrné platy, doplním o procentuální nárůst a zjistím průměrnou roční hodnotu a z upraveného
 dotazu z ot.3 pro průměrný nárůst (pokles) cen v letech 2006-2018. Dotazy propojím a setřídím podle nejvyššího rozdílu meziročního nárůstu cen/mezd.
 použiji dříve vytvořené dočasné tabulky t_t_food_category_price a t_t_czechia_payroll
*/

WITH q4_price AS (
SELECT 
	`year`,
	food_category,
	avg_price_value,
	LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`) AS previous_price,
	(avg_price_value - LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`))/LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`)*100 AS perc_difference
FROM t_t_food_category_price
WHERE 1=1
),
q4_avg_price_increase AS (
SELECT `year`, round(avg(perc_difference), 2) AS avg_price_increase
FROM q4_price
GROUP BY `year`
),
q4_pay AS (
SELECT 
	`year`,
	industry_branch,
	avg_payroll_value,
	LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) AS previous_payroll,
	round(((avg_payroll_value - LAG(avg_payroll_value, 1) OVER (PARTITION BY industry_branch ORDER BY `year` ASC))/ LAG(avg_payroll_value, 1) OVER (PARTITION BY industry_branch ORDER BY `year` ASC)) * 100, 2) AS perc_diff_pay
	FROM t_t_czechia_payroll
GROUP BY industry_branch, `year`
),
q4_avg_pay_increase AS (
SELECT 
	`year`,
	round(avg(perc_diff_pay),2) AS avg_pay_increase
FROM q4_pay
WHERE 1=1
GROUP BY `year`
)
SELECT 
	qpri.`year`,
	qpay.avg_pay_increase,
	qpri.avg_price_increase,
	abs(qpay.avg_pay_increase - qpri.avg_price_increase) AS difference
FROM q4_avg_pay_increase qpay
JOIN q4_avg_price_increase qpri ON qpri.`year` = qpay.`year`
ORDER BY difference DESC;


/* Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Využiji dotazů z otázky 4 a propojím s tabulkou t_milena_sedlarova_project_sql_secondary_final.
*/
WITH q5_gdp AS (
SELECT
	`year`,
	country,
	GDP,
	LAG(GDP) OVER (ORDER BY `year` ASC) AS gdp_previous_year,
	round(((GDP - LAG(GDP) OVER (ORDER BY `year`))/ LAG(GDP) OVER (ORDER BY `year` ASC)) * 100, 2) AS gdp_increase
FROM t_milena_sedlarova_project_sql_secondary_final 
WHERE country = 'Czech Republic'
),
q4_price AS (
SELECT 
	`year`,
	food_category,
	avg_price_value,
	LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`) AS previous_price,
	(avg_price_value - LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`))/LAG(avg_price_value) OVER (PARTITION BY food_category ORDER BY `year`)*100 AS perc_difference
FROM t_t_food_category_price
WHERE 1=1
),
q4_avg_price_increase AS (
SELECT `year`, round(avg(perc_difference), 2) AS avg_price_increase
FROM q4_price
GROUP BY `year`
),
q4_pay AS (
SELECT 
	`year`,
	industry_branch,
	avg_payroll_value,
	LAG(avg_payroll_value,1) OVER (PARTITION BY industry_branch ORDER BY `year`) AS previous_payroll,
	round(((avg_payroll_value - LAG(avg_payroll_value, 1) OVER (PARTITION BY industry_branch ORDER BY `year` ASC))/ LAG(avg_payroll_value, 1) OVER (PARTITION BY industry_branch ORDER BY `year` ASC)) * 100, 2) AS perc_diff_pay
	FROM t_t_czechia_payroll
GROUP BY industry_branch, `year`
),
q4_avg_pay_increase AS (
SELECT 
	`year`,
	round(avg(perc_diff_pay),2) AS avg_pay_increase
FROM q4_pay
WHERE 1=1
GROUP BY `year`
)
SELECT 
	gdp.`year`,
	gdp.gdp_increase,
	qpay.avg_pay_increase,
	qpri.avg_price_increase
	-- abs(qpay.avg_pay_increase - qpri.avg_price_increase) AS difference
FROM q5_gdp gdp
JOIN q4_avg_price_increase qpri ON qpri.`year` = gdp.`year`
JOIN q4_avg_pay_increase qpay ON qpay.`year` = gdp.`year`;
