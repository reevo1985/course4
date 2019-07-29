#add correct libraries
library(data.table)

#download file 
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./Dataset1.zip')){
  download.file(fileurl,'./Dataset1.zip', mode = 'wb')
  unzip("Dataset1.zip", exdir = getwd())
}

#read txt file as csv
features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

#pull data of different trains
dxtrain <- read.table('./UCI HAR Dataset/train/X_train.txt')
dytrain <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
dsubjecttrain <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

#create dataframe dtrainframe
dtrainframe <-  data.frame(dsubjecttrain, dytrain, dxtrain)
names(dtrainframe) <- c(c('subject', 'activity'), features)

#pull date of different test information
dxtest <- read.table('./UCI HAR Dataset/test/X_test.txt')
dytest <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
dsubjecttest <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

#create second dataframe dtestframe
dtestframe <-  data.frame(dsubjecttest, dytest, dxtest)
names(dtestframe) <- c(c('subject', 'activity'), features)

#combine data
dcombinedframe <- rbind(dtrainframe, dtestframe)

#Calculate the mean and standard deviation
mean_std.select <- grep('mean|std', features)
dmeanstd <- dcombinedframe[,c(1,2,mean_std.select + 2)]

#read activity labels txt file and set data as characters
activitylabels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activitylabels <- as.character(activitylabels[,2])
dmeanstd$activity <- activitylabels[dmeanstd$activity]

#rename data
name.new <- names(dmeanstd)
name.new <- gsub("[(][)]", "", name.new)
name.new <- gsub("^t", "Time", name.new)
name.new <- gsub("^f", "Frequency", name.new)
name.new <- gsub("Acc", "Accelerometer", name.new)
name.new <- gsub("Gyro", "Gyroscope", name.new)
name.new <- gsub("Mag", "Magnitude", name.new)
name.new <- gsub("-mean-", "Mean", name.new)
name.new <- gsub("-std-", "Standard_Deviation", name.new)
name.new <- gsub("-", "_", name.new)
names(dmeanstd) <- name.new

#clean data and output
dclean <- aggregate(dmeanstd[,3:81], by = list(activity = dmeanstd$activity, subject = dmeanstd$subject),FUN = mean)
write.table(x = dclean, file = "dataclean.txt", row.names = FALSE)
