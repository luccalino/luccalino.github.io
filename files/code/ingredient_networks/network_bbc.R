# Loading packages (install if not yet installed)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, reshape, igraph, data.table, plyr, magrittr, tidyr, qgraph, dplyr, readxl, RColorBrewer, gtools, gplots, ggraph)

# Clear environment
remove(list = ls())  

# Cuisines to select
# ctp <- c("american","british","caribbean","chinese","french","greek","indian",
#               "italian","japanese","mediterranean","mexican","moroccan","spanish",
#               "thai","turkish","vietnamese")

# Groups to select
# ctp <- c("Anglo-saxon","Mediterranean","Caribbean","Asian")

# Anglo-saxon, Mediterranean, Asian, French, Indian, Turkish, Caribbean, Mexican
# Select cuisine to be plotted
tbp <- "italian"

############################## Preparing data for netowrk ##############################

# Loading data
load("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/ingredients_group_level.RData")

# Select data
data <- ingredients_db %>%
  dplyr::select(Group, cuisine, recipe_id, ingredient, rel_freq, global_rel_freq)

if (tbp == "World") {
  data$rel_freq <- data$global_rel_freq
} else if (tbp != "World") {
  data <- subset(data, cuisine == tbp)
}

# Select data
data <- data %>%
  dplyr::select(Group, cuisine, recipe_id, ingredient, rel_freq)

#########
# to_be_deleted <- data %>%
#   group_by(Group,ingredient) %>%
#   summarise(n())
# 
# to_be_deleted <- to_be_deleted %>%
#   filter(Group != "" & Group != "Asia" & Group != "Northamerica" & ingredient != "")
# 
# to_be_deleted2 <- to_be_deleted %>%
#   group_by(ingredient) %>%
#   summarise(n())

# Generate unique ingredient/relative frequency crosswalk
crosswalk <- data[!duplicated(data$ingredient),3:5]
crosswalk <- subset(crosswalk, ingredient != '')
crosswalk$ingredient <- gsub(" ","_",crosswalk$ingredient)

# Write complete ingredients list to CSV for categorization
#write.csv(crosswalk, file = "/Volumes/ExHD_LAZ/data/bbc_recipes/raw/categories.csv")

combination_data <- setDT(data)[, transpose(combn(ingredient, 2, FUN = list)), by = recipe_id]
names(combination_data)[2] <- "source"
names(combination_data)[3] <- "target"

combination_data <- combination_data[,2:3]
combination_data$source <- gsub(" ", "_", combination_data$source)
combination_data$target <- gsub(" ", "_", combination_data$target)

new_combo_data <- data.frame(table(combo = sapply(split(as.matrix(combination_data), row(combination_data)), 
                                        function(x) paste(sort(x), collapse=" "))))

new_combo_data <- new_combo_data %>%
  separate(combo, c("source", "target"), " ")

new_combo_data <- subset(new_combo_data, source != "")
new_combo_data <- subset(new_combo_data, source != target)

new_combo_data <- new_combo_data %>%
  dplyr::arrange(desc(Freq))

if (tbp == "World") {
  header <- nrow(new_combo_data)*5/100
} else if (tbp == "French") {
  header <- nrow(new_combo_data)*30/100
} else if (tbp == "Indian") {
  header <- nrow(new_combo_data)*30/100
} else {
  header <- nrow(new_combo_data)*10/100
}

new_combo_data <- head(new_combo_data, header)

# Merge crosswalk and combo data
merged_combo_data <- merge(new_combo_data,crosswalk,by.x="source",by.y="ingredient")
merged_combo_data <- merged_combo_data[order(merged_combo_data[,3]), ]

combo_matrix <- as.matrix(merged_combo_data)

############################## Starting network ##############################
vertices_data <- coalesce(merged_combo_data$source, merged_combo_data$target)

# Load data frame as igarph object
g <- graph_from_data_frame(merged_combo_data, directed = FALSE) %>%
  set_edge_attr("weight", value = merged_combo_data$Freq)

