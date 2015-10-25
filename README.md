# Getting and Cleaning Data

## Course Project

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## How to run the analysis

Run ```source('run_analysis.R')```. It will download the zipped data file to a temporary directory and unzip that file 
to your working directory, creating a folder called ```UCI HAR Dataset``` which contains all data used by the program.
It will then use that data to generate a new file ```tidy_data.txt``` in your working directory.

## Dependencies

```run_analysis.R``` will install any non-existent dependencies automatically. It depends on ```data.table``` and ```plyr```. 