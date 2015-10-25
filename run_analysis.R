# Create one R script called run_analysis.R that does the following:
# 	1. Merges the training and the test sets to create one data set.
# 	2. Extracts only the measurements on the mean and standard deviation for each measurement
# 	3. Uses descriptive activity names to name the activities in the data set.
# 	4. Appropriately lables the data set with descriptive activity names.
# 	5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Check if required packages are installed
if ('data.table' %in% rownames(installed.packages()) == FALSE) { install.packages('data.table') }
if ('plyr' %in% rownames(installed.packages()) == FALSE) { install.packages('plyr') }

# Load required packages
require(data.table)
require(plyr)

# Download data to tempfile() and unzip to working directory
dataUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
dataZipped <- tempfile()
download.file(dataUrl, dataZipped, method = 'curl')
unzip(zipfile = dataZipped, exdir = getwd())

# Initialize directories and files
dataPath <- paste(getwd(), 'UCI HAR Dataset', sep = '/')
featureFile <- file.path(dataPath, 'features.txt')
activityLabelsFile <- file.path(dataPath, 'activity_labels.txt')
trainFileX <- file.path(dataPath, 'train', 'X_train.txt')
trainFileY <- file.path(dataPath, 'train', 'Y_train.txt')
subjectTrainFile <- file.path(dataPath, 'train', 'subject_train.txt')
testFileX <- file.path(dataPath, 'test', 'X_test.txt')
testFileY <- file.path(dataPath, 'test', 'Y_test.txt')
subjectTestFile <- file.path(dataPath, 'test', 'subject_test.txt')
writeFile <- file.path(paste(getwd(), 'tidy_data.txt', sep = '/'))

# Load raw data
features <- read.table(featureFile)[, 2]
activityLabels <- read.table(activityLabelsFile)[, 2]
trainX <- read.table(trainFileX)
trainY <- read.table(trainFileY)
subjectTrain <- read.table(subjectTrainFile)
testX <- read.table(testFileX)
testY <- read.table(testFileY)
subjectTest <- read.table(subjectTestFile)

# Extract only the measurements on the mean and standard deviation for each measurement.
extractFeatures <- grepl('mean|std', features)

names(testX) <- features
names(trainX) <- features

testX <- testX[, extractFeatures]
trainX <- trainX[, extractFeatures]

# Load activity labels
testY[, 2] <- activityLabels[testY[, 1]]
names(testY) <- c('ActivityID', 'ActivityLabel')
names(subjectTest) <- 'Subject'

# Load activity data
trainY[, 2] <- activityLabels[trainY[, 1]]
names(trainY) <- c('ActivityID', 'ActivityLabel')
names(subjectTrain) <- 'Subject'

# Bind data
testData <- cbind(as.data.table(subjectTest), testY, testX)
trainData <- cbind(as.data.table(subjectTrain), trainY, trainX)

# Merge test and train data
data <- rbind(testData, trainData)

# Remove parentheses from names
names(data) <- gsub('\\(|\\)', '', names(data), perl = TRUE)

# Make syntactically valid names
names(data) <- make.names(names(data))

# Make names more relevant
names(data) <- gsub('Acc', 'Acceleration', names(data))
names(data) <- gsub('Gyro', 'AngularMomentum', names(data))
names(data) <- gsub('GyroJerk', 'AngularVelocity', names(data))
names(data) <- gsub('Mag', 'Magnitude', names(data))
names(data) <- gsub('^t', 'TimeDomain', names(data))
names(data) <- gsub('^f', 'FrequencyDomain', names(data))
names(data) <- gsub('\\.mean', '.Mean', names(data))
names(data) <- gsub('\\.std', '.StandardDeviation', names(data))
names(data) <- gsub('Freq\\.', 'Frequency', names(data))
names(data) <- gsub('Freq$', 'Frequency', names(data))

idLabels <- c('Subject', 'ActivityID', 'ActivityLabel')
dataLabels <- setdiff(colnames(data), idLabels)
meltedData <- melt(data, id = idLabels, measure.vars = dataLabels)

# Apply mean function to dataset using dcast function
tidyData <- dcast(meltedData, Subject + ActivityLabel ~ variable, mean)

write.table(tidyData, file = writeFile, row.names = FALSE)
