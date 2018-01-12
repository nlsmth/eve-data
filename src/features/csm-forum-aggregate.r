input_file.v <- "data/csm-forums/csm-forums-ordered.csv"
csm_forums.df <- read.csv(input_file.v)
csm_forums.df$dates <- as.POSIXlt(csm_forums.df$dates)

if (interactive()) {
  min_date <- as.POSIXlt(readline(prompt = "Please enter the minimum date for the range: (YYYY-MM-DD HH:MM:SS UTC) "))
  max_date <- as.POSIXlt(readline(prompt = "Please enter the maximum date for the range: (YYYY-MM-DD HH:MM:SS UTC) "))
} else {
  min_date <- csm_forums.df$dates[1]
  max_date <- csm_forums.df$dates[length(csm_forums.df)]
}

part_csm_forums.df <- subset(csm_forums.df, dates >= min_date)
part_csm_forums.df <- subset(part_csm_forums.df, dates <= max_date)

output_file.v <- as.character(readline(prompt = "Please enter output file: "))
write.csv(part_csm_forums.df, file = output_file.v)