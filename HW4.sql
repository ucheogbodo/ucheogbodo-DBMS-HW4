CREATE DATABASE space_missions;
USE space_missions;

-- Part 1: SQL Table Creation
CREATE TABLE countries (
	CountryCode VARCHAR(3),
    CountryName VARCHAR(100),
    Continent VARCHAR(100),
    PRIMARY KEY (CountryCode)
);

CREATE TABLE launch_sites (
	SiteID INT,
    SiteName VARCHAR(100),
    CountryCode VARCHAR(100),
    Status VARCHAR(100),
    PRIMARY KEY (SiteID),
    CONSTRAINT FK_LaunchSites_Countries FOREIGN KEY (CountryCode)
		REFERENCES countries(CountryCode)
);

CREATE TABLE missions (
	MissionID INT,
    MissionName VARCHAR(100),
    RocketID VARCHAR(100),
    SiteID INT,
    Destination VARCHAR(100),
    LaunchYear int,
    Outcome VARCHAR(100),
    PRIMARY KEY (MissionID),
    CONSTRAINT FK_Missions_Sites FOREIGN KEY (SiteID)
		REFERENCES launch_sites(SiteID),
    CONSTRAINT FK_Missions_Rockets FOREIGN KEY (RocketID)
		REFERENCES rockets(RocketID)
);

CREATE TABLE organizations (
	OrgID INT,
    OrgName VARCHAR(100),
    HeadquartersCountry VARCHAR(100),
    OrgType VARCHAR(100),
    PRIMARY KEY (OrgID)
);

CREATE TABLE payloads (
	PayloadID INT,
    MissionID INT,
    PayloadName VARCHAR(100),
    PayloadType VARCHAR(100),
    MassKg DOUBLE,
    PRIMARY KEY (PayloadID),
    CONSTRAINT FK_Payloads_Missions FOREIGN KEY (MissionID)
		REFERENCES missions(MissionID)
);

CREATE TABLE rockets (
	RocketID INT,
    RocketName VARCHAR(100),
    OrgID INT,
    PayloadCapacityKG INT,
    OperationalStatus VARCHAR(100)
);

-- Part 2: SQL Queries
-- Q1
SELECT 
	missions.MissionName,
    rockets.RocketName,
    organizations.OrgName,
    launch_sites.SiteName,
    missions.Destination,
    missions.LaunchYear,
    missions.Outcome
FROM missions
JOIN rockets
	ON missions.RocketID = rockets.RocketID
JOIN organizations
	ON rockets.OrgID = organizations.OrgID
JOIN launch_sites
	ON missions.SiteID = launch_sites.SiteID
ORDER BY
	missions.LaunchYear DESC,
    missions.MissionName ASC;
    
-- Q2
SELECT
	missions.MissionName,
    rockets.RocketName,
    payloads.PayloadName,
    payloads.PayloadType,
    payloads.MassKg
FROM payloads
JOIN missions
	ON payloads.MissionID = missions.MissionID
JOIN rockets
	ON missions.RocketID = rockets.RocketID
WHERE missions.LaunchYear = 2024
ORDER BY payloads.MassKg DESC;
    
-- Q3
SELECT 
    launch_sites.SiteName,
    missions.MissionName,
    rockets.RocketName,
    missions.LaunchYear
FROM launch_sites
LEFT JOIN missions 
    ON launch_sites.SiteID = missions.SiteID
    AND missions.LaunchYear = 2024
LEFT JOIN rockets 
    ON missions.RocketID = rockets.RocketID
ORDER BY launch_sites.SiteName ASC;

-- Q4
WITH Org_Payload_Summary AS (
    SELECT 
        rockets.OrgID,
        SUM(payloads.MassKg) AS Total_Payload_Mass
    FROM payloads
    JOIN missions 
        ON payloads.MissionID = missions.MissionID
    JOIN rockets 
        ON missions.RocketID = rockets.RocketID
    GROUP BY rockets.OrgID
)
SELECT 
    organizations.OrgName,
    organizations.HeadquartersCountry,
    organizations.OrgType,
    org_payload_summary.Total_Payload_Mass
FROM organizations
LEFT JOIN Org_Payload_Summary 
    ON organizations.OrgID = Org_Payload_Summary.OrgID
ORDER BY Total_Payload_Mass DESC;

-- Q5
WITH mission_counts AS (
    SELECT 
        launch_sites.countrycode,
        COUNT(missions.missionid) AS total_missions
    FROM launch_sites
    JOIN missions 
        ON launch_sites.siteid = missions.siteid
    GROUP BY launch_sites.countrycode
),
payload_masses AS (
    SELECT 
        launch_sites.countrycode,
        SUM(payloads.masskg) AS total_payload_mass
    FROM launch_sites
    JOIN missions 
        ON launch_sites.siteid = missions.siteid
    JOIN payloads 
        ON missions.missionid = payloads.missionid
    GROUP BY launch_sites.countrycode
)
SELECT 
    countries.countryname,
    COALESCE(mission_counts.total_missions, 0) AS total_missions,
    COALESCE(payload_masses.total_payload_mass, 0) AS total_payload_mass
FROM countries
LEFT JOIN mission_counts 
    ON countries.countrycode = mission_counts.countrycode
LEFT JOIN payload_masses 
    ON countries.countrycode = payload_masses.countrycode
ORDER BY 
    total_missions DESC, 
    total_payload_mass DESC;