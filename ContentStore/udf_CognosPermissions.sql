create function [dbo].[udf_CognosPermissions](@sIn varchar(max))
returns varchar(max)
as 
begin
declare @sBin varchar(max) = ''
declare @sOut varchar(max) = ''
declare @i int = 1
declare @j int = 1
declare @sTemp varchar(8) = ''
declare @iByte int = 0
declare @thisByte varchar(5) = ''

declare @codes table (
  letter char(1) COLLATE Latin1_General_CS_AS,
  number int
)

insert @codes
      select 'A', 0
union select 'B', 1
union select 'C', 2
union select 'D', 3
union select 'E', 4
union select 'F', 5
union select 'G', 6
union select 'H', 7
union select 'I', 8
union select 'J', 9
union select 'K', 10
union select 'L', 11
union select 'M', 12
union select 'N', 13
union select 'O', 14
union select 'P', 15
union select 'Q', 16
union select 'R', 17
union select 'S', 18
union select 'T', 19
union select 'U', 20
union select 'V', 21
union select 'W', 22
union select 'X', 23
union select 'Y', 24
union select 'Z', 25
union select 'a', 26
union select 'b', 27
union select 'c', 28
union select 'd', 29
union select 'e', 30
union select 'f', 31
union select 'g', 32
union select 'h', 33
union select 'i', 34
union select 'j', 35
union select 'k', 36
union select 'l', 37
union select 'm', 38
union select 'n', 39
union select 'o', 40
union select 'p', 41
union select 'q', 42
union select 'r', 43
union select 's', 44
union select 't', 45
union select 'u', 46
union select 'v', 47
union select 'w', 48
union select 'x', 49
union select 'y', 50
union select 'z', 51
union select '0', 52
union select '1', 53
union select '2', 54
union select '3', 55
union select '4', 56
union select '5', 57
union select '6', 58
union select '7', 59
union select '8', 60
union select '9', 61
union select '+', 62
union select '/', 63


while @i < len(@sIn)
begin
  set @sBin = @sBin + right('000000' + dbo.udf_ConvertFromBase10((select number from @codes where letter = substring(@sIn, @i, 1)), 2), 6)
  set @i = @i + 1
end

set @i = 1

while @i < len(@sBin)
begin
  set @sTemp = substring(@sBin, @i, 8)
  set @j = 1
  set @iByte = 0
  while @j <= 8
  begin
    set @iByte = @iByte + (cast(substring(@sTemp, @j, 1) as int) * (power(2, 8 - @j)))
    set @j = @j + 1
  end
  set @thisByte = case when @iByte = 0 then char(13)
                       else char(@iByte)
                  end
  set @sOut = @sOut + @thisByte
  set @i = @i + 8
end

return @sOut
end
GO
