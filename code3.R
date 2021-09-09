library("data.table")
library("reshape2")

packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

label <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

training <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(training, colnames(training), measurements)
trainact <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainsubj <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
training <- cbind(trainsubj, trainact, training)

testing <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(testing, colnames(testing), measurements)
testact <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testsubj <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
testing <- cbind(testsubj, testact, testing)

mixed <- rbind(training, testing)

mixed[["Activity"]] <- factor(mixed[, Activity], levels = label[["classLabels"]], labels = label[["activityName"]])

mixed[["SubjectNum"]] <- as.factor(mixed[, SubjectNum])
mixed <- reshape2::melt(data = mixed, id = c("SubjectNum", "Activity"))
mixed <- reshape2::dcast(data = mixed, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = mixed, file = "cleanData.csv", quote = FALSE)
