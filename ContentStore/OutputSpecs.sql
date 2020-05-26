;
with cte2(CMID,
              ObjectName,
              ObjectPath,
              ObjectClass,
			  Modified) as
(
       select o.CMID
       , n.NAME
       , cast(
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(
										replace(
											n.NAME, char(60), ''	--	<
										), char(62), ''	--	>
									), char(58), ''	--	:
								), char(34), ''	--	quote
							), char(47), ''	--	/
						), char(92), ''	--	\
					), char(124), ''	--	|
				), char(63), ''	--	?
			), char(42), ''	--	*
		) as varchar(max))
       , cast(c.NAME as varchar(max))
	   , o.MODIFIED
       from CMOBJECTS o
         inner join CMOBJNAMES n on n.CMID = o.CMID
         inner join CMCLASSES c on c.CLASSID = o.CLASSID
       where n.ISDEFAULT = 1
         and isdate(n.NAME) = 0
         and o.CMID = 2
       
	   union all
       select o.CMID
       , n.NAME
       , cast(cte2.ObjectPath + '/' + 
		replace(
			replace(
				replace(
					replace(
						replace(
							replace(
								replace(
									replace(
										replace(
											n.NAME, char(60), ''
										), char(62), ''
									), char(58), ''
								), char(34), ''
							), char(47), ''
						), char(92), ''
					), char(124), ''
				), char(63), ''
			), char(42), ''
		) as varchar(max))
       , cast(c.NAME as varchar(max))
	   , o.MODIFIED
       from CMOBJECTS o
         inner join CMOBJNAMES n on n.CMID = o.CMID
         inner join CMCLASSES c on c.CLASSID = o.CLASSID
         inner join cte2 cte2 on cte2.CMID = o.PCMID
       where n.ISDEFAULT = 1
         and n.CMID != 0
)

select REPLACE(c.ObjectPath,'/','\') + case when c.ObjectClass = 'exploration' then '.json' else '.xml' end as FilePath
, s.SPEC as SPEC
from cte2 c
  left join CMOBJPROPS7 s on s.CMID = c.CMID
where c.ObjectClass in ('report', 'exploration', 'dataSet2')
  and c.ObjectPath like 'Team Content/Reports%'