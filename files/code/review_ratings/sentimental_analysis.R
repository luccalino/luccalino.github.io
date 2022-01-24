# Clear environment
remove(list = ls())

# Loading packages
library(lubridate)
library(plyr)

library(gridExtra) #viewing multiple plots together
library(tidytext) #text mining
library(readr)
library(Rmisc)
library(stargazer)
library(qdap)


# Loading packages (install if not yet installed)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest, tidyverse, httr, svMisc, ggmap, tmaptools, dplyr)

# Clear environment to start from a white page
remove(list = ls())

# Set working directory
setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Projects/restaurants/copenhagen")

# Define some colors to use throughout
my_colors <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00")

# Reading data
files <- list.files(path = "data", pattern = "*.csv", full.names = T, recursive = T)
db <- sapply(files, read_csv, simplify=FALSE) %>% 
  bind_rows(.id = "url")








# Check for duplicates
check_for_duplicates <- duplicated(db$Review_text)
db <- unique(db)

db$temp <- substr(db$url, 41,100)
db$resto_type <- gsub("/.*","",db$temp)
db$resto_name <- gsub(".*/","",sub("_reviews.csv","",db$temp))
db$url <- NULL
db$temp <- NULL

# Rescale ranking
db$Rating <- db$Rating/10

counts_per_type <- count(db,c('db$resto_type'))
counts_per_resto <- count(db,c('db$resto_name'))

# Plot mean rating per price category
mean_per_type <- aggregate(db[, 3], list(db$resto_type), mean)
mean_per_type$Group.1 <- gsub("_"," ",mean_per_type$Group.1)
mean_per_type$Group.1 <- factor(mean_per_type$Group.1, levels = mean_per_type$Group.1[order(-mean_per_type$Rating)])

ggplot(data = mean_per_type, aes(x = Group.1, y = Rating)) +
  geom_line(aes(group = 1)) + 
  labs(x = "Price type") +
  labs(y = "Average rating") +
  labs(title = "Average rating per price category")

#mean(database$Rating, trim = 0, na.rm = FALSE)s
#median(database$Rating, trim = 0, na.rm = FALSE)

# Reformat dates
#database$Review_Date <- as.Date(substr(database$Review_Date, 10, 40), format = "%B %d, %Y")
#database$Visiting_date <- myd(database$Visiting_date, truncated = 1)

### DATA CONDITIONING ###

# Function to expand contractions in an English-language source
fix.contractions <- function(doc) {
  # "won't" is a special case as it does not expand to "wo not"
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", " not", doc)
  doc <- gsub("'ll", " will", doc)
  doc <- gsub("'re", " are", doc)
  doc <- gsub("'ve", " have", doc)
  doc <- gsub("'m", " am", doc)
  doc <- gsub("'d", " would", doc)
  # 's could be 'is' or could be possessive: it has no expansion
  doc <- gsub("'s", "", doc)
  return(doc)
}

# Fix (expand) contractions
db$Review_text <- sapply(db$Review_text, fix.contractions)

# Function to remove special characters
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]", " ", x)

# Remove special characters
db$Review_text <- sapply(db$Review_text, removeSpecialChars)

# Convert everything to lower case
db$Review_text <- sapply(db$Review_text, tolower)

### SENTIMEN ANALYSIS
library(SentimentAnalysis)
sentiment <- analyzeSentiment(db$Review_text)

db$sentiment1 <- sentiment$SentimentQDAP
db$wordcount <- sentiment$WordCount
summary <- summarySE(db, measurevar = "sentiment1", groupvars = c("resto_type","Rating"))
summary_stats <- summarySE(db, measurevar = "Rating", groupvars = c("resto_type"))
summary_wordcount <- summarySE(db, measurevar = "wordcount", groupvars = c("resto_type"))
summary_stats$wordcount <- summary_wordcount$wordcount

# Summary statistics
library(xtable)
#print.xtable(xtable(head(summary_stats)), auto = TRUE, file = "/Users/laz/Dropbox/Studies/UNISG/Psychology_of_food/summary_stats.txt")

# The errorbars overlapped, so use position_dodge to move them horizontally
pd <- position_dodge(0.1) # move them .05 to the left and right

ggplot(summary, aes(x=Rating, y=sentiment1, colour=resto_type, group=resto_type)) + 
  #geom_errorbar(aes(ymin=sentiment1-se, ymax=sentiment1+se), colour="black", width=.1, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size=3, shape=21, fill="white") + # 21 is filled circle
  xlab("Numeric review score") +
  ylab("Verbal review score") +
  theme(
    axis.title.x = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.title.y = element_text(size = 10),
    axis.text.y = element_text(size = 10)) +
  scale_colour_hue(name="Restaurant category",    # Legend label, use darker colors
                   breaks=c("Cheap_eats", "Mid_range", "Fine_dining"),
                   labels=c("Cheap eats", "Mid range", "Fine dining"),
                   l=40) +                    # Use darker colors, lightness=40
  ggtitle("") +
  theme_bw() +
  theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15), axis.title.y = element_text(size=15), axis.title.x = element_text(size=15)) +
  theme(legend.justification=c(1,0),
        legend.position=c(0.99,0.09))               # Position legend in bottom right
  ggsave("/Users/laz/Dropbox/Studies/UNISG/Psychology_of_food/plot1.pdf", width = 30, height = 20, units = "cm")

