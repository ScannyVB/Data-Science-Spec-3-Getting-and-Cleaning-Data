library(data.table)
library(reshape2)

# Set Working Directory and Download Data
path <- getwd()
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Load Activity Labels and Features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load Training Datasets
trainData <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
setnames(trainData, colnames(trainData), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
trainData <- cbind(trainSubjects, trainActivities, trainData)

testData <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
setnames(testData, colnames(testData), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
testData <- cbind(testSubjects, testActivities, testData)


combinedData <- rbind(trainData, testData)


combinedData[["Activity"]] <- factor(combinedData[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])

combinedData[["SubjectNum"]] <- as.factor(combinedData[, SubjectNum])
combinedData <- melt(data = combinedData, id = c("SubjectNum", "Activity"))
combinedData <- dcast(data = combinedData, SubjectNum + Activity ~ variable, fun.aggregate = mean)


fwrite(x = combinedData, file = "tidyData.txt", quote = FALSE)
