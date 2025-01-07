create database Business ; 
use Business ; 

-- Create the table for Importaning data

create table bed_type (
	bed_id	int primary Key   , 
    bed_code varchar(50) Not null, 
    bed_desc  varchar(50) 
) ; 

CREATE TABLE bed_fact (
    ims_org_id VARCHAR(50) NOT NULL,       
    bed_id INT NOT NULL,                  
    license_beds INT NOT NULL,             
    census_beds INT NOT NULL,              
    staffed_beds INT NOT NULL,            
    PRIMARY KEY (ims_org_id, bed_id)       -- Primary key composite of ims_org_id and bed_id
);

CREATE TABLE business (
    ims_org_id VARCHAR(50) NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    ttl_license_beds INT NOT NULL,
    ttl_census_beds INT NOT NULL,
    ttl_staffed_beds INT NOT NULL,
    bed_cluster_id INT NOT NULL,
    PRIMARY KEY (ims_org_id)
);

-- check that data properly inserted 
select * from bed_type ; 
select * from business ; 
select * from bed_fact ; 

-- Questions : 4a    Query Base Analysis 

/*
Q1 : Identify which hospitals have an Intensive Care Unit (ICU bed_id = 4) bed or a Surgical Intensive Care 
Unit (SICU bed_id = 15) bed or both.
*/

SELECT bed_fact.ims_org_id, Business.business_name
FROM bed_fact
JOIN business ON bed_fact.ims_org_id = Business.ims_org_id
WHERE (bed_fact.bed_id = 4  -- ICU bed
   OR bed_fact.bed_id = 15); -- SICU bed


/*
Q1 - A :  License beds: List of Top 10 Hospitals ordered descending by the total ICU or SICU license beds.
*/

SELECT business.business_name, SUM(bed_fact.license_beds) AS total_license_beds
FROM bed_fact
JOIN business ON bed_fact.ims_org_id = business.ims_org_id
WHERE (bed_fact.bed_id = 4  -- ICU bed
   OR bed_fact.bed_id = 15)  -- SICU bed
GROUP BY business.ims_org_id 
order by total_license_beds desc
Limit 10; 

/* 
Q2 Do the same thing for Census beds.
*/ 
SELECT business.business_name, SUM(bed_fact.census_beds) AS total_census_beds
FROM bed_fact
JOIN business ON bed_fact.ims_org_id = business.ims_org_id
WHERE (bed_fact.bed_id = 4  -- ICU bed
   OR bed_fact.bed_id = 15)  -- SICU bed
GROUP BY business.ims_org_id 
order by total_census_beds desc
Limit 10; 

/*
Q3 : Do the same thing for Staffed beds.
*/ 
SELECT business.business_name, SUM(bed_fact.staffed_beds) AS total_staffed_beds
FROM bed_fact
JOIN business ON bed_fact.ims_org_id = business.ims_org_id
WHERE (bed_fact.bed_id = 4  -- ICU bed
   OR bed_fact.bed_id = 15)  -- SICU bed
GROUP BY business.ims_org_id 
order by total_staffed_beds desc
Limit 10; 

/*
Q5 A
Conduct the same investigation as you did for 4a and list the same output of top 10 hospitals by descending bed volume,
 only this time select only those top 10 hospitals that have both kinds of ICU and SICU beds, 
i.e. only hospitals that have at least 1 ICU bed and at least 1 SICU bed can be included in this part of the analysis. 
 */
 
/*
License Beds
*/
SELECT 
    business.business_name, 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN bed_fact.license_beds ELSE 0 END) AS total_icu_license_beds,
    SUM(CASE WHEN bed_fact.bed_id = 15 THEN bed_fact.license_beds ELSE 0 END) AS total_sicu_license_beds,
    SUM(bed_fact.license_beds) AS total_license_beds
FROM 
    bed_fact
JOIN 
    business ON bed_fact.ims_org_id = business.ims_org_id
WHERE 
    bed_fact.bed_id IN (4, 15)  -- ICU bed or SICU bed
GROUP BY 
    business.ims_org_id, business.business_name
HAVING 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN 1 ELSE 0 END) > 0  -- At least 1 ICU bed
    AND SUM(CASE WHEN bed_fact.bed_id = 15 THEN 1 ELSE 0 END) > 0  -- At least 1 SICU bed
ORDER BY 
    total_license_beds DESC  -- Sorting by the total census beds
LIMIT 10;

/*
census_beds
*/
SELECT 
    business.business_name, 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN bed_fact.census_beds ELSE 0 END) AS total_icu_census_beds,
    SUM(CASE WHEN bed_fact.bed_id = 15 THEN bed_fact.census_beds ELSE 0 END) AS total_sicu_census_beds,
    SUM(bed_fact.census_beds) AS total_census_beds
FROM 
    bed_fact
JOIN 
    business ON bed_fact.ims_org_id = business.ims_org_id
WHERE 
    bed_fact.bed_id IN (4, 15)  -- ICU bed or SICU bed
GROUP BY 
    business.ims_org_id, business.business_name
HAVING 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN 1 ELSE 0 END) > 0  -- At least 1 ICU bed
    AND SUM(CASE WHEN bed_fact.bed_id = 15 THEN 1 ELSE 0 END) > 0  -- At least 1 SICU bed
ORDER BY 
    total_census_beds DESC  -- Sorting by the total census beds
LIMIT 10;

/* 
Staff Detail : 
*/ 

SELECT 
    business.business_name, 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN bed_fact.staffed_beds ELSE 0 END) AS total_icu_staffed_beds,
    SUM(CASE WHEN bed_fact.bed_id = 15 THEN bed_fact.staffed_beds ELSE 0 END) AS total_sicu_staffed_beds,
    SUM(bed_fact.census_beds) AS total_staffed_beds
FROM 
    bed_fact
JOIN 
    business ON bed_fact.ims_org_id = business.ims_org_id
WHERE 
    bed_fact.bed_id IN (4, 15)  -- ICU bed or SICU bed
GROUP BY 
    business.ims_org_id, business.business_name
HAVING 
    SUM(CASE WHEN bed_fact.bed_id = 4 THEN 1 ELSE 0 END) > 0  -- At least 1 ICU bed
    AND SUM(CASE WHEN bed_fact.bed_id = 15 THEN 1 ELSE 0 END) > 0  -- At least 1 SICU bed
ORDER BY 
    total_staffed_beds DESC  -- Sorting by the total census beds
LIMIT 10;
