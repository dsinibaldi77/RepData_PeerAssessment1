
        
## 1. Code for reading in the dataset and/or processing the data
        
### Global settings and working directory
pathwd<-"/home/superuser/Dropbox/R/Coursera/Reproducible Research/week2/RepData_PeerAssessment1"
setwd(pathwd)

### Loading and preprocessing the data
file<-"activity.zip"
unzip(file)
csv<-"activity.csv"
act <- read.csv(csv)
library(dplyr)
actvalid<-act %>% filter(is.na(steps)==FALSE) 

## 2. Histogram of the total number of steps taken each day

### Calculate the total number of steps taken per day
step_by_day<-actvalid %>% select(steps,date) %>% 
        rename(tot_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(sum)

### Histogram of the total number of steps taken each day
hist(step_by_day$tot_steps, 
     breaks = 20,
     main = 'Histogram of the total number of steps taken each day',
     xlab = 'Total Number of Steps', 
     col = 'red'
)

## 3. Mean and median number of steps taken each day

### Calculation and reporting the mean and median of the total number of steps taken per day
library(dplyr)
mean_step_by_day<-actvalid %>% select(steps,date) %>% 
        rename(mean_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(mean)
median_step_by_day<-actvalid %>% select(steps,date) %>% 
        rename(median_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(median)
mm_step_by_day<-inner_join(mean_step_by_day,median_step_by_day,
                           by=c("date"="date")) %>% 
        select(date,mean_steps,median_steps) 


## 4. Time series plot of the average number of steps taken
library(dplyr)
mean_steps_by_interval<-actvalid %>% select(steps,interval) %>% 
        rename(mean_steps = steps) %>% 
        group_by(interval) %>% 
        summarise_all(mean)
with(mean_steps_by_interval,
     plot(x=interval,
          y=mean_steps,
          type="l",
          main = 'Time series plot of the average number of steps taken',
          xlab = '5-minute time interval', 
          ylab="Average number of steps",
          col = 'blue')
)

## 5. The 5-minute interval that, on average, contains the maximum number of steps
max_steps<-mean_steps_by_interval[mean_steps_by_interval[,"mean_steps"] == max(mean_steps_by_interval$mean_steps),]


## 6. Code to describe and show a strategy for imputing missing data
### Calculation and reporting the total number of missing values in the dataset 
library(dplyr)
actna<-act %>% filter(is.na(steps)==TRUE)  %>% select(date,interval)

### My strategy is to replace NA values with 0
library(dplyr)
act_optimized <- act %>% mutate(steps = replace(steps,is.na(steps)==TRUE, 0))
step_by_day_opt <-act_optimized %>% select(steps,date) %>% 
        rename(tot_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(sum)

##7. Histogram of the total number of steps taken each day after missing values are imputed
### This histogram show that the differences in the frequencies between using dataset with NA values and without NA values of steps. The frequencies increases in all steps adding data with NA.
step_by_day_opt$datatype="Dataset optimized with NA=0 values of steps"
step_by_day$datatype="Dataset without NA values of steps"
library(dplyr)
hist_step_by_day<-union(step_by_day_opt,step_by_day)
library(ggplot2)
ggplot(hist_step_by_day,aes(x=tot_steps,fill=datatype)) +
        geom_histogram() +
        ggtitle('Histogram of the total number of steps taken each day')+
        ylab('Frequency')+
        xlab('Total Number of Steps')+
        scale_fill_discrete(name="Dataset")+
        theme(legend.position="top")

### The calculation of mean and median show that isn't difference with the dataset with no NA values. This means that all NA values apply to the dates in which the measures have not been taken.
library(dplyr)
mean_step_by_day_opt<-act_optimized %>% select(steps,date) %>% 
        rename(mean_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(mean)
median_step_by_day_opt<-act_optimized %>% select(steps,date) %>% 
        rename(median_steps = steps) %>% 
        group_by(date) %>% 
        summarise_all(median)
diff_mean<-left_join(mean_step_by_day_opt,mean_step_by_day,
                     by=c("date"="date")) %>%  
        rename(mean_steps_na = mean_steps.x,
               mean_steps_no_na = mean_steps.y)
diff_median<-left_join(median_step_by_day_opt,median_step_by_day,
                       by=c("date"="date")) %>%  
        rename(median_steps_na = median_steps.x,
               median_steps_no_na = median_steps.y)


##8. Panel plot comparing the average number of steps taken per 5-minute interval across weekdays and weekends
act_optimized$date<-as.Date(act_optimized$date)
act_optimized$daytype<-ifelse(weekdays(act_optimized$date) %in% 
                                      c("sabato","domenica"),
                              "weekend","weekday")
library(ggplot2)
ggplot(data=act_optimized,
       aes(x=interval, y=steps, colour=daytype)) +
        geom_line()+
        ggtitle('')+
        ylab('Number of Steps')+
        xlab('Interval')+
        theme(legend.position="top")


