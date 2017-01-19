#Get the data

#create folder for all assignment files if it doesn't exist:
if(!file.exists("./Course3ProgAssignment")) {dir.create("./Course3ProgAssignment")}

#download the dataset zip folder:
fileUrl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./SmartphoneDataSet.zip", method="curl")

#unzip the folder:
unzip(zipfile="SmartphoneDataSet.zip", exdir="./data")

#Read the data

#read the activity files
testActivities <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
trainActivities <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")

#read the subject files
testSubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
trainSubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#read the features files
testFeatures <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
trainFeatures <- read.table("./data/UCI HAR Dataset/train/X_train.txt")

#Step 1) Merge the training and test data sets

#concatenate data tables by rows
dataSubject <- rbind(trainSubjects, testSubjects)
dataActivity <- rbind(trainActivities, testActivities)
dataFeatures <- rbind(trainFeatures, testFeatures)

##set names to variables
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
dataFeaturesNames <- read.table("./data/UCI HAR Dataset/features.txt")
names(dataFeatures) <- dataFeaturesNames$V2

#merge columns to get one dataframe for all data
dataCombine <- cbind(dataSubject, dataActivity)
data <- cbind(dataFeatures, dataCombine)

#Step 2) Extract only measurements on mean and standard deviation

#subset name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#subset the 'data' data frame by selected names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
data <-subset(data,select=selectedNames)

#Step 3) Use descriptive activity names to name the activities in the data set

#read descriptive activity names from "activity_labels.txt" file
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

#update values with correct activity names
trainActivities[, 1] <- activityLabels[trainActivities[, 1], 2]

#correct column name
names(trainActivities) <- "activity"

#Step 4) Appropriately label the data set with descriptive variable names

#[In step 1, activity, subject and features were labeled using descriptive names.
#In this step, names of features will be labeled using descriptive variable names.]
#prefix t is replaced by time
#Acc is replaced by Accelerometer
#Gyro is replaced by Gyroscope
#prefix f is replaced by frequency
#Mag is replaced by Magnitude
#BodyBody is replaced by Body

names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

#5)create a second, independent tidy data set and output it
library(plyr);
dataTidy<-aggregate(. ~subject + activity, data, mean)
dataTidy<-dataTidy[order(dataTidy$subject,dataTidy$activity),]
write.table(dataTidy, file = "tidydata.txt",row.name=FALSE)