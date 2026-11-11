--- the following validate KPIs from two table 
WITH source1 AS (
    SELECT
        COUNT(UNIQUEPOLICIES)       AS PolicyCount,
        ROUND(SUM(IAP))             AS Total_IAP
    FROM (
        SELECT DISTINCT
            UNIQUEPOLICIES,
            AVG(MAX_IAP) AS IAP
        FROM (
            SELECT *
            FROM adhoc_salesops.adhoc_reporting.vw_newapps_with_agentkey_rn_e_v2
            WHERE YEAR(min_firststatementdate) = '2025'
        )
        GROUP BY ALL )),
source1_agents AS (
    -- Separate CTE: distinct AGENTKEY count, independent of policy dedup
    SELECT COUNT(DISTINCT AGENTKEY) AS AgentKey_Count
    FROM adhoc_salesops.adhoc_reporting.vw_newapps_with_agentkey_rn_e_v2
    WHERE YEAR(min_firststatementdate) = '2025'
),
source2 AS (
    SELECT
        COUNT(Policy_composite_id)  AS PolicyCount,
        ROUND(SUM(IAP))             AS Total_IAP
    FROM (
        SELECT DISTINCT
            Policy_composite_id,
            AVG(initial_annual_premium) AS IAP
        FROM (
            SELECT *
            FROM EDW.BI.VW_BI_NEWAPPS_PREMIUM_AGENT_REVENUE
            WHERE YEAR(first_statement_date) = '2025'
        )
        GROUP BY ALL)),
source2_agents AS (
    -- Separate CTE: distinct AGENTKEY count, independent of policy dedup
    SELECT COUNT(DISTINCT AGENTKEY) AS AgentKey_Count
    FROM EDW.BI.VW_BI_NEWAPPS_PREMIUM_AGENT_REVENUE
    WHERE YEAR(first_statement_date) = '2025'
)
SELECT
    s1.PolicyCount                                          AS S1_PolicyCount,
    s2.PolicyCount                                          AS S2_PolicyCount,
    (s2.PolicyCount - s1.PolicyCount)                       AS PolicyCount_Variance,
    s1.Total_IAP                                            AS S1_Total_IAP,
    s2.Total_IAP                                            AS S2_Total_IAP,
    (s2.Total_IAP - s1.Total_IAP)                           AS IAP_Variance,
    s1a.AgentKey_Count                                      AS S1_AgentKey_Count,
    s2a.AgentKey_Count                                      AS S2_AgentKey_Count,
    (s2a.AgentKey_Count - s1a.AgentKey_Count)               AS AgentKey_Variance
FROM source1       s1
CROSS JOIN source2       s2
CROSS JOIN source1_agents s1a
CROSS JOIN source2_agents s2a;
