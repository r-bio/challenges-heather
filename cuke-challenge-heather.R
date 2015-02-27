download.file("http://r-bio.github.io/data/holothuriidae-specimens.csv", "data/holothuriidae-specimens.csv")
download.file("http://r-bio.github.io/data/holothuriidae-nomina-valid.csv","data/holothuriidae-nomina-valid.csv")
hol <- read.csv(file="data/holothuriidae-specimens.csv", stringsAsFactors=FALSE)
nom <- read.csv(file="data/holothuriidae-nomina-valid.csv", stringsAsFactors=FALSE)
################################################################################################################
##1. How many specimns in hol data frame?
Number_of_specimens <- nrow(hol)
print(paste0("number of specimens in hol data frame = ", Number_of_specimens))
################################################################################################################
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
#plot the inst_contribs vector and name the four bars by institution
barplot(inst_contribs, names.arg = unique(hol$dwc.institutionCode))
################################################################################################################
##3.a. When was the oldest specimen collected?
dwc_year_noNA <- data.frame(year=c(na.omit(hol$dwc.year)))
#edit the dataset to take out incorrectly entered dates (e.g. 94).  This should be improved to edit the wrong
#dates, but for now I left them out.
dwc_years_no_errors <- data.frame(subset(dwc_year_noNA, year>1600))
#print out when the earliest collection was made
print(paste0("the earliest collection was made in ", min(dwc_years_no_errors)))
##3.b.
#create the data subset of specimens collected between 2006 and 2014
dwc_years_between_2006_2014 <- data.frame(subset(dwc_year_noNA, year<=2014 & year>=2006))
#count how many columns in the data subset
how_many_2006_2014 <- nrow(dwc_years_between_2006_2014)
#count how many columns were in the total data frame
how_many_total <- nrow(dwc_years_no_errors)
#find the proportion
proportion_of_specimens_btw_2006_2014 <- how_many_2006_2014/how_many_total
#print out the proportion
print(paste0("the proportions of specimens collected between 2006 and 2014 is ", proportion_of_specimens_btw_2006_2014))
################################################################################################################
##4.a
#make a data frame that shows whether each specimen has class listed (TRUE) or not (FALSE)
class_true_or_false_data <- data.frame(TF=c(nzchar(c(hol$dwc.class))))
#create a variable that is the number of occurrences of FALSE in the above data frame
missing_class <- nrow(subset(class_true_or_false_data, TF==FALSE))
#print how many FALSEs there were in the data frame
print(paste0(missing_class," specimens have class information missing"))
##4.b
#create a vector with the appropriate number of elements for specimens and the value Holothuroidea
dwc.class <- c("Holuthurodiea")
dwc.class_vector <- rep(dwc.class, 2984)
#merge this new vector with the hol data frame
hol_with_class_info <- data.frame(cbind(dwc.class_vector, hol))
#remove old dwc.class column
drops <- c("dwc.class")
hol_with_new_class_info <- hol_with_class_info[,!(names(hol_with_class_info) %in% drops)]
################################################################################################################
##5
#creat a subset of nom with only specimens that have subgenera currently
has_subgenus <- subset(nom,(nzchar(nom$Subgenus.current)==TRUE))
################################################################################################################
##6a. With the function paste(), create a new column (called genus_species) that contains the genus (column dwc.genus)
##and species names (column dwc.specificEpithet) for the hol data frame.
#Create the genus_species column by pasting the genus and specificEpithet together
genus_species <- (paste(hol$dwc.genus, hol$dwc.specificEpithet, sep= " ", collapse=NULL))
#Use cbind to add the genus_species column to the hol data frame
hol_with_class_info_and_genusspecies <- data.frame(cbind(genus_species, hol_with_new_class_info))
##6b.Do the same thing with the nom data frame (using the columns Genus.current and species.current).
#Create the genus_species column by pasting the Genus.current and species.current together
genus_species <- (paste(nom$Genus.current, nom$species.current, sep= " ", collapse=NULL))
#Use cbind to add the genus_species column to the hol data frame
nom_with_genusspecies <- data.frame(cbind(genus_species, nom))
##6c. Use merge() to combine hol and nom (hint: you will need to use the all.x argument, read the help to figure 
##it out, and check that the resulting data frame has the same number of rows as hol).
#PROBLEML:nom_and_hol has 2814 obs when all.x=FALSE and 2917 when all.x=TRUE, but it never has the total 2984 obs
#in hol.
nom_and_hol <- merge(nom_with_genusspecies,hol_with_class_info_and_genusspecies, 
                     by.x="genus_species",  by.y="genus_species", all.x=TRUE)
##6d.Create a data frame that contains the information for the specimens identified with an invalid species name
##(content of the column Status is not NA)? (hint: specimens identified only with a genus name shouldn't be 
#included in this count.)
#create new data frame from nom_and_hol rows where the Status column is not na
#PROBLEM: This returns all rows
specimens_invalid_sp_name <- nom_and_hol[! is.na(nom_and_hol$Status), ]
##6e.Select only the columns: idigbio.uuid, dwc.genus, dwc.specificEpithet, dwc.institutionCode, dwc.catalogNumber 
##from this data frame and export the data as a CSV file (using the function write.csv) named 
##holothuriidae-invalid.csv
#PROBLEM: This isn't working, getting 0 obs whether paste or unique is used
column_subset <- paste(specimens_invalid_sp_name$idigbio.uuid,
                                                   specimens_invalid_sp_name$dwc.genus,
                                                   specimens_invalid_sp_name$dwc.specificEpithet,
                                                        specimens_invalid_sp_name$dwc.institutionCode,
                                                   specimens_invalid_sp_name$dwc.catalogNumber, sep= " ", 
                       collapse=NULL)
column_subset <- unique(specimens_invalid_sp_name[, c("dwc.genus","dwc.specificEpithet",
                                                      "dwc.institutionCode", "dwc.catalogNumber")])

