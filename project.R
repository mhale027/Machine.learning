
---
title: "Practical Machine Learning - Peer Assessment"
author: "Matthew Hale"
date: "Monday, October 19, 2015"
output: html_document
---
library(knitr)

```{r global_opts, echo=FALSE}
knitr::opts_chunk$set(echo=FALSE, cache=TRUE, message=FALSE, warning=FALSE)
```

##Summary

In this project I will be using the testing and training data sets which have been graciously provided at [http://groupware.les.inf.puc-rio.br/har](http://groupware.les.inf.puc-rio.br/har), to create a predictive model for the "classe" variable. This type of machine learning is used by companies like Nike, Jawbone, and Fitbit to predict the activities of subjects from the large amount of data recorded by the highly accurate sensors in smartphones. 

##Data Analysis

First, the data must be read into a data frame:

```{r raw_data}
data.train <- read.csv("pml-training.csv")
data.test <- read.csv("pml-testing.csv")
```

Next, I remove the columns which are dominated by NA values, and then partition the data into the training and testing sets 

```{r}
library(caret)
library(randomForest)
library(ada)
data.train <- data.train[,-c(1:7)]
nas <- grep("19216", apply(data.train,2,function(x) sum(is.na(x))))
data.train <- data.train[,-nas]
data.test <- data.test[,-nas]
inTrain <- createDataPartition(data.train$classe, p=.6, list=FALSE)
training <- data.train[inTrain,]
testing <- data.train[-inTrain,]
```

The first seven variables do not contribute to the physical representation of the system, and must be removed. The random forest's main benefit is its accuracy, but it is quite slow to train. The nearZeroVar function determines the variables which contribute nearly zero variance to the data. Since they likely have little influence on the prediction, I remove them, but only for the random forest's training set.

```{r}
nzv <- nearZeroVar(training)
training.rf <- training[,-nzv]
testing.rf <- testing[,-nzv]
```

##Model Selection
The machine learning methods I compare here are random forests, boosting with adaboost, and linear discriminant analysis with lda.
```{r}
model.rf <- train(classe~.,method="rf",data=training.rf, prox=TRUE)
model.ada <- train(classe~.,method="ada",data=training, verbose=FALSE)
model.lda <- train(classe.,method="lda",data=training)
```

##Testing
First predictions need to be made on the testing set:
```{r}
pred.rf <- predict(model.rf, testing.rf)
pred.ada <- predict(model.ada, testing)
pred.lda <- predict(model.lda, testing)
```
#Confusion Matrix
```{r, echo=TRUE}
table.rf <- table(pred.rf, testing$classe)
table.ada <- table(pred.ada, testing$classe)
table.lda <- table(pred.lda, testing$classe)
```
##Conclusion
