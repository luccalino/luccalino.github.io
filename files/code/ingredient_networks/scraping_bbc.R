####################################################################
# Loading packages
library(plyr)
library(reshape2)
library(tidyr)
library(xml2)
library(rvest)
library(stringr)
library(tidyverse)
library(httr)
library(scrapeR)
library(utils)
library(plm)
library(tidytext)
library(DataCombine)
library(tm)
library(SemNetCleaner)

# Clear environment
remove(list = ls())

# Main scraping ----------------------------------------------------------------

# Vector with cuisines
cuisines <- c("american","british","caribbean","chinese","french","greek","indian",
              "italian","japanese","mediterranean","mexican","moroccan","spanish",
              "thai","turkish","vietnamese")

cuisine_list = list() 

# Generate a list of all recipes
for(c in cuisines) {
  
  # Parse html search result 
  #cuisine_url <- read_html(paste0("https://www.bbcgoodfood.com/recipes/collection/",c))
  
  #last_page <- cuisine_url %>%
  #  html_nodes(".horizontal-elements") %>%
  #  html_text() %>%
  #  as.numeric()
  
  last_page <- 5
  
  ####################################################################
  datalist = list() 
  
  for (i in 1:last_page) {
    
    webpage <- read_html(paste0("https://www.bbcgoodfood.com/recipes/collection/",c,"?platform=hootsuite%23c&page=",i-1,"#c"))
    links <- data.frame(webpage %>%
                          html_nodes(".teaser-item__title a") %>%
                          html_attr(name="href"))
    datalist[[i]] <- links 
    paste0(print(i))
    Sys.sleep(abs(rnorm(1,1,2)))
    
  }
  
  # Append the lists
  list_of_urls <- do.call(rbind, datalist)
  names(list_of_urls)[1] <- "url"
  complete_url <- as.vector(paste0("https://www.bbcgoodfood.com",list_of_urls$url))
  
  cuisine_list[[c]] <- complete_url
  
}

list_of_urls <- as.data.frame(unlist(cuisine_list))
names(list_of_urls)[1] <- "url"
list_of_urls$url <- as.character(list_of_urls$url)

# Loop through every row in list of recipes and extract desired information
for(j in 1:nrow(list_of_urls)) {
  
  ua <- user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36")
  seesion_with_ua <- html_session(list_of_urls$url[j],ua)
  
  for(x in 1:10){
    try({
      recipe_site <- read_html(list_of_urls$url[j])  # load the recipe page
      break #break/exit the for-loop
    }, silent = FALSE)
  }
  
  # Title
  list_of_urls$title[[j]] <- recipe_site %>%
    html_nodes(".recipe-header__title") %>%
    html_text()
  
  # Cuisine
  list_of_urls$cuisine[[j]] <- gsub('[0-9]+', '',rownames(list_of_urls)[j])
  list_of_urls$nrecipe_per_cuisine[[j]] <- as.numeric(gsub('[a-z]+', '',rownames(list_of_urls)[j]))
  
  # Prep and cook time
  node <- recipe_site %>%
    html_nodes(".recipe-details__cooking-time-prep .hrs") 
  list_of_urls$prep_time_hours[[j]] <- ifelse(length(node)!= 0,
                                              node %>% 
                                                html_text() %>%
                                                gsub(" (.*)", "", .) %>%
                                                as.integer(),
                                              0
  )
  node <- recipe_site %>%
    html_nodes(".recipe-details__cooking-time-prep .mins") 
  list_of_urls$prep_time_minutes[[j]] <- ifelse(length(node)!= 0,
                                                node %>% 
                                                  html_text() %>%
                                                  gsub(" mins", "", .) %>%
                                                  as.integer(),
                                                0
  )
  list_of_urls$prep_time[[j]] <- eval((list_of_urls$prep_time_hours[[j]]*60)+list_of_urls$prep_time_minutes[[j]])
  
  node <- recipe_site %>%
    html_nodes(".recipe-details__cooking-time-cook .hrs") 
  list_of_urls$cook_time_hours[[j]] <- ifelse(length(node)!= 0,
                                              node %>% 
                                                html_text() %>%
                                                gsub(" (.*)", "", .) %>%
                                                as.integer(),
                                              0
  )
  node <- recipe_site %>%
    html_nodes(".recipe-details__cooking-time-cook .mins") 
  list_of_urls$cook_time_minutes[[j]] <- ifelse(length(node)!= 0,
                                                node %>% 
                                                  html_text() %>%
                                                  gsub(" mins", "", .) %>%
                                                  as.integer(),
                                                0
  )
  list_of_urls$cook_time[[j]] <- eval((list_of_urls$cook_time_hours[[j]]*60)+list_of_urls$cook_time_minutes[[j]])
  
  # Nutrition
  list_of_urls$kcal[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(1) .nutrition__value") %>%
    html_text()
  list_of_urls$fat[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(2) .nutrition__value") %>%
    html_text()
  list_of_urls$saturates[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(3) .nutrition__value") %>%
    html_text()
  list_of_urls$carbs[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(4) .nutrition__value") %>%
    html_text()
  list_of_urls$sugars[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(5) .nutrition__value") %>%
    html_text()
  list_of_urls$fibre[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(6) .nutrition__value") %>%
    html_text()
  list_of_urls$protein[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(7) .nutrition__value") %>%
    html_text()
  list_of_urls$salt[[j]] <- recipe_site %>%
    html_nodes("li:nth-child(8) .nutrition__value") %>%
    html_text()
  
  # Effort
  list_of_urls$effort[[j]] <- recipe_site %>%
    html_nodes(".recipe-details__item--skill-level .recipe-details__text") %>%
    html_text()
  
  # Serving size
  list_of_urls$serving_size[[j]] <- recipe_site %>%
    html_nodes(".recipe-details__item--servings .recipe-details__text") %>%
    html_text()
  
  # Ingredients
  list_of_urls$ingredients[[j]] <- list(recipe_site %>%
                                          html_nodes(".ingredients-list__item") %>%
                                          html_text())
  list_of_urls$ingredients[j] <- paste(unlist(list_of_urls$ingredients[[j]]), collapse = " @ ")
  
  # Method
  list_of_urls$method[[j]] <- list(recipe_site %>%
                                     html_nodes("#recipe-method p") %>%
                                     html_text())
  list_of_urls$method[j] <- paste(unlist(list_of_urls$method[[j]]), collapse = " @ ")
  
  # Stars
  #list_of_urls$review_stars[[j]] <- list(recipe_site %>%
  #                           html_nodes(".comment__rating-and-report-wrapper") %>%
  #                           html_text())
  # Review text
  # list_of_urls$review_text[[j]] <- list(recipe_site %>%
  #                           html_nodes("#fragment-comment .even") %>%
  #                           html_text())
  
  # Print iteration stage
  print(paste0("Round ",j," completed of ",nrow(list_of_urls)," rounds (",round(j/nrow(list_of_urls)*100,2),"%). Bravo!"))
  
}

# Adding recipe id
list_of_urls$recipe_id <- seq.int(nrow(list_of_urls))
list_of_urls <- list_of_urls %>%
  select(recipe_id, everything())

# Saving as rdata
save(list_of_urls, file = "/Volumes/ExHD_LAZ/data/bbc_recipes/raw/scraped_data.RData")