ggplot(data = mean_per_type, aes(x = Group.1, y = Rating)) +
  geom_line(aes(group = 1)) + 
  labs(x = "Price type") +
  labs(y = "Average rating") +
  labs(title = "Average rating per price category")

### TEXT MINING ###

# Unnest and remove stop, undesirable and short words
review_words_filtered <- db %>%
  unnest_tokens(word, Review_text) %>%
  anti_join(stop_words) %>%
  distinct() 

# Top words
review_words_filtered %>%
  count(word, sort = TRUE) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot() +
  geom_col(aes(word, n), fill = my_colors[4]) +
  theme(legend.position = "none", 
        plot.title = element_text(hjust = 0.5),
        panel.grid.major = element_blank()) +
  xlab("") + 
  ylab("Word Count") +
  ggtitle("Most Frequently Used Words in Restaurant Reviews") +
  coord_flip()


# Bigram Network

db1 <- db[db[, "Rating"] == "5",]
db_bigrams <- db1[db1[, "resto_type"] == "Cheap_eats",] %>%
  unnest_tokens(bigram, Review_text, token = "ngrams", n = 2)

library(dplyr)
library(tidyr)
bigrams_separated <- db_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

undesired_words <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "10", "11", "00", "visiting", "copenhagen", "tables", "fantastic", "highly", "recommend", "recommended",
                     "banana", "joe", "krebsegaarden", "trip", "advisor", "ben", "marv", "floor", "8th", "foodball", "stadium", "olive", "kitchen",
                     "absolute", "noon", "owners", "morton", "claus", "tripadvisor", "decided", "round", "freshness", "little", "children",
                     "tasty")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% undesired_words) %>%  
  filter(!word2 %in% undesired_words) 

bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)
bigram_counts

library(igraph)

bigram_graph <- bigram_counts %>%
  filter(n > 25) %>%
  graph_from_data_frame()
bigram_graph

# Draw graph
library(ggraph)

set.seed(2016)

a <- grid::arrow(type = "closed", length = unit(.09, "inches"))

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = TRUE,
                 arrow = a, end_cap = circle(0.1, 'mm')) +
  geom_node_point(color = "black", size = 1) +
  geom_node_text(aes(label = name), vjust = 0.5, hjust = 0.5, size=6, repel = TRUE) +
  theme_void() +
  ggtitle("") +
  ggsave("/Users/laz/Dropbox/Studies/UNISG/Psychology_of_food/network_cheap_eats.pdf", width=14, height=9)

tot_nodes <- sort(degree(bigram_graph, mode = "total"), decreasing=TRUE)
tot_nodes
out_nodes <- sort(degree(bigram_graph, mode = "out"), decreasing=TRUE)
out_nodes
in_nodes <- sort(degree(bigram_graph, mode = "in"), decreasing=TRUE)
in_nodes











# Plot
ggplot(data = database, aes(x = Visiting_date, y = Rating)) +
  geom_line(color = "#00AFBB", size = 2)

# Cleaning function
Clean_String <- function(string){
  # Lowercase
  temp <- tolower(string)
  # Remove everything that is not a number or letter (may want to keep more 
  # stuff in your actual analyses). 
  temp <- stringr::str_replace_all(temp,"[^a-zA-Z\\s]", " ")
  # Shrink down to just one white space
  temp <- stringr::str_replace_all(temp,"[\\s]+", " ")
  # Split it
  temp <- stringr::str_split(temp, " ")[[1]]
  # Get rid of trailing "" if necessary
  indexes <- which(temp == "")
  if(length(indexes) > 0){
    temp <- temp[-indexes]
  } 
  return(temp)
}

# Sentimental Analysis
#install.packages("SentimentAnalysis")
library(SentimentAnalysis)

sentiment <- analyzeSentiment(database$Review_text)

coll_senti_mean <- aggregate(sentiment$SentimentQDAP,list(database$Rating),mean)
coll_senti_median <- aggregate(sentiment$SentimentQDAP,list(database$Rating),median)


test_plot1 <- plot(coll_senti_median$Group.1,coll_senti_median$x,type="o",col="red", 
                   xlab = "Review ranking", ylab = "Review sentiment score (mean)")
              lines(coll_senti_mean$Group.1,coll_senti_mean$x,type="o",col="green")

test_plot2 <- plot(database$Rating,sentiment$SentimentQDAP,pch = 19,col="red",
                   xlab = "Rating", ylab = "Sentiment")
test_plot3 <- plot(database$Visiting_date,sentiment$SentimentQDAP,pch = 19,col="red",
                   xlab = "Visiting date", ylab = "Sentiment")

comp <- compareToResponse(sentiment, raw_data$Rating)

# Part 1: https://www.datacamp.com/community/tutorials/R-nlp-machine-learning
# Part 2: https://www.datacamp.com/community/tutorials/sentiment-analysis-R

