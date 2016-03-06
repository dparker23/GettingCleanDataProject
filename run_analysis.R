#Here are the data for the project: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
#You should create one R script called run_analysis.R that does the following.
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
library(plyr)
library(knitr)

####  1. Merge the training and the test sets to create one data set.
#load data
rawActivityTest  <- read.table("./data/UCI HAR Dataset/test/Y_test.txt", header = FALSE)
rawActivityTrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt", header = FALSE)
rawSubjectTest  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
rawSubjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
rawFeaturesTest  <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
rawFeaturesTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
featureNames <- read.table("./data/UCI HAR Dataset/features.txt")
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

#concat data
dataSubject <- rbind(rawSubjectTrain, rawSubjectTest)
dataActivity<- rbind(rawActivityTrain, rawActivityTest)
dataFeatures<- rbind(rawFeaturesTrain, rawFeaturesTest)

#name columns
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
names(dataFeatures)<- featureNames$V2
names(activityLabels)<- c("activity", "activitylabel")

#merge data
Data <- cbind(dataSubject, dataActivity, dataFeatures)

###2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
ExtractData <- Data[grep(("subject|activity|mean|std"),colnames(Data))]
ExtractData <- ExtractData[, -grep("Freq", colnames(ExtractData))]

### 3. Uses descriptive activity names to name the activities in the data set
#
ExtractData <- join(activityLabels, ExtractData)

### 4. Appropriately labels the data set with descriptive variable names.
#
names(ExtractData)<-gsub("Acc", "Accelerometer.", names(ExtractData))
names(ExtractData)<-gsub("Gyro", "Gyroscope.", names(ExtractData))
names(ExtractData)<-gsub("Mag", "Magnitude.", names(ExtractData))
names(ExtractData)<-gsub("^t", "Time.", names(ExtractData))
names(ExtractData)<-gsub("^f", "Frequency.", names(ExtractData))

### 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#      of each variable for each activity and each subject.
TidyData<-aggregate(. ~subject + activity, ExtractData, FUN = "mean", simplify = TRUE)

#fix labels
names(TidyData)<-gsub("mean()", "mean_of_means", names(TidyData))
names(TidyData)<-gsub("std()", "mean_of_stds", names(TidyData))

#output tidy data
write.table(TidyData, file = "tidydata.txt",row.name=FALSE)

#generate codebook
codebook <- codebook(TidyData)
codebook_html <- format_html(codebook, toprule = 2, midrule = 1, padding =3, title = "Tidy Data")
write(codebook_html, file = "codebook.html")

