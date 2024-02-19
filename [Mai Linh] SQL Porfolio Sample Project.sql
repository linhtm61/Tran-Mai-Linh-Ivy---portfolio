
-- This SQL project, conducted by Tran Mai Linh (Ivy), aims to calculate the growth rate of each product over three consecutive years using a dataset obtained from FTU's Data Management System course.
-- show sales data
select * from sales_17
order by 1,2

-- overall sale data
with CombinedData as (
    select * from sales_15
    union all
    select * from sales_16
    union all
    select * from sales_17
)
select * into sale
from CombinedData;

-- Looking at number of order by productkey per year
with peryear as (
    select sum(case when sale.orderdate like '2015%' then sale.orderquantity else 0 end) as totalorders_15, sale.productkey
    from sale 
    group by sale.productkey
),
temp_2016 as (
	select sum(case when sale.orderdate like '2016%' then sale.orderquantity else 0 end) as totalorders_16, sale.productkey
    from sale 
    group by sale.productkey
),
temp_2017 as (
    select sum(case when sale.orderdate like '2017%' then sale.orderquantity else 0 end) as totalorders_17, sale.productkey
    from sale 
    group by sale.productkey
),
final as (
	select peryear.*, temp_2016.totalorders_16
    from peryear
    left join temp_2016 on peryear.productkey = temp_2016.productkey
)
select final.*, temp_2017.totalorders_17
into final
from final
left join temp_2017 on final.productkey = temp_2017.productkey;

--  Calculate growth rate
alter table final add growth_rate_16 float;
update final
set growth_rate_16 = 
    case 
        when totalorders_15 = 0 then null
        else ((totalorders_16 - totalorders_15)*100.0  / totalorders_15) 
    end;
alter table final add growth_rate_17 float;
update final
set growth_rate_17 = 
    case 
        when totalorders_16 = 0 then null
        else ((totalorders_17 - totalorders_16) *100.0 / totalorders_16 )
    end;


-- create view
create view ProductGrowthRate as
select 
    productkey as ProductKey,
    totalorders_15 as [Total orders 15],
    totalorders_16 as [Total orders 16],
    growth_rate_16 as [Growth Rate 1516],
    totalorders_17 as [Total orders 17],
    growth_rate_17 as [Growth Rate 1617]
from 
    final;
