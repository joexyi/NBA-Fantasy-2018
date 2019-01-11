#R Script for Project 2


library(tidyverse)
library(dplyr)
library(reshape2)


draft2018 <- read.csv(file="D:/Work/UNCBiostatistics/Fall2018/611/project2-joexyi/Draft_2018_Projections.csv", header=TRUE, sep=",")

#Fix the FT% and FG%

draft2018$temp1 <- substr(draft2018$FG.,1,4)
draft2018$temp2 <- substr(draft2018$FT.,1,4)
draft2018$FGp <- as.numeric(draft2018$temp1)
draft2018$FTp <- as.numeric(draft2018$temp2)
draft2018$X3PM <- as.numeric(draft2018$X3PM)

nbascale <- function(x) {
  scaled <- (x - mean(x)) / sd(x)
}

# Loop to normalize desired 9 categories
new <- draft2018
for (nm in names(draft2018)) {
  if (!is.numeric(draft2018[, nm])) next
  nnm <- paste("n",nm, sep='')
  new[, nnm] <- nbascale(draft2018[, nm])
}

# Select only the desired columns
normdraft <- select(new, PLAYER, POS, TEAM, GP, MPG, nFGp, nFTp, nX3PM, nPTS, nTREB, nAST, nSTL, nBLK, nTO)
normdraft$nTO = -normdraft$nTO
write.table(normdraft, file="D:/Work/UNCBiostatistics/Fall2018/611/project2-joexyi/normdraft.dat")


#Turnovers are negative thus when normalized, you need to multiply by -1.
punt <- function(x) {
  for (i in seq_along(normdraft$PLAYER)) {
    if(x %in% normdraft$PLAYER[[i]]) {
      vec <-c(normdraft$nFGp[i], normdraft$nFTp[i], normdraft$nX3PM[i], normdraft$nPTS[i], normdraft$nTREB[i], normdraft$nAST[i], normdraft$nSTL[i], normdraft$nBLK[i], -normdraft$nTO[i])
      rk <- rank(vec)
      normdraft1 <- normdraft[, 6:14]
      normdraft$score <- rowSums(normdraft1[, -which(rk <=3)], na.rm = FALSE)  
      return(normdraft[order(-normdraft$score),])
    }
    else next
  }
}

USG <- read.csv(file="D:/Work/UNCBiostatistics/Fall2018/611/project2-joexyi/usage_2018.csv", header=TRUE, sep=",")

# James Harden 

A <- "James Harden"
A <- "Kevin Durant"
A <- "Karl-Anthony Towns"
A <- "Nikola Jokic"
A <- "Kawhi Leonard"
A <- "Damian Lillard"
A <- "Lebron James"
A <- "Nikola Jokic"
B <- "Damian Lillard"
A <- punt(A)
A_usg <- left_join(A, USG[, c("PLAYER", "USG_")], by="PLAYER")
write.csv(A_usg, file="D:/NBA/Draft 2018/A.csv")


write.csv(normdraft, file="D:/NBA/Draft 2018/normdraft.csv")

B <- "Kevin Durant"
B <- punt(B)
B_usg <- left_join(B, USG[, c("PLAYER", "USG_")], by="PLAYER")
write.csv(B_usg, file="D:/NBA/Draft 2018/B.csv")












#Bar charts looking at Anthony Davis comparison
AD.data <- melt(AD_usg, id=c("PLAYER", "POS", "TEAM", "GP", "MPG", "USG_"))
ggplot(subset(AD.data, PLAYER=="Anthony Davis" & variable!="score") , aes(x=variable, y=value)) +
  geom_col() +
  labs(
    title ="Anthony Davis Statistical Breakdown",
    x = "Categories",
    y = "Normalized Values"
  )+
  theme(plot.title = element_text(hjust = 0.5)) 
ggsave("ADbar.png")

ggplot(subset(AD.data, PLAYER=="Giannis Antetokounmpo" & variable!="score") , aes(x=variable, y=value)) +
  geom_col() +
  labs(
    title ="Giannis Antetokounmpo Statistical Breakdown",
    x = "Categories",
    y = "Normalized Values"
  )+
  theme(plot.title = element_text(hjust = 0.5)) 
ggsave("GAbar.png")


#Pie Charts looking at Stephen Curry comparisons
SC.data <- melt(SC_usg, id=c("PLAYER", "POS", "TEAM", "GP", "MPG", "USG_"))


SC.bar <-ggplot(subset(SC.data, PLAYER=="Stephen Curry" & variable!="score") , aes(x="", y=value, fill=variable))+
  geom_bar(width = 1, stat="identity") +
  labs(
    title ="Stephen Curry Statistical Breakdown",
    y = "Normalized Values"
  )+
  theme(plot.title = element_text(hjust = 0.5))

SC.pie <- SC.bar + coord_polar("y", start=0) 
ggsave("SCpie.png")

JH.bar <-ggplot(subset(SC.data, PLAYER=="James Harden" & variable!="score") , aes(x="", y=value, fill=variable))+
  geom_bar(width = 1, stat="identity") +
  labs(
    title ="James Harden Statistical Breakdown",
    y = "Normalized Values"
  )+
  theme(plot.title = element_text(hjust = 0.5))

JH.pie <- JH.bar + coord_polar("y", start=0) 
ggsave("JHpie.png")