# We then add the edge weights to this network by assigning an edge attribute called 'occurance'.
#E(g)$occurance <- as.numeric(combo_matrix[,3]) 
V(g)$rel_freq <- as.numeric(crosswalk$rel_freq[match(V(g)$name,crosswalk$ingredient)])

# Color vertices according to category
categories <- read_excel("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/raw/categories.xlsx")
categories$category <- gsub("Beverages", "01) Beverages", categories$category)
categories$category <- gsub("Cereals and cereal products", "02) Cereals", categories$category)
categories$category <- gsub("Salts, spices, soups, sauces, salads, protein products", "03) Condiments", categories$category)
categories$category <- gsub("Eggs and egg products", "04) Eggs and egg products", categories$category)
categories$category <- gsub("Fats and oils", "05) Fats and oils", categories$category)
categories$category <- gsub("Meat and meat products", "06) Meat and fish", categories$category)
categories$category <- gsub("Fish", "06) Meat and fish", categories$category)
categories$category <- gsub("Fruits", "07) Fruits and vegetables", categories$category)
categories$category <- gsub("Vegetables", "07) Fruits and vegetables", categories$category)
categories$category <- gsub("Sweeteners", "08) Sweeteners", categories$category)
categories$category <- gsub("Bakery wares", "09) Bakery wares", categories$category)
categories$category <- gsub("Dairy products", "10) Dairy products", categories$category)
categories$category <- gsub("Other", "11) Other", categories$category)
V(g)$category <- as.character(categories$category[match(V(g)$name,categories$ingredient)])
V(g)$category <- ifelse(is.na(V(g)$category),
                        "12) Not defined",
                        V(g)$category)

# Assign the "category" attribute as the vertex color
#color.range <- colorpanel(13, "blue", "green", "red")
color.range <- brewer.pal(nlevels(as.factor(V(g)$category)), name = "Paired")
plot(rep(1,nlevels(as.factor(V(g)$category))),col=color.range,pch=19,cex=3)
#V(g)$color  <- color.range[as.factor(V(g)$category)]
V(g)$color  <- V(g)$category

vertice_cols <- brewer.pal(12, name = "Paired")
V(g)$color <- gsub("01) Beverages","lightskyblue2", V(g)$color)
V(g)$color <- gsub("02) Cereals","tan3", V(g)$color)
V(g)$color <- gsub("03) Condiments","limegreen", V(g)$color)
V(g)$color <- gsub("04) Eggs and egg products","azure2", V(g)$color)
V(g)$color <- gsub("05) Fats and oils","orange1", V(g)$color)
V(g)$color <- gsub("06) Meat and fish","pink1", V(g)$color)
V(g)$color <- gsub("07) Fruits and vegetables","darkgreen", V(g)$color)
V(g)$color <- gsub("08) Sweeteners","red", V(g)$color)
V(g)$color <- gsub("09) Bakery wares","brown", V(g)$color)
V(g)$color <- gsub("10) Dairy products","yellow", V(g)$color)
V(g)$color <- gsub("11) Other","lightgrey", V(g)$color)
V(g)$color <- gsub("10) Dairy products","yellow", V(g)$color)
V(g)$color <- gsub("12) Not defined","lightgrey", V(g)$color)

vertice_cols[as.numeric(as.factor(levels(as.factor(V(g)$category))))]
vertice_cols <- gsub("#A6CEE3","lightskyblue2",vertice_cols)
vertice_cols <- gsub("#1F78B4","tan3",vertice_cols)
vertice_cols <- gsub("#B2DF8A","limegreen",vertice_cols)
vertice_cols <- gsub("#33A02C","azure2",vertice_cols)
vertice_cols <- gsub("#FB9A99","orange1",vertice_cols)
vertice_cols <- gsub("#E31A1C","pink1",vertice_cols)
vertice_cols <- gsub("#FDBF6F","darkgreen",vertice_cols)
vertice_cols <- gsub("#FF7F00","red",vertice_cols)
vertice_cols <- gsub("#CAB2D6","brown",vertice_cols)
vertice_cols <- gsub("#6A3D9A","yellow",vertice_cols)
vertice_cols <- gsub("#FFFF99","lightgrey",vertice_cols)

