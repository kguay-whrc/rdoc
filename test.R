## ShrubHub Functions
## @desc The following functions are intended for the ShrubHub project.
## It is assumed that input data frames (d) are in the following format:
##		 year month day site   value
##	1  1982     1   1   s1 0.00000
##	2  1982     1  15   s1 0.00000
##	3  1982     2   1   s1 0.00000
##
## @author: Kevin Guay (kguay@whrc.org)
## @contributer: 
##

time <- function(code){
	## @desc A utility to time a section of code
	## @param code: R code
	## @return runtime (seconds)
	
	# start timer
	ptm <- proc.time()
	# run code
	f
	# stop timer and return stats
	(proc.time() - ptm)[3]
}

sh.2monthly <- function(d){
	## @desc A set of functions for converting the temporal resolution of a data
	##   frame that has a year, month and day (optional) column.
	## Aggregate daily observations (in a dataframe) to monthly observations.
	## @param d: data frame with a columns: 'year', 'month', 'day' (optional),
	##   'site', 'value'
	## @return a dataframe with columns: 'year', 'month', 'site', 'value'
	## @examp
	##	df <- data.frame(year=1990:2000, site=s1:s11)
	##	df.monthly <- sh.2monthly(df)
	
	# aggregate dataframe (d) to yearly temporal resolution
	d <- aggregate(d$value, by=list(d$year, d$month, d$site), FUN=mean,
		na.rm=TRUE)
	# rename the column names
	colnames(d) <- c("year", "month", "site", "value")
	# sort the dataframe by site, then year
	d <- d[with(d, order(site, year, month)), ]
	# return the new data frame
	d
}

sh.2yearly <- function(d){
	## @desc Aggregate daily or monthly observations (in a dataframe) to
	##   yearly observations.
	## @param d: data frame with a columns: 'year', 'month', 'day' (optional),
	##   'site', 'value'
	## @return a dataframe with columns: 'year', 'site', 'value'
	
	# aggregate dataframe (d) to yearly temporal resolution
	d <- aggregate(d$value, by=list(d$year, d$site), FUN=mean, na.rm=TRUE)
	# rename the column names
	colnames(d) <- c("year", "site", "value")
	# sort the dataframe by site, then year
	d <- d[with(d, order(site, year)), ]
	# return the new data frame
	d
}

sh.yearly2monthly <- function(d, per.year=12){
	## @desc Disaggregate yearly observations (in a dataframe) to monthly or
	##   semi-monthly observations. This function allows data frames wtih a
	##   higher temporal resolution (ie. yearly) to be compared to dataframes 
	##   with lower temporal resolutions (ie. bi-monthly).
	## @param per.year: number of observations to insert per year. 12
	##   (default) represents one observation per month while 24 would 
	##   represent 2 observations per month.
	## @return a dataframe with the new temporal resolution.
	
	# insert [per.year] new rows per year into the data frame, d
	d <- data.frame(lapply(d, function(d) rep(d, each = per.year)), 
		month=rep(1:per.year))
	# reorder the columns and return the new data frame
	d[c(1,4,2,3)]
}

subset.range <- function(d, s.year, length){
	## @desc Subset a data frame for a range of dates.
	## @param d: data frame with a 'year' column
	## @param s.year: start year
	## @param length: length of range
	## @return new dataframe with only subsest specified
	for(i in 1:length){
		if(i==1)
			df <- subset(d, year == (s.year -1 + i))
		else
			df <- rbind(df, subset(d, year == (s.year - 1 + i)))
	}
	df
}

sh.cor.t.range <- function(d1, d2, s.year, e.year, range=21){
	## @desc Calculate the correlation between two variables (data frames;
	##   d1 and d2) for each month using a range of years (default = 20)
	## @param d1: data frame 1
	## @param d2: data frame 2
	## @param s.year: start year (must be 10 years into the series)
	## @param e.year: end year (must be )
	## @param range: [20] range of years to compute correlation for (even)
	## @return new dataframe with correlation values
	## @examp sh.cor <- sh.cor.t.range(cru.tmp, cru.pre, 1920, 1922)
	
	# parameter check: check that range is even
	if(range %% 2 == 1){
		print('exit(-2): error: range must be even (divisible by 2)')
		return(-2)
	}
	
	# set up an output dataframe (this first row will be deleted when
	#  returning)
	out <- data.frame(year=1, month=1, site=1, value=1)
	
	# loop through years, sites and months
	for(y in s.year:e.year)
		for(s in c(paste('s', seq(1:51), sep=''), paste('i', seq(1:54), sep='')))
			for(m in 1:12){
				# subset the first dataset
				d1.subset <- subset.range(subset(d1, site==s & month==m), y-10, range)
				# subset the second dataset
				d2.subset <- subset.range(subset(d2, site==s & month==m), y-10, range)
				# add them to the output dataframe
				out <- rbind(out, data.frame(year=y, month=m, site=s, value=cor(d1.subset$value, d2.subset$value)))
			}
	
	# return everything except for the first row of the output data frame
	out[2:nrow(out),]
}


sh.shrub.site <- function(growth, y){
   # initalize an empty output dataframe (this row will not be returned)
   output <- data.frame(site='', shrub='', value=0)
   
   # list of site names in growth df
   growth.sites <- unique(growth$site)
   # loop through each site and run correlation on the individual shrub chrons
   #  and the site-level variables
   for(growth.site in growth.sites){
      # extract the current site from the site-level variable
      sl.var <- subset(sh.2yearly(y), site == growth.site)
      # list of the individual shrub codes (within the given site)
      growth.shrubs <- unique(subset(growth,site == growth.site)$shrub)
      # loop through the shrubs and run correlation on each individual one
      for(growth.shrub in growth.shrubs){
         # extract the individual shrub data from the growth dataframe
         shrub.sel <- subset(growth,shrub == as.character(growth.shrub))
         # merge the shrub dataframe with the site-level variable
         dat <- merge(shrub.sel, sl.var, by='year')
         
         # calculate the correlation and add it to the output dataframe
         output <- rbind(output, data.frame(site=growth.site, 
         shrub=growth.shrub, value=cor(dat$value.x, dat$value.y)))
      }
   }
   
   # return the output dataframe without the first (initialization) row
   output[2:nrow(output),]
}


sh.cor <- function(sml, lrg, moving.window = F){
	# for each year in the lrg data frame, loop through the monthly/ daily/ semi-daily observations in the sml data frame and run correlation.
	
	lrg.sites <- unique(lrg$site)
	lrg.years <- unique(lrg$year)
	
	# combine the sml and lrg data frames
	df <- merge(sml, lrg, c('site', 'year'))
	# set the column names
	names(df) <- c('site', 'year', 'month', 'day', 'value1', 'value2')
	# reorder the columns
	df <- df[c(2,3,4,1,5,6)]
	# order the rows by column (site, year, month and then day)
	df <- df[with(df, order(site, year, month, day)), ]
	# show the first 30 rows of the data frame
	df[1:30,]

	# compute [yearly] correlation between value1 (yearly cru) and valu2 (gimms)
	data.frame(year=unique(df$year), cor=as.numeric(by(df, df$year, 
		FUN = function(x) cor(x$value1, x$value2, method = "spearman",
		use='complete.obs'))))	
}



