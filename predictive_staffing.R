# Goal: plot staffings needs probabilistically in time via info from BD efforts
# Incoming data: p(win), staffing needs by type, start and end dates
# Plots: Staffing needs (and haves) by type, and totals.

# Make up data; handle API later
# Each row has effort name, pwin, and counts of staff needed, and dates (dates suck).
# Output needs to be at the monthly level

#                                             j.eng, s.eng, j.ds, s.ds, fse, pm
raw <- c(
  "Effort1", "10/1/2019", "10/1/2021", 0.3,    1,    1,      0,    0,   2,    .5, 
  "Effort2", "12/1/2019", "12/1/2022", 0.2,    1,    1,      2,    .5,  1,    .5,
  "Effort3", "3/1/2020",   "3/1/2021", 0.5,    0,    .5,     1,    0.3, 1,     0,
  "Effort4", "5/1/2020",   "5/1/2023", .8,     2,    1,      1,     .5, 2,     .5,
  "Effort5",  "11/1/2019", "11/1/2020", .3,    1,    0,      .33,   .33, 1,    0)

rm <- matrix(raw, nrow=5, byrow=T)

dat <- data.frame(rm, stringsAsFactors = F)
colnames(dat) <- c("Effort", "StartDate", "EndDate", "pwin", "jeng", "seng", "jds", "sds", "fse", "pm")
#seq(from=as.Date(dat$StartDate[1]), to=as.Date(dat$EndDate[1]), by="month")

starts <- as.Date(dat$StartDate, format = "%m/%d/%Y")
ends <- as.Date(dat$EndDate, format = "%m/%d/%Y")

all_months <- seq(from=min(starts), to=max(ends), by="month")
all_jobs <- c("jeng", "seng", "jds", "sds", "fse", "pm")

# need an array of month X effort X type
# this let's us sample from efforts, index by month, and get info per type (and totals)
main  <- array(data = 0, dim=c(length(all_months), nrow(dat), length(colnames(dat[5:ncol(dat)]))))

for (e in 1:nrow(dat)){   # e in efforts
  # get the months included in this effort
  st <- dat[e, "StartDate"]
  en <- dat[e, "EndDate"]
  this_effort_seq <- seq(from=as.Date(st, format= "%m/%d/%Y"), 
                         to=as.Date(en, format= "%m/%d/%Y"), 
                         by="month")
  for (j in 1:length(all_jobs)){  # j in jobs
    for (m in 1:length(all_months)){  # m in months
      if (all_months[m] %in% this_effort_seq){
        main[m,e,j] <- as.numeric(dat[e,all_jobs[j]])
      }
    }
  }
}

# Let's get the grand totals first; and the per-job-category stuff afterwards.
# Main is [effort, month, job-type]
# Collapse to effort by month, aggregating over job type
sub <- apply(main, c(1,2), sum) # month by effort
sims <- matrix(0, nrow=nrow(sub), ncol=100)
for(i in 1:100){
  win_vec <- matrix(0, nrow=5, ncol=1)
  for(e in 1:ncol(sub)){
    win_vec[e,1] <- rbinom(1, 1, as.numeric(dat[e,"pwin"]))
  }
  sims[,i] <- sub %*% win_vec
}

# sims has num_months rows, and 100 simulation columns
# each entry is number of FTE in the month, in that simulation
# get summary stats:
med <- apply(sims, 1, function(x) quantile(x, probs=c(0.5)))
five <- apply(sims, 1, function(x) quantile(x, probs=c(0.05)))
ninetyfive <- apply(sims, 1, function(x) quantile(x, probs=c(0.95)))

plot(all_months, med, type="l",
     ylim=c(min(five), max(ninetyfive)),
     xlab="Timeframe", ylab="Projected Total Staffing",
     main="Projected Staffing over Time")
points(all_months, five, col="red", type="l")  
points(all_months, ninetyfive, col="green", type="l")
  
# Ok, now we are going to make simultations FOR EACH LCAT/job.
# So, we aggregate main (effort-month-job)
# Main is [effort, month, job-type]

for (j in 1:length(all_jobs)){
  sub <- main[,,j]
  sims <- matrix(0, nrow=nrow(sub), ncol=100)
  for(i in 1:100){
    win_vec <- matrix(0, nrow=5, ncol=1)
    for(e in 1:ncol(sub)){
      win_vec[e,1] <- rbinom(1, 1, as.numeric(dat[e,"pwin"]))
    }
    sims[,i] <- sub %*% win_vec
  }
  # get quantiles of 'sub'
  med <- apply(sims, 1, function(x) quantile(x, probs=c(0.5)))
  five <- apply(sims, 1, function(x) quantile(x, probs=c(0.05)))
  ninetyfive <- apply(sims, 1, function(x) quantile(x, probs=c(0.95)))
  # plot
  plot(all_months, med, type="l",
       ylim=c(min(five), max(ninetyfive)),
       xlab="Timeframe", ylab="Projected Staffing",
       main=paste("Projected Staffing:", all_jobs[j], sep=" "))
  points(all_months, five, col="red", type="l")  
  points(all_months, ninetyfive, col="green", type="l")
}
  







