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
library(dplyr)

# Clear environment
remove(list = ls())

# Ingredients -------------------------------------------------------------

## Loading data
load("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/scraped_data.RData") 

### Working on ingredients ###
ingredients_db <- list_of_urls %>%
  dplyr::select(recipe_id, cuisine, ingredients)

ingredients_db$ingredients <- as.list(strsplit(as.character(ingredients_db$ingredients), " @ "))
ingredients_db <- unnest(unnest(ingredients_db, ingredients))

### Creating ingredient id ###
ingredients_db  <- ingredients_db %>% 
  group_by(recipe_id) %>% 
  mutate(cuisine, ingredient_id = row_number(recipe_id)) %>%
  dplyr::select(recipe_id, cuisine, ingredient_id, ingredients)

### Create original ingredients list to compare work in progress ###
ingredients_db$ingredients_original <- ingredients_db$ingredients
ingredients_db <- ingredients_db[c("cuisine", "recipe_id", "ingredient_id", "ingredients_original", "ingredients")]

### Select data
ingredients_db  <- subset(ingredients_db, cuisine %in% c("american","british","chinese","french","greek","indian","italian","japanese",
                                    "moroccan","spanish","thai","vietnamese"))

### Remove some spotted troublemakers
ingredients_db$ingredients <- gsub(" heaped ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub(" rounded ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("/2lb", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("4oz", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("/ 6oz", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("ripe,", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("800g-1kg", "900g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("-piece", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("about", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("T-bone steak", "t-bone steak", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Spanish", "spanish", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("/5oz", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("/4lb 8oz", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("(vegetarian brand, if required)", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Little Gem", "little gem", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Hob Nobs", "hob nobs biscuits", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("skinless, boneless", "boneless skinless", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("boneless, skinless", "boneless skinless", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("850ml-1 litre/1½ pints - 1¾ pints", "925ml", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("at room temperature", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("such as", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Appleton rum", "appleton rum", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("a good grating", "grated", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("baby or ½", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("couple ", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("about ", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("0% fat", "zerofat", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Cumberland or Lincolnshire sausages", "cumberland or lincolnshire sausages", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("140-200g/5-7oz", "170g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("litre/1¾ pints", "l", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("2% fat", "lowfat", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('try Cumberland', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('/1lb 2oz', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(', omega-3 rich', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('/7oz', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('Levi Roots Love Apple Tomato sauce or tomato sauce with a good splash Tabasco', "tomato sauce", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('- the skins must be black', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('lots of soft flour', "softflour", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('1 whole large sea bass (about 800g)', "800g large seabass", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('Shaoxing rice wine or dry Sherry', "shaohsing rice wine", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('3 fat, fresh red chillies deseeded and thinly shredded', "3 fat fresh red chillies", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('reduced salt ', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('low salt ', "low-salt ", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('egg white', "egg whites ", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('tbp', "tbsp", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('/9oz', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('unsalted, roasted', "unsalted roasted", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(' from the chiller cabinet (see tips)', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(' Thai ', " thai ", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('/3lb 8oz', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('/8oz', "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('small, thick slices brioche or white bread', "small thick slices brioche", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('extra virgin', "extravirgin", ingredients_db$ingredients)
ingredients_db$ingredients <-sub('finely, freshly grated', "finely freshly grated", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Green & Black's", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("free range", "freerange", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("several", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("pkt", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("large, raw, shell-on", "large raw", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("skinless, sustainably-caught", "skinless sustainably-caught", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("celeriac", "celery", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Kalamata", "kalamata", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("toasted, flaked", "toasted flaked", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("½ a", "0.5", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Greek", "greek", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("roasted, salted", "roasted salted", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Cointreau or Grand Marnier", "cointreau or grand marnier", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("oil for frying", "frying oil", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("680g-700g", "690g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("small, ripe", "small ripe", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("1 x 50g/2oz", "50g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("SunBlush", "sunblush", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("British", "british", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("300g/11oz", "300g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("white, pointed or sweetheart", "white pointed", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Japanese", "japanese", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Tenderstem", "tenderstem", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("full fat", "fullfat", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("a few, or one, of the following to serve: crumbled feta cheese, chopped spring onions, sliced radishes, avocado chunks, soured cream", "avocado chunks", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Cajun or Mexican", "cajun or mexican ", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Red Leicester", "red leicester", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("4cm/1½ in piece", "4cm", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("cooked, shelled", "cooked shelled", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("6 x 175g/6oz", "6 x 175g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("litre", "l", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("hot stock, fish or vegetable", "hot fish or vegetable stock", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Tabasco or harissa", "tabasco or harissa", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("fat, fresh red", "fat fresh red", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("pack large, cooked, peeled", "pack large cooked peeled", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("raw, peeled prawns, defrosted if frozen", "raw peeled prawns", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("1 level tsp", "1 tsp", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("raw, peeled", "raw peeled", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("cooked, skinless", "cooked skinless", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("larger, mild-to-medium", "larger mild-to-medium", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("400ml/14fl oz", "400ml", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("Atlantic", "atlantic", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("thick, dried, flat", "thick dried flat", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("thick, creamy", "thick creamy", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("medium, ripe", "medium ripe", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("½ a 350g/12oz", "175g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("raw, tail-on", "raw tail-on", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("2½cm/1in piece", "2.5cm", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("low sodium", "lowsodium", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("large cooked, peeled", "large cooked peeled", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("juice 3 limes Lime ly-mThe same shape,", "juice 3 limes,", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("peeled, cooked", "peeled cooked", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("175g/60z", "175g", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("mixed Asian greens such as", "", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("8-10 sheets of brik or filo pastry (see tips)", "9 sheets filo pastry", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("½ a 350g/12oz bought madeira loaf", "175g madeira loaf", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("rapeseed, sunflower or grapeseed oil", "rapeseed or sunflower oil", ingredients_db$ingredients)


### Remove everything after first comma ###
ingredients_db$ingredients <- gsub(",.*", "", ingredients_db$ingredients)

### Remove brackets and text within ###
ingredients_db$ingredients <- gsub("\\s*\\([^\\)]+\\)","",as.character(ingredients_db$ingredients))

### Extracting quantities from ingredients ###
# Replace division symbols
ingredients_db$ingredients <-sub("½ a ", "0.5 x ", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(" ¼", "¼", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("¼", ".25", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(" ½", "½", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("½", ".5", ingredients_db$ingredients)
ingredients_db$ingredients <-sub(" ¾", "¾", ingredients_db$ingredients)
ingredients_db$ingredients <-sub("¾", ".75", ingredients_db$ingredients)

# Extracting numeric quantities
ingredients_db$quantity <-as.numeric(parse_number(ingredients_db$ingredients))

# Extract special cases (such as 2 x 400g etc.) I
ingredients_db$special_cases <- grepl(" x ", ingredients_db$ingredients)
ingredients_db$special_cases2 <- grepl("-", ingredients_db$ingredients)
ingredients_db$special_cases1 <- gsub('[[:digit:]]+', ' ', ingredients_db$ingredients)

# Get positions of digits (pod) and commas (pocomma) within strings
ingredients_db$pod <- gregexpr(pattern ='[[:digit:]]',ingredients_db$ingredients)
ingredients_db$pocomma <- gregexpr(pattern ='-',ingredients_db$ingredients)

# Extract the last numeric position or the first comma position
ingredients_db$max_pod <- sapply(ingredients_db$pod, MARGIN = 1, FUN = max) 
ingredients_db$max_pocomma <- sapply(ingredients_db$pocomma, MARGIN = 1, FUN = max) 
  
# Extract digits from special cases (dsc) otherwise empty ("")
ingredients_db$dsc <- ifelse(ingredients_db$special_cases == TRUE, substring(ingredients_db$ingredients,1,ingredients_db$max_pod), "")

# Replace couple of special characters
ingredients_db$dsc <- gsub("/.*", "", ingredients_db$dsc)
ingredients_db$dsc <- gsub("packs.*", "", ingredients_db$dsc)
ingredients_db$dsc <- gsub("g.*", "", ingredients_db$dsc)
ingredients_db$dsc <- gsub("ml.*", "", ingredients_db$dsc)
ingredients_db$dsc <- trimws(ingredients_db$dsc, "both")
ingredients_db <- separate(ingredients_db, dsc, c("dsc1", "dsc2"), sep = " x ")
ingredients_db$dsc1 <- as.numeric(ingredients_db$dsc1)
ingredients_db$dsc2 <- as.numeric(ingredients_db$dsc2)
ingredients_db$updated_quantity <- ingredients_db$dsc1*ingredients_db$dsc2
ingredients_db$quantity <- with(ingredients_db, ifelse(special_cases == TRUE, updated_quantity, quantity))
ingredients_db$ingredients <- str_replace(ingredients_db$ingredients," x ", "")
ingredients_db <- ingredients_db %>%
  dplyr::select(cuisine, recipe_id, ingredient_id, ingredients_original, ingredients, quantity, max_pocomma, max_pod)

### Remove numbers and punctuation ###
ingredients_db$ingredients <- gsub('[[:digit:]]+', '', ingredients_db$ingredients)
ingredients_db$ingredients <- gsub('½', '', ingredients_db$ingredients)
ingredients_db$ingredients <- gsub('¼', '', ingredients_db$ingredients)
ingredients_db$ingredients <- gsub('¾', '', ingredients_db$ingredients)
ingredients_db$ingredients <- gsub('[[:punct:]]', '', ingredients_db$ingredients)

### Make first letter of ingredients lower case ###
# Remove whitespace at the beginning or end 
ingredients_db$ingredients <- trimws(ingredients_db$ingredients, "left")
ingredients_db$ingredients<- paste(tolower(substr(ingredients_db$ingredients, 1, 1)), substr(ingredients_db$ingredients, 2, nchar(ingredients_db$ingredients)), sep="")

### Extracting units ###
ingredients_db$ingredients <- paste0(" ", ingredients_db$ingredients)
ingredients_db$unit <- ifelse(grepl(" kg | g | tbsp | tsp | ml | cm | mm | l | dl | ml ", ingredients_db$ingredients), gsub("([a-z]+).*", "\\1", ingredients_db$ingredients), "") 
ingredients_db$unit <- trimws(ingredients_db$unit, "both")
ingredients_db$ingredients <- gsub(" kg | g | tbsp | tsp | ml | cm | mm | l | dl | ml ", '', ingredients_db$ingredients)
ingredients_db$ingredients <- trimws(ingredients_db$ingredients, "left")
ingredients_db$unit <- gsub("tsp", "tbsp", ingredients_db$unit)

# Replace quantity = 0.25 and unit = tbsp if pinch is mentioned
ingredients_db$quantity <- ifelse(grepl("pinch", ingredients_db$ingredients_original) == TRUE,
                                  0.25, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("pinch", ingredients_db$ingredients_original) == TRUE,
                                  "tbsp", ingredients_db$unit)

# Replace quantity = 1 and unit = tbsp if "a little" is mentioned
ingredients_db$quantity <- ifelse(grepl("a little", ingredients_db$ingredients_original) == TRUE,
                                  1, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("a little", ingredients_db$ingredients_original) == TRUE,
                              "tbsp", ingredients_db$unit)

# Replace quantity = 2 and unit = g if "handful" is mentioned
ingredients_db$quantity <- ifelse(grepl("handful", ingredients_db$ingredients_original) == TRUE,
                                  2, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("handful", ingredients_db$ingredients_original) == TRUE,
                              "g", ingredients_db$unit)

# Replace quantity = 2 and unit = g if "smidgen" is mentioned
ingredients_db$quantity <- ifelse(grepl("smidgen", ingredients_db$ingredients_original) == TRUE,
                                  2, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("smidgen", ingredients_db$ingredients_original) == TRUE,
                              "g", ingredients_db$unit)

# Replace quantity = 2 and unit = tbsp if "drizzle" is mentioned
ingredients_db$quantity <- ifelse(grepl("drizzle", ingredients_db$ingredients_original) == TRUE,
                                  2, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("drizzle", ingredients_db$ingredients_original) == TRUE,
                              "tbsp", ingredients_db$unit)

# Replace quantity = 10 and unit = g if "a mugful of" or "cupful" is mentioned
ingredients_db$quantity <- ifelse(grepl("a mugful of", ingredients_db$ingredients_original) == TRUE,
                                  10, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("a mugful of", ingredients_db$ingredients_original) == TRUE,
                              "g", ingredients_db$unit)
ingredients_db$quantity <- ifelse(grepl("a cupful of", ingredients_db$ingredients_original) == TRUE,
                                  10, ingredients_db$quantity)
ingredients_db$unit <- ifelse(grepl("a cupful of", ingredients_db$ingredients_original) == TRUE,
                              "g", ingredients_db$unit)

### Remove strings after first capital letter (i.e. explanatory text)
# Get position of capital letters (poc)
ingredients_db$poc <- gregexpr("[A-Z]", ingredients_db$ingredients)

# Get number of capital letters (if one: leave in dataset; if more than one: remove)
ingredients_db$number_poc <- lengths(ingredients_db$poc)
ingredients_db$ingredients <- ifelse(ingredients_db$number_poc > 1, gsub("[A-Z].*","", ingredients_db$ingredients), ingredients_db$ingredients)

### Extract special cases (such as 1-2 to 1.5 etc.) II
ingredients_db$dsc3 <- ifelse(ingredients_db$max_pocomma <= 5 & ingredients_db$max_pocomma > 1, 
                              substring(ingredients_db$ingredients_original,1,ingredients_db$max_pod), "")
ingredients_db$dsc3 <- gsub('g', '', ingredients_db$dsc3)
ingredients_db$dsc3 <- gsub('5', '', ingredients_db$dsc3)
ingredients_db$dsc3 <- gsub('s', '', ingredients_db$dsc3)
ingredients_db$dsc3 <- gsub('½', '.5', ingredients_db$dsc3)
ingredients_db <- separate(ingredients_db, dsc3, c("dsc4", "dsc5"), sep = "-")
ingredients_db$dsc4 <- as.numeric(ingredients_db$dsc4)
ingredients_db$dsc5 <- as.numeric(ingredients_db$dsc5)
ingredients_db$updated_quantity2 <- (ingredients_db$dsc4+ingredients_db$dsc5)/2
ingredients_db$quantity <- with(ingredients_db, ifelse(!is.na(updated_quantity2), updated_quantity2, quantity))

# Bring ingredeitns to lower cases
ingredients_db$ingredients <- tolower(ingredients_db$ingredients)
ingredients_db <- ingredients_db %>%
  dplyr::select(cuisine, recipe_id, ingredient_id, ingredients_original, quantity, unit, ingredients)

### Saving as rdata
save(ingredients_db, file = "/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/modified_data.RData")

# Clear environment
remove(list = ls()) 

## Loading data
load("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/modified_data.RData") 

### Extract adjectives
# Loading and extracting adjectives
adjectives <- read.delim("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/adjectives.txt", header = TRUE, col.names=c("adjective"))
adjectives <- paste(unlist(adjectives$adjective, use.names = F), collapse = " | ")

# Make some spotted adjustments
ingredients_db$ingredients <- gsub("hot dog", "hot-dog", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("of  your  favourite", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub(" of ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("in water", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("your favourite", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("a  little", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("a little", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("handful", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("smidgen", "", ingredients_db$ingredients)

# Extract
ingredients_db$ingredients <- paste0(" ", ingredients_db$ingredients," ")
ingredients_db$ingredients <- gsub(" ", "  ", ingredients_db$ingredients)
ingredients_db$adjectives <- str_extract_all(ingredients_db$ingredients, adjectives)
ingredients_db$ingredients <- gsub(adjectives, '', ingredients_db$ingredients)

ingredients_db$ingredients <- trimws(ingredients_db$ingredients, "both")
ingredients_db$ingredients <- gsub("  ", " ", ingredients_db$ingredients)

### Extract attributes
# Loading and extracting attributes
attributes <- read.delim("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/attributes.txt", header = TRUE, col.names=c("attribute"))
attributes <- paste(unlist(attributes$attribute, use.names = F), collapse = " | ")

ingredients_db$ingredients <- paste0(" ", ingredients_db$ingredients, " ")
ingredients_db$ingredients <- gsub(" ", "  ", ingredients_db$ingredients)
ingredients_db$attributes <- str_extract_all(ingredients_db$ingredients, attributes)
ingredients_db$ingredients <- gsub(attributes, '', ingredients_db$ingredients)

# Ex post modifications
ingredients_db$ingredients <- gsub("  s  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  splash  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  each  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  more  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  from  ", "  ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  a  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  around  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  oz  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  fl ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  beaten  with  water  ", "", ingredients_db$ingredients)
ingredients_db$unit <- gsub("egg", "", ingredients_db$unit)
ingredients_db$ingredients <- gsub("  on  the  vine  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  drizzle  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  but  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  total  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("mugful  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("cupful  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  five  spice", "fivespice", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub(" mange  tout ", "mangetout", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  from  the  chiller  cabinet  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  the  equivalent  pork ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  with  water  to  makepaste  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  for  flavour  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  see  try  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  to  garnish  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  raisin  bread  and  cornichons  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  see  secrets  for  success  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  several  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  see  tip  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  their  shells  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  flute  or  baguette  measuring  approx  cm  ", "baguette", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  juice  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  orchopped  oregano  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  olive  oil  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  oil  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("   or  you  use  farfalle  or  penne ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  with  garlic  and  herbs  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  and  onion  and  rocket  salad  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  take  this  thetub  for  the  ice  cream  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  to  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  on  the  bone  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  including  aubergine  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  mayo  ", " mayonnaise", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  inch  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  available  bart  or  steenbergscouk  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  per  portion  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  blend  lots  garlic  with  vegetable  oil  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  your  choice  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  for  deepfrying  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  whatever  youve  got  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  vegetarian  equivalent  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("   cherry  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  seasoned  with  salt  and  pepper  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or    local  blue  cheese  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  the  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("    use  tonkatsu  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  vocado", "avocado", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  spray  for  cooking  or mildflavoured  cooking  oil  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  apiece  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  see  recipe  in  tip  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  for  deep  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("a  mix  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  another  sustainable  fish  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  their  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  the  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  choose toppings  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  spoonfulscurtido  and  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  sauceserve  ", " sauce", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  other  fish  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  brine  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("upsunflower", "sunflower", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  serve  with  avocado  ", "avocado", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  homemade  tortilla  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or  add thumbnailsized  chocolate  along  withbeans  instead  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  we  used  discovery  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  seeds    pomegranate  ortub  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  lemonserve  ", "lemon", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  falafels  with  hummus  recipe  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  ras  el  hanout  ", "raselhanout", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  moroccan  spice  mix  orraselhanout", "raselhanout", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  we  used  coriander  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  in  sunflower  oil  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  or    chicken  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  we  used seafood  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  we  used", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  easy  cook  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("   limes  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  cut  in  or  cheeks  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  including  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  hummus  hoomiss  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  anpack  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  and  basmati  or  jasmine  rice  ", "basmati rice", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  go  for leafy  mix  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  bacon  or  pancetta  ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("  chilliestaste  ", "chillies", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("egano", "oregano", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("zo", "orzo", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("ange", "orange", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("ecchiette", "orecchiette", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("houmous", "hummus", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("choriorzo", "chorizo", ingredients_db$ingredients)

# Order dataset
ingredients_db <- ingredients_db %>%
  select(cuisine, recipe_id, ingredient_id, ingredients_original, quantity, unit, adjectives, ingredients, attributes)

# Remove "or" and "and" at the beginning -> referring to addjectives 
ingredients_db$ingredients <- gsub("  ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("   ", " ", ingredients_db$ingredients)
ingredients_db$ingredients <- paste0("  ",ingredients_db$ingredients,"  ")
ingredients_db$ingredients <- gsub("   or", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("   and ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- trimws(ingredients_db$ingredients, "left")

# Remove "or" and "and" at the end -> referring to attributes 
ingredients_db$ingredients <- trimws(ingredients_db$ingredients, "right")
ingredients_db$ingredients <- paste0(ingredients_db$ingredients,"    ")
ingredients_db$ingredients <- gsub("or    ", "", ingredients_db$ingredients)
ingredients_db$ingredients <- gsub("and    ", "", ingredients_db$ingredients)

# Seperate "or" and "and" in the middle of ingredients
ingredients_db <- separate(ingredients_db, ingredients, c("ingredient", "alternative"), sep = " or ")

# Seperate "or" and "and" in the middle of ingredients
ingredients_db <- separate(ingredients_db, ingredient, c("ingredient", "additions"), sep = " and ")

# Adding relevant information to ingredient
ingredients_db$ingredient <- ifelse(grepl("vegetable", ingredients_db$ingredient) & grepl(" oil", ingredients_db$alternative), 
                                    gsub("vegetable", "vegetable oil", ingredients_db$ingredient), ingredients_db$ingredient)

ingredients_db$ingredient <- ifelse(grepl("wine", ingredients_db$ingredient) & grepl(" vinegar", ingredients_db$alternative), 
                                    gsub("wine", "wine vinegar", ingredients_db$ingredient), ingredients_db$ingredient)

ingredients_db$ingredient <- ifelse(grepl("balsamic", ingredients_db$ingredient) & grepl(" vinegar", ingredients_db$alternative), 
                                    gsub("balsamic", "balsamic vinegar", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("vinegar vinegar", "vinegar", ingredients_db$ingredient)

ingredients_db$ingredient <- ifelse(grepl("groundnut", ingredients_db$ingredient) & grepl(" oil", ingredients_db$alternative), 
                                    gsub("groundnut", "groundnut oil", ingredients_db$ingredient), ingredients_db$ingredient)

ingredients_db$ingredient <- ifelse(grepl("rapeseed", ingredients_db$ingredient) & grepl(" oil", ingredients_db$alternative), 
                                    gsub("rapeseed", "rapeseed oil", ingredients_db$ingredient), ingredients_db$ingredient)

ingredients_db$ingredient <- ifelse(grepl("sunflower", ingredients_db$ingredient) & grepl(" oil", ingredients_db$alternative), 
                                    gsub("sunflower", "sunflower oil", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("oil oil", "oil", ingredients_db$ingredient)

# Final adjustments
ingredients_db$ingredient <- gsub("ancho chilli", "ancho", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("and pepper", "pepper", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("asian greens  ", "", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("vegetable bouillon powder", "vegetable bouillon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("basil leaves", "basil", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("ororange", "orange", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bourbon", "bourbon whiskey", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("whiskey whiskey", "whiskey", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("brik", "brik pastry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pastry pastry", "pastry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bulghar", "bulgur", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cannellini", "cannellini beans", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("beans beans", "beans", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cardamom powder", "cardamom", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cheddar cheese", "cheddar", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("chorizo sausage", "chorizo", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("ciabatta bread", "ciabatta", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cider", "cider vinegar", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("vinegar vinegar", "vinegar", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("coriander andor mint leaf", "coriander", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("coriander leaf", "coriander", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("corianderbasmati rice", "coriander", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cornflour with watermake paste", "cornflour", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("custard", "custard powder", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("powder powder", "powder", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("edamame beans", "edamame", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("egg yolks with water", "egg yolk", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("fenugreek seed", "fenugreek", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("feta cheese", "feta", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("fish pie mix salmon", "salmon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("flour with salt", "flour", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("food colouring pastes in variety colours", "food colouring", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("garlic paste blend lots garlic with  vegetable oil", "garlic paste", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("garni", "garni tea", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tea tea", "tea", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("halloumi cheese", "halloumi", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("iceberg lettuce leaf", "iceberg lettuce", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("jalapeno", "jalapeño", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("jalapeño", "jalapeño chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("jalapeño chilli peppers", "jalapeño chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("jalapeño peppers", "jalapeño chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice  lemons", "lemon juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice  lemon", "lemon juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice lemon", "lemon juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice  lime", "lime juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice lime", "lime juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice  orange", "orange juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("juice orange", "orange juice", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("kashmiri chillies", "kashmiri chilli powder", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("kiwi fruit", "kiwi", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lamb on", "lamb", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lettuce leaf", "lettuce", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mint leaf", "mint", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mix sesame seeds", "sesame seeds", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mix tomatoes", "tomato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mix vegetables", "vegetable", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("morangetout", "mangetout", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("nori seaweed", "nori", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("oil spray for", "oil", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("oregano leaf", "oregano", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("other cookie fillings", "cookie filling", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("other potato", "potato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("other soy sauce", "soy sauce", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("palm", "palm sugar", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sugar sugar", "sugar", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("paneer cheese", "paneer", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pappardelle pasta", "pappardelle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("parsley leaf", "parsley", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peppers vegetables", "pepper", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pineapple orpineapple", "pineapple", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pinto", "pinto bean", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bean bean", "bean", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pitta", "pitta bread", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bread bread", "bread", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("plum tomatoes with garlic", "plum tomatoes", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("quantity beef with wine  carrots", "beef", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("rice noodlechiller cabinet", "rice noodle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("rocket leaf", "rocket", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("rocket salad", "rocket", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sage leaf", "sage", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sake", "saké", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("salad leaf", "salad", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("salmon roe", "salmon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sandwich baguette", "baguette", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("seasonal vegetables", "vegetable", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("seasoning mix", "seasoning", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("seeds  pomegranate", "pomegranate seed", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("semolina", "semolina flour", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("flour flour", "flour", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("shichimi togarashi chilli powder", "shichimi togarashi", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("shichimi togarashi spice mix", "shichimi togarashi", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("shiitake", "shiitake mushroom", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mushroom mushroom", "mushroom", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("soba", "soba noodle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("noodle noodle", "noodle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("spice mix orraselhanout", "raselhanout", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("spice seasoning", "seasoning", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("spinach leaf", "spinach", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("star anise seeds", "star anise", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tamarind pulp", "tamarind paste", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("thyme leaf", "thyme", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tiger prawns source", "tiger prawn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tikka paste", "tikka masala paste", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tomato with garlic", "tomato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("wasabi", "wasabi paste", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("paste paste", "paste", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("watercress leaf", "watercress", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("yoghurt", "yogurt", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("rice noodlechiller cabinet", "rice noodle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tomato passata", "passata", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("turmeric powder", "turmeric", ingredients_db$ingredient)

### Singularize
# Remove all whitespace
ingredients_db$ingredient <- trimws(ingredients_db$ingredient, "both")

ingredients_db$ingredient <- gsub("leaves", "leaf", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cherries", "cherry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cranberries", "cranberry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("strawberries", "strawberry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("blackberries", "blackberry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("blueberries", "blueberry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cranberries", "cranberry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("noodles", "noodle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("chives", "chive", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("courgettes", "courgette", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("berries", "berry", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("baguettes", "baguette", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("chickpeas", "chickpea", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cloves", "clove", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cornflakes", "cornflake", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("dates", "date", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("egg whites", "egg white", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lettuces", "lettuce", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("gruyères", "gruyère", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("limes", "lime", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("oranges", "orange", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pancakes", "pancake", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("olives", "olive", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peaches", "peach", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peanut cookies", "peanut cookie", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pickles", "pickle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("molasses", "molasse", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pulses", "pulse", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("quinces", "quince", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sardines", "sardine", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sausages", "sausage", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sprinkles", "sprinkle", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("vegetables", "vegetable", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("parsley leaf", "parsley", ingredients_db$ingredient)

ingredients_db$ingredient <- gsub("gem lettuce leaf", "gem lettuce", ingredients_db$ingredient)

# Make codes for words that would disappear when singularized
ingredients_db$ingredient <- gsub("chapatis", "chapatis@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("couscous", "couscous@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("hummus", "hummus@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("petits pois", "petits@ pois@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sea bass", "sea bass@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cress", "cress@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lemongrass", "lemongrass@", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lettuce leaf", "lettuce", ingredients_db$ingredient)

# Treat zest and juice
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" lemon ", ingredients_db$additions), 
                                    gsub("zest", "lemon zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" lemon", ingredients_db$additions), 
                                    gsub("zest", "lemon zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" lemons ", ingredients_db$additions), 
                                    gsub("zest", "lemon zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" lime ", ingredients_db$additions), 
                                    gsub("zest", "lime zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" limes ", ingredients_db$additions), 
                                    gsub("zest", "lime zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" ororange ", ingredients_db$additions), 
                                    gsub("zest", "orange zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" ororanges ", ingredients_db$additions), 
                                    gsub("zest", "orange zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl(" ororanges ", ingredients_db$additions), 
                                    gsub("zest", "orange zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- ifelse(grepl("zest", ingredients_db$ingredient) & grepl("juice    ", ingredients_db$additions), 
                                    gsub("zest", "orange zest", ingredients_db$ingredient), ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("zest  lemon", "lemon zest", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("zest  orange", "orange zest", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("zest lemon", "lemon zest", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("zest orange", "orange zest", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("zest  blood orange plus juice", "blood orange zest", ingredients_db$ingredient)

# Final adjustment
ingredients_db$ingredient <- gsub("thyme leaf", "thyme", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("herb thyme", "thyme", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cumin seed", "cumin", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cumins", "cumin", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bacon lardon", "bacon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cherry tomatoes", "tomato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("garlic", "garlic clove", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("clove clove", "clove", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("coriander leaf", "coriander", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mint leaf", "mint", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("harissa paste", "harissa", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("root ginger", "ginger", ingredients_db$ingredient)
# Singularize
ingredients_db$ingredient <- singularize(ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("potatoe", "potato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("chillie", "chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("chillis", "chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tomatoe", "tomato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tomatos", "tomato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("onions", "onion", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("spring onions", "spring onion", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mangoe", "mango", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("radishe", "radish", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("eggs", "egg", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("beansprouts", "beansprout", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("breadcrumbs", "breadcrumb", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sesame seeds", "sesame seed", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("shallots", "shallot", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peanuts", "peanut", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peppercorns", "peppercorn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("potatos", "potato", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peppers", "pepper", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("egg yolks", "egg yolk", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pecans", "pecan", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("carrots", "carrot", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("biscuits", "biscuit", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bacons", "bacon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("apples", "apple", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("aubergines", "aubergine", ingredients_db$ingredient)

ingredients_db$ingredient <- gsub("chilli chilli", "chilli", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lemon lemon", "lemon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("orange lemon", "lemon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("orange orange", "orange", ingredients_db$ingredient)

# Re-Make codes for words that would disappear when singularized
ingredients_db$ingredient <- gsub("chapatis@", "chapatis", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("couscous@", "couscous", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("hummus@", "hummus", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("petits@ pois@", "petits pois", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sea bass@", "sea bass", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("cress@", "cress", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lemongrass@", "lemongrass", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("apricots", "apricot", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("avocados", "avocado", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("bananas", "banana", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("beans", "bean", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("greens", "green", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("peas", "pea", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mustard seeds", "mustard seed", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mangos", "mango", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lentils", "lentil", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("fennel seeds", "fennel seed", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("almonds", "almond", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("greens", "green", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("beanprout", "beansprout", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mushrooms", "mushroom", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("parsnips", "parsnip", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pears", "pear", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lambs", "lamb", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("prawns", "prawn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("king prawns", "prawn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("king prawn", "prawn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("tiger prawn", "prawn", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("radishs", "radish", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("sugar snap peas", "pea", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("water chestnuts", "chestnut", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("lemons", "lemon", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("porcini_mushrooms", "porcini_mushroom", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("mussels", "mussel", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("hazelnuts", "hazelnut", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("almonds", "almond", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("pistachios", "pistachio", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("garlic clove sausage", "sausage", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("fennel fronds", "fennel frond", ingredients_db$ingredient)
ingredients_db$ingredient <- gsub("confit ducks", "duck", ingredients_db$ingredient)


# Remove white space
ingredients_db$ingredient <- trimws(ingredients_db$ingredient, "both")
ingredients_db$ingredient <- gsub("  ", " ", ingredients_db$ingredient)

### Adding group
ingredients_db$Group <- ""
ingredients_db$Group[ingredients_db$cuisine %in% "french"] <- "French"
ingredients_db$Group[ingredients_db$cuisine %in% "italian"] <- "Mediterranean"
ingredients_db$Group[ingredients_db$cuisine %in% "spanish"] <- "Mediterranean"
ingredients_db$Group[ingredients_db$cuisine %in% "british"] <- "Anglo-saxon"
ingredients_db$Group[ingredients_db$cuisine %in% "greek"] <- "Mediterranean"
ingredients_db$Group[ingredients_db$cuisine %in% "american"] <- "Anglo-saxon"
#ingredients_db$Group[ingredients_db$cuisine %in% "caribbean"] <- "Caribbean"
#ingredients_db$Group[ingredients_db$cuisine %in% "mexican"] <- "Mexican"
ingredients_db$Group[ingredients_db$cuisine %in% "moroccan"] <- "Mediterranean"
#ingredients_db$Group[ingredients_db$cuisine %in% "turkish"] <- "Turkish"
ingredients_db$Group[ingredients_db$cuisine %in% "thai"] <- "Asian"
ingredients_db$Group[ingredients_db$cuisine %in% "chinese"] <- "Asian"
ingredients_db$Group[ingredients_db$cuisine %in% "indian"] <- "Indian"
ingredients_db$Group[ingredients_db$cuisine %in% "vietnamese"] <- "Asian"
ingredients_db$Group[ingredients_db$cuisine %in% "japanese"] <- "Asian"

# Drop unused cusines
#ingredients_db <- subset(ingredients_db, cuisine != "mediterranean")
#ingredients_db <- subset(ingredients_db, Group != "mexican")
#ingredients_db <- subset(ingredients_db, Group != "caribbean")
#ingredients_db <- subset(ingredients_db, Group != "indian")

### Relative frequencies
# Count ingredient per cusine
ingredients_db <- ingredients_db %>% 
  dplyr::group_by(Group, ingredient) %>%
  dplyr::mutate(ingredient_count =  dplyr::n())

ingredients_db <- ingredients_db %>% 
  dplyr::group_by(ingredient) %>%
  dplyr::mutate(global_count =  dplyr::n())

# Count sum of ingredients per cuisine
ingredients_db <- ingredients_db %>% 
  dplyr::group_by(Group) %>%
  dplyr::mutate(total_ingredient_count =  dplyr::n())

# Count sum of unique ingredients per cuisine
ingredients_db <- ingredients_db %>% 
  dplyr::group_by(Group) %>%
  dplyr::mutate(unique_total_ingredient_count = n_distinct(ingredient))

ingredients_db$global_ingredient_count <- nrow(ingredients_db)

# Relative frequency
ingredients_db$rel_freq <- eval(ingredients_db$ingredient_count/ingredients_db$total_ingredient_count)
ingredients_db$global_rel_freq <- eval(ingredients_db$global_count/ingredients_db$global_ingredient_count)

# Save ingredients dataset
save(ingredients_db, file = "/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/ingredients_group_level.RData")

