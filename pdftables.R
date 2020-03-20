# load the data exported from pdf with excalibur-py
library(tidyverse)

cnames <- c("rownum", "region", "standard.opfyldt", "Tæller.nævner", "Uoplyst.antal", 
            "Aktuelle.år.2018.pc", "Aktuelle.år.2018.ci", 
            "Tidligere.år.2017", "Tidligere.år.2016")
p1 <- readxl::read_excel("4669_dap_aarsrapport-2018_24062019final.xlsx", sheet=1, skip=4, col_names = cnames)
p2 <- readxl::read_excel("4669_dap_aarsrapport-2018_24062019final.xlsx", sheet=2, skip=4, col_names = cnames)
p3 <- readxl::read_excel("4669_dap_aarsrapport-2018_24062019final.xlsx", sheet=3, skip=4, col_names = cnames)
p4 <- readxl::read_excel("4669_dap_aarsrapport-2018_24062019final.xlsx", sheet=4, skip=4, col_names = cnames)

pp <- bind_rows(p1, p2, p3, p4)
pp <- select(pp, -rownum)

# split the columns

pp <- separate(pp, `Tæller.nævner`, into = c("Tæller", "nævner"), sep = "/", convert=TRUE)
pp <- mutate(pp, Uoplyst.antal=as.numeric(str_remove(Uoplyst.antal, "\\(.+\\)")),
             Aktuelle.år.2018.pc = as.numeric(Aktuelle.år.2018.pc),
             Aktuelle.år.2018.ci = str_replace_all(Aktuelle.år.2018.ci, "[()-]", " "),
             Tidligere.år.2017 = str_replace_all(Tidligere.år.2017, "[()-]", " "),
             Tidligere.år.2016 = str_replace_all(Tidligere.år.2016, "[()-]", " "))
# Now replace multiple spaces with one
#pp <- mutate_at(pp, .vars=c("Aktuelle.år.2018.ci", "Tidligere.år.2017", "Tidligere.år.2016"), ~str_replace_all(.x, " +", " "))
# remove leading/trailing spaces
pp <- mutate_at(pp, .vars=c("Aktuelle.år.2018.ci", "Tidligere.år.2017", "Tidligere.år.2016"), 
                ~str_squish(.x))

pp <- separate(pp, col=Aktuelle.år.2018.ci,
               into=c("Aktuelle.år.2018.lci", "Aktuelle.år.2018.uci"), 
               convert=TRUE, remove=TRUE, extra="drop")

pp <- separate(pp, col=Tidligere.år.2017,
               into=c("Tidligere.år.2017.pc", "Tidligere.år.2017.lci", "Tidligere.år.2017.uci"), 
               convert=TRUE, remove=TRUE, extra="drop")


pp <- separate(pp, col=Tidligere.år.2016,
               into=c("Tidligere.år.2016.pc", "Tidligere.år.2016.lci", "Tidligere.år.2016.uci"), 
               convert=TRUE, remove=TRUE, extra="drop")

pp <- mutate(pp, 
             anglicized=str_replace(region, "ø", "oe"),
             anglicized=str_replace(anglicized, "Ø", "Oe"),
             anglicized=str_replace(anglicized, "å", "aa"),
             anglicized=str_replace(anglicized, "Å", "Aa"),
             anglicized=str_replace(anglicized, "æ", "ae"),
             anglicized=str_replace(anglicized, "Æ", "Ae")
             )
# This table is a combination of small regions and the larger regions containing them.
# Add a column corresponding to the large region

# first row is all Denmark, 2:7 are larger regions.
# These regions then get repeated with the sub regions

denmark <- pp[1, ]

regionens <- pp[2:7,]
regionensTmp <- mutate(select(regionens, region), RR=region)
kommunesA <- rename(pp[-(1:7), ], kommune=region)

kommunesA <- left_join(kommunesA, regionensTmp, by=c("kommune"="RR"))
kommunesA <- fill(kommunesA, region, .direction="down")
kommunes <- filter(kommunesA, region != kommune)
