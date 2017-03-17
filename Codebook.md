# Summary

[run_analysis.R](https://github.com/bensylve/coursera_get_clean_data_project/blob/master/run_analysis.R) is the file that contains this script. For simplicity's sake I kept the script to one function.

The script operates in x steps:

* Download the data set from the web and unzip the them into a directory for processing
* Get the column names and meta-data to label the rows and columns
* Tidy up the test data set
* Tidy up the train data set
* Combine the test and train data sets and export the data to a text file
* Aggregate the data and export the aggregated data to a text file

## Download the data set
```R
  if (!file.exists("UCI HAR Dataset")) {
    # download the data
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    zipfile="UCI HAR Dataset.zip"
    message("Downloading data")
    download.file(fileURL, destfile=zipfile)
    unzip(zipfile)
  }
``` 
## Get the column names and meta-data to label the rows and columns
```R 
  activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
  features <- read.table("./UCI HAR Dataset/features.txt")
  
  featuresDT <- setDT(features)
  columns <- featuresDT[like(V2,"mean()") | like(V2,"std()")]$V1
  columnNames <- featuresDT[like(V2,"mean()") | like(V2,"std()")]$V2
```  
## Tidy up the test data set
```R   
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
```    
## Tidy up the train data set
```R    
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
``` 
##Combine the test and train data sets and export the data to a text file
```R 
  combinedSet <- rbind(testSetWithDesc,trainingSetWithDesc)
  
  write.table(combinedSet,"disaggregate_combined_dataset.txt")
``` 
##Aggregate the data and export the aggregated data to a text file
```R 
  aggregatedResults <- aggregate(. ~subject+activityNumber+activityName, data=combinedSet, mean, na.rm=TRUE)
  
  write.table(aggregatedResults,"aggregate_combined_dataset.txt")
``` 
