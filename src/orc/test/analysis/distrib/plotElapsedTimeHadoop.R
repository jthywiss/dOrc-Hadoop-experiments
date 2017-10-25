# plotElapsedTimeHadoop.R -- R script to plot elapsed time results from HolmesWordCountHadoop
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

library(dplyr)
library(ggplot2)

source("analysis.R")

allRepetitionTimes <- read.csv("repetition-times.csv")
names(allRepetitionTimes) <- c("program", "numInputFiles", "dOrcNumRuntimes", "repetitionNumber", "elapsedTime")

warmRepetitionTimes <- allRepetitionTimes[allRepetitionTimes$repetitionNumber >= 3,]

elapsedTimeSummary <- warmRepetitionTimes[!is.na(warmRepetitionTimes$dOrcNumRuntimes),] %>%
  group_by(program, numInputFiles, dOrcNumRuntimes) %>%
  summarise(nElapsedTime = length(elapsedTime), meanElapsedTime = mean(elapsedTime), sdElapsedTime = sd(elapsedTime), seElapsedTime = sdElapsedTime / sqrt(nElapsedTime))


# Plot elapsed times

for (currProgram in unique(elapsedTimeSummary$program)) {
  ggplot(elapsedTimeSummary[elapsedTimeSummary$program == currProgram,], aes(x = factor(numInputFiles), y = meanElapsedTime, group = 1)) +
  geom_point() +
  stat_summary(fun.y = mean, geom = "line") +
  ggtitle(currProgram) +
  xlab("Number of files read") +
  labs(fill = "Cluster size [Number of HDFS replicas]") +
  scale_y_continuous(name = "Elapsed time (s)", labels = function(n){format(n / 1000000, scientific = FALSE)}) +
  expand_limits(y = 0) +
  geom_errorbar(aes(ymax = meanElapsedTime + seElapsedTime, ymin = meanElapsedTime - seElapsedTime), width = 0.2, alpha = 0.35, position = "dodge") +
  theme_minimal() +
  theme(legend.justification = c(0, 1), legend.position = c(0, 1))

  ggsave(paste0("elapsedTime_", currProgram, ".pdf"), width = 7, height = 7)
}
