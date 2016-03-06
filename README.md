---
title: "README.md"
author: "David Parker"
date: "March 6, 2016"
output: html_document
---
# Getting and Cleaning Data: Tidy Data Class Project

## Instructions
You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Required packages
The following packages were downloaded from CRAN for this solution:

* The plyr package is required for joining data. 
* The memisc package is required for generating the codebook.

## Setup: Download the data

1.Download the data package.

```{r}
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/package.zip",method="curl")
```
2.Unzip the package.
```{r}
unzip(zipfile="./data/package.zip",exdir="./data")
```

## 1. Solution 'Merge the training and the test sets to create one data set.'

1. First load the raw data, names and labels with read.table().
```{r}
#load data
rawActivityTest  <- read.table("./data/UCI HAR Dataset/test/Y_test.txt", header = FALSE)
rawActivityTrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt", header = FALSE)
rawSubjectTest  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
rawSubjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
rawFeaturesTest  <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
rawFeaturesTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
featureNames <- read.table("./data/UCI HAR Dataset/features.txt")
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
```

2. Use rbind() for merge raw data into a logical data sets.
```{r}
#concat data
dataSubject <- rbind(rawSubjectTrain, rawSubjectTest)
dataActivity<- rbind(rawActivityTrain, rawActivityTest)
dataFeatures<- rbind(rawFeaturesTrain, rawFeaturesTest)
```

3. Use names() in order to name the column names consistant and readable.
```{r}
#name columns
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<- featureNames$V2
names(activityLabels)<- c("activity", "activitylabel")
```

4. Use cbind() to merge logical data sets into a unified data set called Data
```{r}
#merge data
Data <- cbind(dataSubject, dataActivity, dataFeatures)
```

## 2. Solution: 'Extracts only the measurements on the mean and standard deviation for each measurement.'
Create the ExtractData data.table using grep() to subset down to the required columns using the 'or' operator |.  

```{r}
ExtractData <- Data[grep(("subject|activity|mean|std"),colnames(Data))]
ExtractData <- ExtractData[, -grep("Freq", colnames(ExtractData))]
```

## 3. Solution: 'Uses descriptive activity names to name the activities in the data set.'
Use join from the plyr package to add readable activity labels.  Will join on the activity. 
```{r}
ExtractData <- join(activityLabels, ExtractData)
```

## 4. Solution: 'Appropriately labels the data set with descriptive variable names.'
Use gsub() to expand the abbreviated column names into standalone readable values. 
```{r}
names(ExtractData)<-gsub("Acc", "Accelerometer.", names(ExtractData))
names(ExtractData)<-gsub("Gyro", "Gyroscope.", names(ExtractData))
names(ExtractData)<-gsub("Mag", "Magnitude.", names(ExtractData))
names(ExtractData)<-gsub("^t", "Time.", names(ExtractData))
names(ExtractData)<-gsub("^f", "Frequency.", names(ExtractData))
```

## 5. Solution: 'From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.'

1. Use aggregate() to produce the summary table TidyData consisting of 'means of means' and 'means of std devs' for each subject/activity pair. 

```{r}
TidyData<-aggregate(. ~subject + activity, ExtractData, FUN = "mean", simplify = TRUE)
```

2. Use gsub() to fix labels to reflect calculation.

```{r}
#fix labels
names(TidyData)<-gsub("mean()", "mean_of_means", names(TidyData))
names(TidyData)<-gsub("std()", "mean_of_stds", names(TidyData))
```

3. Output TidyData set with write.table().

```{r}
#output tidy data
write.table(TidyData, file = "tidydata.txt",row.name=FALSE)
```
4. Use codebook() from the memisc package generate codebook and output it with write().

```{r}
#generate codebook
codebook <- codebook(TidyData)
codebook_html <- format_html(codebook, toprule = 2, midrule = 1, padding =3, title = "Tidy Data")
write(codebook_html, file = "codebook.html")
```
