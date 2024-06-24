# Projekt_4---Projekt-z-SQL
 
## Zadání Projektu:
Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli,
že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. 
Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. 
Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.
Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin
na základě průměrných příjmů za určité časové období.
Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací
dalších evropských států ve stejném období, jako primární přehled pro ČR.

## Datové sady, které je možné použít pro získání vhodného datového podkladu:

### Primární tabulky:

_czechia_payroll_ – Informace o mzdách v různých odvětvích za několikaleté období.  Datová sada pochází z Portálu otevřených dat ČR.
_czechia_payroll_calculation_ – Číselník kalkulací v tabulce mezd.
_czechia_payroll_industry_branch_ – Číselník odvětví v tabulce mezd.  
_czechia_payroll_unit_ – Číselník jednotek hodnot v tabulce mezd.  
_czechia_payroll_value_type_ – Číselník typů hodnot v tabulce mezd.   
_czechia_price_ – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.   
_czechia_price_category_ – Číselník kategorií potravin, které se vyskytují v našem přehledu.

### Číselníky sdílených informací o ČR:

_czechia_region_ – Číselník krajů České republiky dle normy CZ-NUTS 2.     
_czechia_district_ – Číselník okresů České republiky dle normy LAU.

### Dodatečné tabulky:

_countries_ - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.   
_economies_ - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

### Výzkumné otázky:

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
   projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?**


### Výstup projektu:

Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. 
**Tabulky pojmenujte:**
 **_t_{jmeno}_{prijmeni}_project_SQL_primary_final_**
(pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky)
 a **_t_{jmeno}_{prijmeni}_project_SQL_secondary_final_** (pro dodatečná data o dalších evropských státech).

Dále připravte sadu SQL, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. 
Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.

Na svém GitHub účtu vytvořte repozitář (může být soukromý), kam uložíte všechny informace k projektu
 – hlavně SQL skript generující výslednou tabulku, popis mezivýsledků (průvodní listinu) a informace o výstupních datech (například kde chybí hodnoty apod.).

