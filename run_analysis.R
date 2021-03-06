run_analysis <- function()
{
  if (!file.exists("UCI HAR Dataset")) {
    # download the data
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    zipfile="UCI HAR Dataset.zip"
    message("Downloading data")
    download.file(fileURL, destfile=zipfile)
    unzip(zipfile)
  }
  
  activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
  features <- read.table("./UCI HAR Dataset/features.txt")
  
  featuresDT <- setDT(features)
  columns <- featuresDT[like(V2,"mean()") | like(V2,"std()")]$V1
  columnNames <- featuresDT[like(V2,"mean()") | like(V2,"std()")]$V2
  
  subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
  names(subjectTest) <- c("subject")
  
  testSet <- read.table("./UCI HAR Dataset/test/X_test.txt")
  testSetLimitedColumns <- testSet[,columns]
  names(testSetLimitedColumns) <- columnNames
  
  #testSetLimitedColumns[1:length(columns)] <- lapply(testSetLimitedColumns[1:length(columns)], as.numeric)
  
  testSetLabels <- read.table("./UCI HAR Dataset/test/y_test.txt")
  testSetLabelsWithDesc <- merge(testSetLabels,activityLabels, by="V1")
  names(testSetLabelsWithDesc) <- c("activityNumber","activityName")
  testSetWithDesc <- cbind(subjectTest,testSetLabelsWithDesc,testSetLimitedColumns)
  #testSetWithDesc$source <- "test"
  
  subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
  names(subjectTrain) <- c("subject")

  trainingSet <- read.table("./UCI HAR Dataset/train/X_train.txt")
  trainingSetLimitedColumns <- trainingSet[,columns]
  names(trainingSetLimitedColumns) <- columnNames
  trainingSetLabels <- read.table("./UCI HAR Dataset/train/y_train.txt")
  trainingSetLabelsWithDesc <- merge(trainingSetLabels,activityLabels, by="V1")
  names(trainingSetLabelsWithDesc) <- c("activityNumber","activityName")
  trainingSetWithDesc <- cbind(subjectTrain,trainingSetLabelsWithDesc,trainingSetLimitedColumns)
  #trainingSetWithDesc$source <- "train"
  
  combinedSet <- rbind(testSetWithDesc,trainingSetWithDesc)
  
  write.table(combinedSet,"disaggregate_combined_dataset.txt", row.names = FALSE)
  
  aggregatedResults <- aggregate(. ~subject+activityNumber+activityName, data=combinedSet, mean, na.rm=TRUE)
  
  write.table(aggregatedResults,"aggregate_combined_dataset.txt", row.names = FALSE)
}