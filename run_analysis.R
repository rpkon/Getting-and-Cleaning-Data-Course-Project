filename <- "course3.zip"

## download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# extract activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
#features[,2] <- as.character(features[,2])

# keep only features of mean and standard deviation
featuresFinal <- grep(".*mean.*|.*std.*", features[,2])
featuresFinal_names <- features[featuresFinal,2]
featuresFinal_names = gsub('-mean', 'Mean', featuresFinal_names)
featuresFinal_names = gsub('-std', 'Std', featuresFinal_names)
featuresFinal_names <- gsub('\\()', '', featuresFinal_names)
featuresFinal_names <- gsub('-', '', featuresFinal_names)


# load and prepare train and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresFinal]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresFinal]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# rbind train and test and assign right colNames
finalData <- rbind(train, test)
colnames(finalData) <- c("subject", "activity", featuresFinal_names)

finalData$activity <- factor(finalData$activity, levels = activityLabels[,1], labels = activityLabels[,2])

library(reshape2)
finalData_melted <- melt(finalData, id = c("subject", "activity"))
finalData_mean <- dcast(finalData_melted, subject + activity ~ variable, mean)

write.table(finalData_mean, "final_output.txt", row.names = FALSE)
write.table(names(finalData_mean), "colnames.csv", row.names = F, quote=F )
