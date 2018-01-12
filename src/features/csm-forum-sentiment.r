library(parallel)
num.cores <- detectCores()

# Read in Inquirer data
inquirer.dict <- read.csv("data/csm-forums/inquirerbasic.csv", stringsAsFactors = FALSE)
inquirer.dict$Entry <- tolower(inquirer.dict$Entry)
# Remove numbers and repeat entries
inquirer.dict$Entry = gsub("#1", "", inquirer.dict$Entry)
inquirer.dict = inquirer.dict[!grepl("#", inquirer.dict$Entry), ]
# Create list of containing dictionaries for each sentiment
sentiment_dict.l <- list()
for (i in 2:length(inquirer.dict[1,])) {
  words.v <- inquirer.dict$Entry
  words.v <- words.v[inquirer.dict[,i] != ""]
  sentiment_dict.l[[i-1]] <- words.v
  names(sentiment_dict.l)[[i-1]] <- colnames(inquirer.dict)[i]
}
sentiment_dict.l[[1]] <- NULL

# Read in forum data
input_file.v <- "data/csm-forums/csm-forums.csv"
csm_forums.df <- read.csv(input_file.v)
csm_forums.df <- csm_forums.df[sample(nrow(csm_forums.df), 1),]

# Count number of words in each post
csm_forums.df$word_count <- sapply(gregexpr("[[:alpha:]]+",csm_forums.df$posts),function(x) sum(x > 0))

sentiment_count.df <- as.data.frame(matrix(0, nrow = nrow(csm_forums.df), ncol = length(sentiment_dict.l)))
colnames(sentiment_count.df) <- names(sentiment_dict.l)

count_occurances <- function(dict, post) {
  for (m in dict) count <- count + length(grep(m, post))
  count
}

for (k in 1:csm_forums.df$posts) {
  for (j in sentiment_dict.l) {
    sentiment_count.df[k,] <- mclapply(sentiment_count.df[k,],
                                       count_occurances, j,
                                       csm_forums.df[[k]], mc.cores = num.cores)
  }
}


# Write data
output_file.v <- "data/csm-forums/csm-forum-sentiment-1-par.csv"
write.csv(csm_forums.df, file = output_file.v)



