# plotElapsedTimeHadoop.R -- R script to plot elapsed time results from WordCountHadoop
# Project OrcTests
#
# Created by jthywiss on Oct 13, 2017.
#
# Copyright (c) 2017 The University of Texas at Austin. All rights reserved.
#
# Use and redistribution of this file is governed by the license terms in
# the LICENSE file found in the project's top-level directory and also found at
# URL: http://orc.csres.utexas.edu/license.shtml .
#

library(dplyr, warn.conflicts = FALSE)
library(ggplot2)

source("analysis.R")

runNumber <- commandArgs(trailingOnly = TRUE)[1]
warmupReps <- 9
fileSize <- 0.151945899 # GB

allRepetitionTimes <- read.csv("repetition-times.csv")
names(allRepetitionTimes) <- c("program", "numInputFiles", "dOrcNumRuntimes", "repetitionNumber", "elapsedTime")

warmRepetitionTimes <- allRepetitionTimes[allRepetitionTimes$repetitionNumber >= (warmupReps + 1),]

elapsedTimeSummary <- warmRepetitionTimes[!is.na(warmRepetitionTimes$dOrcNumRuntimes),] %>%
  group_by(program, numInputFiles, dOrcNumRuntimes) %>%
  summarise(nElapsedTime = length(elapsedTime), meanElapsedTime = mean(elapsedTime), sdElapsedTime = sd(elapsedTime), seElapsedTime = sdElapsedTime / sqrt(nElapsedTime)) %>%
  rowwise() %>% mutate(sizeInput = numInputFiles * fileSize)


# Plot elapsed times

for (currProgram in unique(elapsedTimeSummary$program)) {
  ggplot(elapsedTimeSummary[elapsedTimeSummary$program == currProgram,], aes(x = sizeInput, y = meanElapsedTime, group = factor(dOrcNumRuntimes), colour = factor(dOrcNumRuntimes), shape = factor(dOrcNumRuntimes))) +
  geom_point(size = 3) +
  stat_summary(fun.y = mean, geom = "line") +
  ggtitle(paste(currProgram, "Run", runNumber)) +
  xlab("Input size (GB)") +
  labs(colour = "Cluster size [Number of HDFS replicas]", shape = "Cluster size [Number of HDFS replicas]") +
  scale_y_continuous(name = "Elapsed time (s)", labels = function(n){format(n / 1000000, scientific = FALSE)}) +
  expand_limits(y = 0.0) +
  geom_errorbar(aes(ymax = meanElapsedTime + seElapsedTime, ymin = meanElapsedTime - seElapsedTime), width = 0.2, alpha = 0.35, position = "dodge") +
  theme_minimal() +
  theme(legend.justification = c(0, 1), legend.position = c(0, 1))

  ggsave(paste0("elapsedTime_", currProgram, ".pdf"), width = 7, height = 7)
}


# # Plot elapsed times: Hadoop vs. Mixed Orc-Java at 6 nodes
#
# program <- c("Java+dOrc", "Hadoop")
# meanElapsedTime <- c(15352089,130345826.3-44750000)
# seElapsedTime <- c(38011,496857)
# hadoopVsMixed <- data.frame(program,meanElapsedTime,seElapsedTime)
#
# {
#   ggplot(hadoopVsMixed, aes(x = program, y = meanElapsedTime, group = 1, colour = program, fill = program)) +
#   geom_col() +
#   xlab("Program variant") +
#   scale_y_continuous(name = "Elapsed time (s)", labels = function(n){format(n / 1000000, scientific = FALSE)}) +
#   expand_limits(y = 0.0) +
#   geom_errorbar(aes(ymax = meanElapsedTime + seElapsedTime, ymin = meanElapsedTime - seElapsedTime), colour = "black", width = 0.2, alpha = 0.35, position = "dodge") +
#   theme_minimal() +
#   theme(legend.position = "none", axis.text=element_text(size=24), axis.title=element_text(size=28))
#   ggsave("wordcount-elapsedTime-hadoop-mixed-6.pdf", width = 7, height = 7)
# }
