-- Cohort Analysis Example
with cohort as (
    select policy_surrogate_id,
           year(min(new_effective_start_date)) as cohort_year
    from edw.bi.bi_policies_under_management
    where new_effective_start_date is not null
    group by policy_surrogate_id
    having min(new_effective_start_date) between '2021-01-01' and '2026-12-31'
),
ren as (
    select policy_surrogate_id,
           renewal_effective_start_date as r_start,
           renewal_effective_end_date   as r_end
    from edw.bi.bi_policies_under_management
    where renewal_effective_start_date is not null
)
select c.cohort_year,
       count(distinct c.policy_surrogate_id) as "0",
       count(distinct iff(r.r_start <= date_from_parts(c.cohort_year+1,12,31) and r.r_end >= date_from_parts(c.cohort_year+1,1,1), c.policy_surrogate_id, null)) as "12",
       count(distinct iff(r.r_start <= date_from_parts(c.cohort_year+2,12,31) and r.r_end >= date_from_parts(c.cohort_year+2,1,1), c.policy_surrogate_id, null)) as "24",
       count(distinct iff(r.r_start <= date_from_parts(c.cohort_year+3,12,31) and r.r_end >= date_from_parts(c.cohort_year+3,1,1), c.policy_surrogate_id, null)) as "36",
       count(distinct iff(r.r_start <= date_from_parts(c.cohort_year+4,12,31) and r.r_end >= date_from_parts(c.cohort_year+4,1,1), c.policy_surrogate_id, null)) as "48"
from cohort c
left join ren r on r.policy_surrogate_id = c.policy_surrogate_id
group by c.cohort_year
order by c.cohort_year;
