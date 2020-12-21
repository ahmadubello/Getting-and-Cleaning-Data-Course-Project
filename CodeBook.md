---
title: "CodeBook"
author: "Ahmad Bello Abdullahi"
date: "12/21/2020"
output: 
  html_document: 
    keep_md: yes
---


```r
library(tidyverse)
```

```
## -- Attaching packages ---------------------------------------------------------------------------------- tidyverse 1.2.1 --
```

```
## v ggplot2 3.2.1     v purrr   0.3.3
## v tibble  2.1.3     v dplyr   0.8.3
## v tidyr   1.0.0     v stringr 1.4.0
## v readr   1.3.1     v forcats 0.4.0
```

```
## -- Conflicts ------------------------------------------------------------------------------------- tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

If the zipped file is stored locally on the machine  


```r
file <- "getdata_projectfiles_UCI HAR Dataset.zip"
```


If not, download from the link provided  

```r
if (!file.exists(file)){
    file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(file_url, file, method="curl")
}  
```

Unzip file, if not already unzipped  

```r
if (!file.exists("UCI HAR Dataset")) {   
    unzip(file) 
}
```

Reading all training and test data sets  

```r
activities_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "id")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "id")  
```

Bind all training and test dataset into one data frame  

```r
all_x <- rbind(x_train, x_test)
all_y <- rbind(y_train, y_test)
subject <- rbind(subject_test, subject_train)
all_data <- cbind(subject, all_x, all_y)
```

Select only measurements with mean and standard deviation  

```r
all_data_mean_std <- all_data %>% 
    select(subject, id, contains("mean"), contains("std"))  
```


Assign activity names to all  data frame  

```r
all_data_mean_std$id <- activities_labels[all_data_mean_std$id, 2]  
```

Assign names to each data appropriately  

```r
names(all_data_mean_std)[2] = "activity"
names(all_data_mean_std)<-gsub("Acc", "Accelerometer", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("Gyro", "Gyroscope", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("BodyBody", "Body", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("Mag", "Magnitude", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("^t", "Time", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("^f", "Frequency", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("tBody", "TimeBody", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("-mean()", "Mean", names(all_data_mean_std), ignore.case = TRUE)
names(all_data_mean_std)<-gsub("-std()", "STD", names(all_data_mean_std), ignore.case = TRUE)
names(all_data_mean_std)<-gsub("-freq()", "Frequency", names(all_data_mean_std), ignore.case = TRUE)
names(all_data_mean_std)<-gsub("angle", "Angle", names(all_data_mean_std))
names(all_data_mean_std)<-gsub("gravity", "Gravity", names(all_data_mean_std))
```

Calculate the mean of each measurement by subject and activity, and save as different data frame   

```r
tidy_data <- all_data_mean_std %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean)) %>% 
    ungroup()
```

save the tidy data to a text file  

```r
write.table(tidy_data, "tidy_data.txt", row.name=FALSE)
```


