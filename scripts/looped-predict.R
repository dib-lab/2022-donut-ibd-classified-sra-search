library(dplyr)
library(readr)
library(ranger)

seed <- as.numeric(c(1,2,3,4,5,6)) # mimicing Taylor's seed values
set.seed(seed) # specify seeds for random number generator

sample_pred <- data.frame()

for (i in 1:length(snakemake@wildcards[['sig']])){

df <- read_csv(snakemake@input[['csv']]) # read in csv
optimal_rf <- read_rds(snakemake@input[['model']]) # read in the corresponding forest model

#keep the df as tibble as long as possible for easy/fast manipulations
colnames(df)[3] <- "sample"

df_w <- tidyr::pivot_wider(df,     # pivot the long df to wide format
                           id_cols = sample,    # collapse the duplicate values of the column into rownames
                           names_from = hash,   # names each column the value
                           values_from = abund) # each value linked to hash name 

df_w <- as.data.frame(df_w) #convert tibble to dataframe

#create a full set of hash samples with zero abundance for those not in original df
smush_prep <- as_tibble(!(optimal_rf$forest$independent.variable.names %in% colnames(df_w)))
smush_prep2 <- as_tibble(optimal_rf$forest$independent.variable.names)
colnames(smush_prep2)[1] <- "hash" 
smush_prep3 <- bind_cols(smush_prep,smush_prep2)
smush_prep4 <- filter(smush_prep3, value == "TRUE") %>%
  mutate(value = 0) 

smush_w <- tidyr::pivot_wider(smush_prep4,     # pivot the long df to wide format
                              names_from = hash,   # names each column the value
                              values_from = value) # each value linked to hash name 


df_t <- merge(df_w, smush_w, all = TRUE)

rownames(df_t) <- df_t$sample # Set sample as rownames
rownames(df_t) <- paste(rownames(df_t), snakemake@wildcards[['model']], sep = "_")
df_t <- subset(df_t, select = -sample) # remove sample column

pred_ibd <- predict(optimal_rf, data= df_t) # predict the diagnosis

pred_idp_df <- data.frame(sample = rownames(df_t), prediction = pred_ibd$predictions)

sample_pred <- rbind(sample_pred, pred_idp_df)
}

write_csv(sample_pred, snakemake@output[['csv']])
