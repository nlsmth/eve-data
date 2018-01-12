# Sort csm forum data set by time

input_file.v <- "data/csm-forums/csm-forums.csv"

#if (interactive())
#  input_file.v <- as.character(readline(prompt = "Please enter desired csv file: "))

csm_forums.df <- read.csv(input_file.v)

csm_forums.df$dates <- as.POSIXlt(csm_forums.df$dates)

# Sort data frame by dates of posts oldest to newest
csm_forums_ordered.df <- csm_forums.df[order(csm_forums.df$dates),]

#if (interactive())
#  output_file.v <- as.character(readline(prompt = "Please enter desired output file: "))

write.csv(csm_forums_ordered.df, file = "data/csm-forums/csm-forums-ordered.csv")