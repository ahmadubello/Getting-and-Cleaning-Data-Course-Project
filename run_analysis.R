library(tidyverse)

# if the zipped file is stored locally on the machine
file <- "getdata_projectfiles_UCI HAR Dataset.zip"

# if not, download from the link provided
if (!file.exists(file)){
    file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(file_url, file, method="curl")
}  

# unzip file, if not already unzipped
if (!file.exists("UCI HAR Dataset")) { 
    unzip(file) 
}


# reading all training and test data sets
activities_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "id")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "id")

# bind all training and test dataset into one data frame
all_x <- rbind(x_train, x_test)
all_y <- rbind(y_train, y_test)
subject <- rbind(subject_test, subject_train)
all_data <- cbind(subject, all_x, all_y)

# select only measurements with mean and standard deviation
all_data_mean_std <- all_data %>% 
    select(subject, id, contains("mean"), contains("std"))

# assign activity names to all  data frame
all_data_mean_std$id <- activities_labels[all_data_mean_std$id, 2]

# assign names to each data appropriately
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

# calculate the mean of each measurement by subject and activity, and save as different data frame 
tidy_data <- all_data_mean_std %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean)) %>% 
    ungroup()
# save the tidy data to a text file
write.table(tidy_data, "tidy_data.txt", row.name=FALSE)

