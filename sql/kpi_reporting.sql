--First_year_renewal Business--
// Why the difference? //
--Medicare Advantage and Part D run on calendar plan years and annual enrollment, so coverage follows the calendar year. Other products renew on the policy anniversary. 

select count(distinct t.policy_surrogate_id) as first_year_renewal_policies_2025
from edw.bi.bi_policies_under_management t
join edw.dbo.dim_productcategory pc on pc.productcategorycodeid = t.productcategorycodeid
and pc.isactive = 1
where t.renewal_effective_start_date <= '2025-12-31'
  and case
        when lower(pc.productcategoryname) in ('medicare advantage', 'part d')
          then least(t.renewal_effective_end_date,
                     date_from_parts(year(t.renewal_effective_start_date), 12, 31))
        else least(t.renewal_effective_end_date,
                   dateadd(day, -1, dateadd(year, 1, t.renewal_effective_start_date)))
      end >= '2025-01-01';
