library(stringr)

inquirer.dict <- read.csv("data/csm-forums/inquirerbasic.csv", stringsAsFactors = FALSE)
inquirer.dict$Entry <- tolower(inquirer.dict$Entry)

# Remove #1 tags 
inquirer.dict$Entry = gsub("#1", "", inquirer.dict$Entry)

# Remove entries that are still numbered (i.e. two or higher)
inquirer.dict = inquirer.dict[!grepl("#", inquirer.dict$Entry), ]

# Create list of containing dictionaries for each sentiment
sentiment_dict.l <- list()
for (i in 2:length(inquirer.dict[1,])) {
  words.v <- inquirer.dict$Entry
  # Remove blanks
  words.v <- words.v[inquirer.dict[,i] != ""]
  # Create dictionary for each sentiment
  sentiment_dict.l[[i-1]] <- words.v
  # Name dictionaries
  names(sentiment_dict.l)[[i-1]] <- colnames(inquirer.dict)[i]
}

input_file.v <- "data/csm-forums/csm-forums.csv"
csm_forums.df <- read.csv(input_file.v)
csm_forums.df <- csm_forums.df[sample(nrow(csm_forums.df), 15000),]

# Words are the number of word separators plus 1
csm_forums.df$word_count <- sapply(gregexpr("\\W+", csm_forums.df$posts), length) + 1

# For each sentiment dictionaries
for (j in names(sentiment_dict.l[2:length(sentiment_dict.l)])) {
  # Initialize a vector 
  count <- rep(0, nrow(csm_forums.df))
  # For each post
  for (k in 1:nrow(csm_forums.df)) {
    # count occurances of words in dictionary
    for (m in sentiment_dict.l[[j]]) {
      count[k] <- count[k] + str_count(csm_forums.df$posts[k], pattern = m)
    }
  }
  csm_forums.df[, eval(j)] <- count
}

#output_file.v <- as.character(readline(prompt = "Please enter output file: "))
output_file.v <- "data/csm-forums/csm-forum-sentiment-15000.csv"
write.csv(csm_forums.df, file = output_file.v)