# Make first letter capital and remove "_"
V(g)$name <- paste(toupper(substr(V(g)$name, 1, 1)), substr(V(g)$name, 2, nchar(V(g)$name)), sep="")
V(g)$name <- gsub("_"," ",V(g)$name)
V(g)$name <- paste0(V(g)$name," (",round(V(g)$rel_freq*100,1),"%)")

# Rescaling vertice size in vs-quantiles and generating percentages
vs <- 6
size_vec_vertice <- seq_len(vs)
sizeCut_vertice <- cut(round(V(g)$rel_freq*100,2),vs)
vertex.size <- size_vec_vertice[sizeCut_vertice]

# Make name bold if vertex size > 3
font.type <- vertex.size
font.type <- ifelse(vertex.size >= 3,
                    paste0("paste(bold('",toupper(V(g)$name),"'))"),
                    paste0("paste('",V(g)$name,"')")
                    )

# Rescaling edge width into octiles
ew <- 9
q99 <- quantile(E(g)$weight, probs = 0.99)
q95 <- quantile(E(g)$weight, probs = 0.95)
q75 <- quantile(E(g)$weight, probs = 0.75)
q50 <- quantile(E(g)$weight, probs = 0.50)
q25 <- quantile(E(g)$weight, probs = 0.25)
q05 <- quantile(E(g)$weight, probs = 0.05)
q01 <- quantile(E(g)$weight, probs = 0.01)
  
# size_vec_edge <- seq_len(ew)
# sizeCut_edge <- cut(E(g)$weight, ew)
# edge.width <- size_vec_edge[sizeCut_edge]

size_vec_edge <- seq_len(8)
sizeCut_edge <- cut(E(g)$weight, 8)
start <- 1.1
vec <- c(start,start^(2*3),start^(3*3),start^(4*3),start^(5*3),start^(6*3),start^(7*3),start^(7.5*3))
edge.width <- vec[sizeCut_edge]

# Changing color of edge according to ew-quantiles
cols <- brewer.pal(ew, "Greys")[1:ew]
plot(rep(1,ew),col=cols,pch=19,cex=3)
title("Main Title", cex.main=2) 
title(sub = "sub title", cex.sub = 0.75, adj = 0) 
adjustcolor(cols[2], alpha.f = 0.2)
adjustcolor(cols[3], alpha.f = 0.2)
adjustcolor(cols[4], alpha.f = 0.2)
adjustcolor(cols[5], alpha.f = 0.2)
E(g)$color[E(g)$weight <= q05] <- cols[2]
E(g)$color[E(g)$weight > q05 & E(g)$weight <= q25] <- cols[3]
E(g)$color[E(g)$weight > q50 & E(g)$weight <= q75] <- cols[4]
E(g)$color[E(g)$weight > q75 & E(g)$weight <= q95] <- cols[5]
E(g)$color[E(g)$weight > q95] <- cols[9]

# Aligning vertice names
radian.rescale <- function(x, start=0, direction=1) {
  c.rotate <- function(x) (x + start) %% (2 * pi) * direction
  c.rotate(scales::rescale(x, c(0, 2 * pi), range(x)))}

v <- gorder(g)
#lab.locs <- radian.rescale(x=1:v, direction=-1, start=0)

# Circular layout and order according to category
l <- layout_in_circle(g, 
                      order = order(V(g)$category)) 

# Change font size of node according to text length (https://stackoverflow.com/questions/13438013/variable-vertex-font-size-in-igraph)
# Implementation: https://trinkerrstuff.wordpress.com/2012/06/30/igraph-and-sna-an-amateurs-dabbling/

############################## Plotting ##############################
pdf(paste0("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/pdf/network_",tbp,".pdf"), width = "5.8", height = "8.3")
op <- par(cex = 0.4) # Font size
par(mar=c(9,9,9,9)) # bottom, left, top and right margins 
#curve_multiple(g)

