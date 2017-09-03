#extract_bib.R
#feigenbaum
#17feb2017

# load a tex file and a bib file
# extract a list of the citations used in the tex file
# and produce a new bib file with ONLY those citations

# updated 3sept2017 to remove the loop when pulling cites from tex file

library(data.table)
library(tidyverse)
library(stringr)
library(zoo)

# input
tex <- "article.tex"
bib <- "library.bib"

# output
bib.out <- "min_library.bib"

# read the tex file
dt.tex <- read_lines(tex) %>%
  as.data.table() %>%
  setnames("V1") %>%
  .[str_detect(V1, "\\\\cite")]

# pull cites out
dt <-
  dt.tex %>%
  select("V1") %>%
  # find the citations
  str_extract_all("\\\\cite.+?\\}", simplify = TRUE) %>%
  t() %>%
  as.data.table() %>%
  # remove tex formatting
  .[, cite := V1 %>%
      str_replace("\\\\cite.?", "") %>%
      str_replace_all("[{}]", "") %>%
      str_replace_all("\\[.*?\\]", "")]

# split on comma
# first max cites in one row?
K <- str_count(dt$V1, ",") %>% max() %>% add(1)
dt[, paste0('c', 1:K) := tstrsplit(cite, ",")] %>%
  .[, V1 := NULL]

cite.list <- dt %>%
  melt(., id.vars = "cite") %>%
  .[!is.na(value), list(value)] %>%
  setnames("value", "cite") %>%
  .[, cite := str_trim(cite)] %>%
  unique() %>%
  .[order(cite)]

# read the library
dt.bib <- fread(bib, sep = "\n", blank.lines.skip = TRUE, header = FALSE, quote = "") %>%
  .[, start := str_detect(V1, "@")] %>%
  .[, end := V1 == "}"] %>%
  # don't include abstract or file in the output
  .[str_sub(V1, 1, 4) != "file"] %>%
  .[str_sub(V1, 1, 8) != "abstract"] %>%
  # remove preamble stuff
  .[cumsum(start) != 0] %>%
  # citation and fill forward
  .[str_sub(V1, 1, 1) == "@", cite := V1 %>%
      str_replace_all(., "@.*?\\{", "") %>%
      str_replace_all(., ",$", "")] %>%
  .[, cite := na.locf(cite)] %>%
  # remove annotations (from mendeley)
  .[, annote := str_sub(V1, 1, 6) == "annote"] %>%
  .[, end.annote := str_detect(V1, "\\},$")] %>%
  .[, remove.annote := cumsum(annote) == 1 & cumsum(end.annote) <= 1 & max(annote) > 0, by = cite] %>%
  .[remove.annote == FALSE]

# should be as many keys as ends
(dt.bib[start == TRUE] %>% nrow()) == (dt.bib[end == TRUE] %>% nrow())

merge(cite.list, dt.bib, by = "cite", sort = FALSE) %>%
  .[, list(V1)] %>%
  fwrite(., file = bib.out, quote = FALSE, col.names = FALSE)
