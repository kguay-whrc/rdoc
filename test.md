
**Author**: : Kevin Guay (kguay@whrc.org)

**Contributer**: : 

#### Functions
- **time**
- **sh.2monthly**
- **sh.2yearly**
- **sh.yearly2monthly**
- **subset.range**
- **sh.cor.t.range**

##### Description
 The following functions are intended for the ShrubHub project.
It is assumed that input data frames (d) are in the following format:
year month day site   value
1  1982     1   1   s1 0.00000
2  1982     1  15   s1 0.00000
3  1982     2   1   s1 0.00000

---
###time
##### Description
 A utility to time a section of code

##### Parameters
name|desc
---|---
 code| R code

##### Return
 runtime (seconds)

---
###sh.2monthly

##### Description
 A set of functions for converting the temporal resolution of a data

frame that has a year, month and day (optional) column.

Aggregate daily observations (in a dataframe) to monthly observations.

##### Parameters
name|desc
---|---
 d| data frame with a columns| 'year', 'month', 'day' (optional),

'site', 'value'

##### Return
 a dataframe with columns: 'year', 'month', 'site', 'value'


##### Example


df <- data.frame(year=1990:2000, site=s1:s11)

df.monthly <- sh.2monthly(df)

---
###sh.2yearly

##### Description
 Aggregate daily or monthly observations (in a dataframe) to

yearly observations.

##### Parameters
name|desc
---|---
 d| data frame with a columns| 'year', 'month', 'day' (optional),

'site', 'value'

##### Return
 a dataframe with columns: 'year', 'site', 'value'

---
###sh.yearly2monthly

##### Description
 Disaggregate yearly observations (in a dataframe) to monthly or

semi-monthly observations. This function allows data frames wtih a

higher temporal resolution (ie. yearly) to be compared to dataframes 

with lower temporal resolutions (ie. bi-monthly).

##### Parameters
name|desc
---|---
 per.year| number of observations to insert per year. 12

(default) represents one observation per month while 24 would 

represent 2 observations per month.

##### Return
 a dataframe with the new temporal resolution.

---
###subset.range

##### Description
 Subset a data frame for a range of dates.

##### Parameters
name|desc
---|---
 d| data frame with a 'year' column
s.year| start year
length| length of range

##### Return
 new dataframe with only subsest specified

---
###sh.cor.t.range

##### Description
 Calculate the correlation between two variables (data frames;

d1 and d2) for each month using a range of years (default = 20)

##### Parameters
name|desc
---|---
 d1| data frame 1
d2| data frame 2
s.year| start year (must be 10 years into the series)
e.year| end year (must be )
range| [20] range of years to compute correlation for (even)

##### Return
 new dataframe with correlation values


##### Example
 sh.cor <- sh.cor.t.range(cru.tmp, cru.pre, 1920, 1922)
