##Download the data
if(!file.exists("./data.project")){dir.create("./data.project")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="C:/Users/Elisa/Documents/data science/data.project/UCI HAR Dataset.zip")
unzip(zipfile="C:/Users/Elisa/Documents/data science/data.project/UCI HAR Dataset.zip",exdir="./data.project")

##load packages that we are going to use
library(dplyr)
library(data.table)
library(tidyr)

## lets read files
filespath<-"C:/Users/Elisa/Documents/data science/data.project/UCI HAR Dataset"
dataSubTrain<-read.table(file.path(filespath,"train","subject_train.txt"))
dataSubTest<-read.table(file.path(filespath,"test","subject_test.txt"))
XTest<-read.table(file.path(filespath,"test","X_test.txt"))
YTest<-read.table(file.path(filespath,"test","Y_test.txt"))
XTrain<-read.table(file.path(filespath,"train","X_train.txt"))
YTrain<-read.table(file.path(filespath,"train","Y_train.txt"))

##Merge the data 

dataSubject<-rbind(dataSubTrain,dataSubTest)
dataActivities<-rbind(YTrain,YTest)
dataFeatures<-rbind(XTrain,XTest)

names(dataSubject)<-c("subject")
names(dataActivities)<-c("activity")
Features<-read.table(file.path(filespath,"features.txt"),head=FALSE)
names(dataFeatures)<-Features$V2
dataUnited<-cbind(dataSubject,dataActivities)
Datas<-cbind(dataFeatures,dataUnited)

##mean and standar deviation for each mesurament

Mean<-Features$V2[grep("mean\\(\\)|std\\(\\)",Features$V2)]
selectNames<-c(as.character(Mean),"subject","activity")
Datas<-subset(Datas,select=selectNames)

## Name activities in the data set
Labels<-read.table(file.path(filespath,"activity_labels.txt"),header=FALSE)
Labels[,2]<-as.character(Labels[,2])
Datas$activity <- factor(Datas$activity, levels = Labels[,1], labels = Labels[,2])
Datas$subject<-as.factor(Datas$subject)

names(Datas)<-gsub('Acc',"Acceleration",names(Datas))
names(Datas)<-gsub('Gyro',"AngularSpeed",names(Datas))
names(Datas)<-gsub('Mag',"Magnitude",names(Datas))
names(Datas)<-gsub('^t',"time",names(Datas))
names(Datas)<-gsub('\\-std',"-StandardDeviation",names(Datas))
names(Datas)<-gsub('^f',"Frequency",names(Datas))
names(Datas)<-gsub('GyroJerk',"AngularAcceleration",names(Datas))

## Another data set with the average on it  
Datasmelt<-melt(Datas,id=c("subject","activity"))
DatasAveg<-dcast(Datasmelt,subject+activity~variable,mean)
write.table(DatasAveg,file="tidy.txt",row.names=FALSE,quote=FALSE)