--  get locations of schedules
;
with cte(PCMID, 
     CMID, 
     ScheduleId, 
     ObjectName, 
     ObjectPath, 
     done, 
     RootNode, 
     Modified, 
     ReportId) as 
(
  select o.PCMID
  , n.CMID
  , n.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , 0
  , cast(n.NAME as varchar(max))
  , o.MODIFIED
  , 0
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where n.ISDEFAULT = 1
    and c.name = 'schedule'

  union all
  select o.PCMID
  , n.CMID
  , cte.ScheduleId
  , cte.ObjectName
  , cast(n.NAME + '/' + cte.ObjectPath as varchar(max))
  , case when left(n.NAME, 8) = 'MyNamespace:' then 1 else 0 end
  , cast(n.NAME as varchar(max))
  , cte.Modified
  , case
    when c.NAME in ('report', 'reportview', 'dataset2') then o.CMID
    else cte.ReportId
    end
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join cte cte on cte.PCMID = n.CMID
  where n.ISDEFAULT = 1
    and n.CMID != 0
    and cte.done = 0
)

select c.ScheduleId
, c.ObjectName
, c.Modified
, c.ObjectPath
, c.ReportId
, c.RootNode
into #schedules
from cte c
where c.ObjectPath like 'Team Content%'
  or c.ObjectPath like 'MyNamespace:%'
order by ObjectPath

select s.ReportId
, replace(reverse(substring(reverse(s.ObjectPath), charindex('/', reverse(s.ObjectPath)) + 1, 4000)), s.RootNode, isnull(u.Name, s.RootNode)) as ObjectPath
, case
    when schedtype.interval = 'trigger' then 'on trigger ' + t.SCHEDTRIGNAME
    else 'Every ' + 
      cast(c.EVERYNPERIODS as varchar(5)) + ' ' + 
      schedtype.interval + 
      case 
        when c.EVERYNPERIODS > 1 then 's'
        else ''
      end + 
      case 
    when schedtype.interval = 'hour' then ' between ' + 
          format(
            CONVERT(
              datetime, 
              SWITCHOFFSET(
                CONVERT(
                  datetimeoffset, 
                  c.INTRARECURSTART
                ), 
                DATENAME(
                  TzOffset, 
                  SYSDATETIMEOFFSET()
                )
              )
            ),
            'HH:mm:ss'
          ) + 
          ' and ' +
          format(
            CONVERT(
              datetime, 
              SWITCHOFFSET(
                CONVERT(
                  datetimeoffset, 
                  c.INTRARECUREND
                ), 
                DATENAME(
                  TzOffset, 
                  SYSDATETIMEOFFSET()
                )
              )
            ),
            'HH:mm:ss'
          ) + ' '
        when schedtype.interval = 'day' then ' '
        when schedtype.interval = 'year' then ' on day ' + cast(c.YEARLYABSDAY as varchar(5)) + ' of ' + DATENAME(month, DATEFROMPARTS(2020, c.YEARLYABSMONTH + 1, 1)) /*'month ' + cast(c.YEARLYABSMONTH as varchar(5))*/ + ' '
        else ' on ' + 
          case
            when schedtype.interval = 'week' then 
              case 
                when c.WEEKLYMONDAY = 1 then 'monday '
                else ''
              end + 
              case 
                when c.WEEKLYTUESDAY = 1 then 'tuesday '
                else ''
              end + 
              case 
                when c.WEEKLYWEDNESDAY = 1 then 'wednesday '
                else ''
              end + 
              case 
                when c.WEEKLYTHURSDAY = 1 then 'thursday '
                else ''
              end + 
              case 
                when c.WEEKLYFRIDAY = 1 then 'friday '
                else ''
              end + 
              case 
                when c.WEEKLYSATURDAY = 1 then 'saturday '
                else ''
              end + 
              case 
                when c.WEEKLYSUNDAY = 1 then 'sunday '
                else ''
              end
            when schedtype.interval = 'month' then 
              case
                when schedtype.typename = 'monthly by day of month' then 'day ' + cast(c.MONTHLYABSDAY as varchar(5)) + ' '
                when schedtype.typename = 'monthly by day of week' then daynames.name /*cast(c.MONTHLYRELDAY as varchar(5))*/ + ' of week ' + cast(c.MONTHLYRELWEEK + 1 as varchar(5)) + ' '  --  this isn't right
                else ''
              end
            else ''
          end
      end + 
      'at ' + 
    format(
        CONVERT(
          datetime, 
          SWITCHOFFSET(
            CONVERT(
              datetimeoffset, 
              c.STARTDATE
            ), 
            DATENAME(
              TzOffset, 
              SYSDATETIMEOFFSET()
            )
          )
        ),
        case
          when schedtype.interval = 'hour' then 'mm'
          else 'HH:mm:ss'
        end
      )
  end as ScheduleDescription
, format(
    CONVERT(
      datetime, 
      SWITCHOFFSET(
        CONVERT(
          datetimeoffset, 
          c.STARTDATE
        ), 
        DATENAME(
          TzOffset, 
          SYSDATETIMEOFFSET()
        )
      )
    ),
    'HH:mm:ss'
  ) as StartTime
into #reports
from #schedules s
  inner join CMOBJPROPS2 c on c.CMID = s.ScheduleId
  left outer join CMOBJPROPS51 t on t.CMID = s.ScheduleId
  left outer join (values (2, 'monthly by day of week', 'month')
                        , (1, 'monthly by day of month', 'month')
                        , (4, 'weekly', 'week')
                        , (0, 'daily', 'day')
                        , (9, 'hourly', 'hour')
                        , (7, 'triggered', 'trigger')
                        , (5, 'yearly', 'year')
  ) schedtype (type, typename, interval) on schedtype.type = c.TYPE
  left outer join (
  select a.OBJID
  , b.NAME

  from CMOBJPROPS1 a
    inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = s.RootNode
  left outer join (values (0, 'Sunday')
                        , (1, 'Monday')
                        , (2, 'Tuesday')
                        , (3, 'Wednesday')
                        , (4, 'Thursday')
                        , (5, 'Friday')
                        , (6, 'Saturday')
  ) daynames (num, name) on daynames.num = c.MONTHLYRELDAY

order by format(
    CONVERT(
      datetime, 
      SWITCHOFFSET(
        CONVERT(
          datetimeoffset, 
          c.STARTDATE
        ), 
        DATENAME(
          TzOffset, 
          SYSDATETIMEOFFSET()
        )
      )
    ),
    'HH:mm:ss'
  )
, c.type
, s.ObjectPath



select pn.NAME as Package
, r.ObjectPath as ReportPath
, r.ScheduleDescription
, r.StartTime
--, r.ReportId

from #reports r
  inner join CMREFNOORD1 ref on ref.CMID = r.ReportId
  inner join CMOBJECTS po on po.CMID = ref.REFCMID
  inner join CMOBJNAMES pn on pn.CMID = po.CMID
  inner join CMCLASSES pc on pc.CLASSID = po.CLASSID

where pn.ISDEFAULT = 1
  and pc.NAME = 'package'

order by Package
, StartTime



drop table #schedules
drop table #reports
