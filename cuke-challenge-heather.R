download.file("http://r-bio.github.io/data/holothuriidae-specimens.csv", "data/holothuriidae-specimens.csv")
download.file("http://r-bio.github.io/data/holothuriidae-nomina-valid.csv","data/holothuriidae-nomina-valid.csv")
hol <- read.csv(file="data/holothuriidae-specimens.csv", stringsAsFactors=FALSE)
nom <- read.csv(file="data/holothuriidae-nomina-valid.csv", stringsAsFactors=FALSE)
##1. How many specimns in hol data frame?
Number_of_specimens <- nrow(hol)
print(paste0("number of specimens in hol data frame = ", Number_of_specimens))
##2. a. How many institutions house specimens
num_institutions <- length(unique(hol$dwc.institutionCode))
print(paste0(num_institutions , " institutions house speciments"))
##2. b. Barplot of institution contributions
###create variables for the number of contributions of each institution
#Vector that holds each instiution name
inst_names <- c(unique(hol$dwc.institutionCode))
#counting contributions of each institution. I should have done this with a for loop through the vector
#inst_names but couldn't get that to work.
FLMNH_contrib <- nrow((FLMNH_only <- subset(hol, dwc.institutionCode=="FLMNH")))
CAS_contrib <- nrow((CAS_only <- subset(hol, dwc.institutionCode=="CAS")))
MCZ_contrib <-nrow((MCZ_only <- subset(hol, dwc.institutionCode=="MCZ")))
YPM_contrib <-nrow((YPM_only <- subset(hol, dwc.institutionCode=="YPM")))
#create a vector that holds the contributions of each institution
inst_contribs <- as.numeric(c(FLMNH_contrib,CAS_contrib,MCZ_contrib,YPM_contrib))
#use cbind to put the institution names with the contributions
inst_contribs_data_frame <- data.frame(cbind(inst_names, inst_contribs))
#name the four bars by institution
names.arg <- unique(hol$dwc.institutionCode)
barplot(table(inst_contribs))
