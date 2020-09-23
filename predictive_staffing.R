#!/usr/bin/env Rscript

require(docopt)
'Usage: predictive_staffing.R <bids_file_pointer> <contracts_file_pointer> <outdir_for_plots>

]' -> doc

opts <- docopt(doc)

d1 <- read.delim(file=opts$bids_file_pointer, sep=",", stringsAsFactors=F)
d2 <- read.delim(file=opts$contracts_file_pointer, sep=",", stringsAsFactors=F)

#d1 <- read.delim(file="~/Documents/personal/gits/predictive_staffing/bids.csv", sep=",", stringsAsFactors=F)
#d2 <- read.delim(file="~/Documents/personal/gits/predictive_staffing/current.csv", sep=",", stringsAsFactors=F)

# TODO: make it so that the current contracts csv need not have a pwin column

dat <- rbind(d1, d2)

colnames(dat)[1:4] <- c("Effort", "StartDate", "EndDate", "pwin")

numStaffTypes <- ncol(dat) - 4

today <- as.Date(format(Sys.Date(),"%m/1/%Y"), format = "%m/%d/%Y")
starts <- as.Date(dat$StartDate, format = "%m/%d/%Y")
ends <- as.Date(dat$EndDate, format = "%m/%d/%Y")

all_months <- seq(from=today, to=max(ends), by="month")
all_jobs <- colnames(dat)[5:ncol(dat)]

# make an array of month X effort X type
# this lets us sample from efforts, index by month, and get info per staff type (and totals)
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
  win_vec <- matrix(0, nrow=nrow(dat), ncol=1)
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

file_handle <- paste(opts$outdir_for_plots, "_totals.pdf", sep="")
pdf(file=file_handle, width=7, height=5)

plot(all_months, med, type="l",
     ylim=c(min(five), max(ninetyfive)),
     xlab="Timeframe", ylab="Projected Total Staffing",
     main="Projected Staffing over Time")
points(all_months, five, col="red", type="l")  
points(all_months, ninetyfive, col="green", type="l")

legend("topright",
       legend=c("95th percentile", "Median", "5th percentile"),
       col=c("green", "black", "red"),
       lty=1, lwd=c(2,2,2))

dev.off()

# make simultations for each staffing type
# So, we aggregate main (effort-month-job)
# Main is [effort, month, job-type]

for (j in 1:length(all_jobs)){
  sub <- main[,,j]
  sims <- matrix(0, nrow=nrow(sub), ncol=100)
  for(i in 1:100){
    win_vec <- matrix(0, nrow=nrow(dat), ncol=1)
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
  file_handle <- paste(opts$outdir_for_plots, "_", all_jobs[j], ".pdf", sep="")
  pdf(file=file_handle, width=7, height=5)
  plot(all_months, med, type="l",
       ylim=c(min(five), max(ninetyfive)),
       xlab="Timeframe", ylab="Projected Staffing",
       main=paste("Projected Staffing:", all_jobs[j], sep=" "))
  points(all_months, five, col="red", type="l")  
  points(all_months, ninetyfive, col="green", type="l")
  legend("topright",
         legend=c("95th percentile", "Median", "5th percentile"),
         col=c("green", "black", "red"),
         lty=1, lwd=c(2,2,2))
  dev.off()
}