# Network plot
plot.igraph(g,
     layout = l,
     edge.width = (edge.width/1.75)^(1.5), #ifelse(edge.width <= 2, 0.1,(edge.width/1.25)^(1.4)),
     edge.color = E(g)$color,
     edge.curved = 0.0,
     vertex.label.color = "black",
     vertex.size = vertex.size*2.8,
     vertex.color = V(g)$color,
     vertex.label = NA
     #sub = "gsfsdf"
     #vertex.label.dist = 1.5, 
     #vertex.label.degree = lab.locs
     )

#Add legend for color categories
legend(x = -1.41,
       y = 1.41,
       legend = levels(as.factor(V(g)$category)),
       col = vertice_cols[as.numeric(as.factor(levels(as.factor(V(g)$category))))],
       pch = 19,
       pt.cex = 2,
       bty = "n",
       title = expression(bold("Node color categories")),
       title.adj = 0.0)

## Apply labels manually
# Specify x and y coordinates of labels, adjust outward as desired
x = l[,1]*1.26
y = l[,2]*1.26

# Create vector of angles for text based on number of nodes (flipping the orientation of the words half way around so none appear upside down)
angle = ifelse(atan(-(l[,1]/l[,2]))*(180/pi) < 0,  90 + atan(-(l[,1]/l[,2]))*(180/pi), 270 + atan(-l[,1]/l[,2])*(180/pi))

# Apply the text labels with a loop with angle as srt
for (i in 1:length(x)) {
  text(x = x[i], 
       y = y[i], 
       labels = parse(text = font.type[i]), 
       adj = NULL, 
       pos = NULL, 
       cex = 1.1, 
       col = "black", 
       srt = angle[i], 
       xpd = TRUE)
}

text(x = 1,
     y = -1.45,
     font = 3,
     cex = 1.25,
      "Data source: Own graph. Data comes from BBCGF.")

uniq <- ingredients_db %>%
  group_by(Group) %>%
  summarise_at(vars(unique_total_ingredient_count), funs(mean(., na.rm=TRUE)))

uniq_ing <- ifelse(uniq$Group == tbp, uniq$unique_total_ingredient_count, NA)
uniq_ing <- subset(uniq_ing, !is.na(uniq_ing))

# text(x = 0.87,
#      y = -1.4,
#      font = 3,
#      cex = 1.25,
#      paste0("Note: ",uniq_ing," unique ingredients are analysed of which the 20% most frequent combinations are shown."))

#title(sub = "Data source: Own graph. Data comes from BBCGF.", font.sub = 3, cex.sub = 1.25, adj = 1, line = 8) 

dev.off()
# 
# ############################### Plot network preview ##################################
# 
# ############################## Plotting ##############################
pdf(paste0("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/bbc_recipes/pdf/preview_",tbp,".pdf"), width = "650", height = "350")
op <- par(cex = 0.8) # Font size
par(mar=c(9,9,9,9), bg="honeydew2") # bottom, left, top and right margins
#curve_multiple(g)

# Network plot
plot.igraph(g,
            layout = l,
            edge.width = ifelse(edge.width <= 2, 0,(edge.width/1.25)^(1.2)),
            edge.color = E(g)$color,
            edge.curved = 0.0,
            vertex.label.color = "black",
            vertex.size = vertex.size*2.8,
            vertex.color = V(g)$color,
            vertex.label = NA
)

## Apply labels manually
# Specify x and y coordinates of labels, adjust outward as desired
x = l[,1]*1.55
y = l[,2]*1.55

# Create vector of angles for text based on number of nodes (flipping the orientation of the words half way around so none appear upside down)
angle = ifelse(atan(-(l[,1]/l[,2]))*(180/pi) < 0,  90 + atan(-(l[,1]/l[,2]))*(180/pi), 270 + atan(-l[,1]/l[,2])*(180/pi))

# Apply the text labels with a loop with angle as srt
for (i in 1:length(x)) {
  text(x = x[i],
       y = y[i],
       labels = parse(text = font.type[i]),
       adj = NULL,
       pos = NULL,
       cex = 1.1,
       col = "black",
       srt = angle[i],
       xpd = TRUE)
}
#title(sub = "Data source: Own graph. Data comes from BBCGF.", font.sub = 3, cex.sub = 1.25, adj = 1, line = 8)

dev.off()
# 
# 
# 
# 
# 
# 
# 
