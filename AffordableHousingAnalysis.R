# =====================================================================
# Affordable Housing Production: Part 2 (R) - Statistical Tests
# Data: NYC Affordable Housing Production by Project (n = 5,928)
# All projects kept (same data as the Python charts)
# =====================================================================


# ---------------------------------------------------------------------
# SETUP: load data, tidy names, keep 11 columns
# ---------------------------------------------------------------------
df <- read.csv("/Users/hershoza/Downloads/Affordable_Housing_Production_by_Project_20261107.csv",
               check.names = FALSE)
names(df) <- tolower(gsub("[^A-Za-z]+", "_", names(df)))

tier_cols <- c("extremely_low_income_units", "very_low_income_units",
               "low_income_units", "moderate_income_units", "middle_income_units")
unit_cols <- c(tier_cols, "all_counted_units", "total_units")

df <- df[, c("project_id", "program_group", "project_start_date",
             "extended_affordability_only", unit_cols)]

# Turn "1,006" into 1006
for (col in unit_cols) df[[col]] <- as.numeric(gsub(",", "", df[[col]]))

# Logs need counts above 0
df <- df[df$total_units > 0 & df$all_counted_units > 0, ]
nrow(df)
# Result: 5928 (no rows dropped)


# ---------------------------------------------------------------------
# NEW VARIABLES
# ---------------------------------------------------------------------
df$share            <- df$all_counted_units / df$total_units
df$fully_affordable <- df$share == 1
df$size_group       <- cut(df$total_units, breaks = c(0, 10, 100, Inf),
                           labels = c("Small (1-10)", "Medium (11-100)", "Large (100+)"))
df$log_units        <- log(df$all_counted_units)
df$start_year       <- as.numeric(format(as.Date(df$project_start_date, "%m/%d/%Y"), "%Y"))
df$program_group    <- relevel(factor(df$program_group), ref = "Multifamily Finance Program")


# =====================================================================
# QUESTION 1: How much of each project is actually affordable?
# =====================================================================

# --- Test 1: Spearman correlation (project size vs. affordable share) ---
cor.test(df$total_units, df$share, method = "spearman", exact = FALSE)
# Result: rho = -0.34, S = 4.66e+10, p < 2.2e-16
# Bigger projects tend to have a smaller affordable share (moderate effect)


# --- Test 2: Chi-square (size group x fully affordable) ---
q1_table <- table(df$size_group, df$fully_affordable)

# Percent fully affordable in each size group
round(prop.table(q1_table, 1) * 100, 1)
# Result:
#                    FALSE   TRUE
#   Small (1-10)      25.5   74.5
#   Medium (11-100)   68.5   31.5
#   Large (100+)      39.5   60.5

q1_chi <- chisq.test(q1_table)
q1_chi
# Result: X-squared = 906.02, df = 2, p < 2.2e-16

# Effect size: Cramer's V
sqrt(q1_chi$statistic / (sum(q1_table) * (min(dim(q1_table)) - 1)))
# Result: V = 0.39 (moderate to strong)
# Medium projects are the most likely to be mixed-income


# --- Test 3: Logistic regression (fully affordable ~ log size) ---
q1_glm <- glm(fully_affordable ~ log(total_units), family = binomial, data = df)
summary(q1_glm)
# Result:
#                    Estimate  Std. Error  z value   p
#   (Intercept)       1.270     0.049      25.68    < 2e-16
#   log(total_units) -0.376     0.015     -25.73    < 2e-16
#   Null deviance = 8123.3 (df 5927), Residual deviance = 7374.2 (df 5926)
#   AIC = 7378.2

# Odds ratio per 1-unit increase in log(size)
exp(coef(q1_glm))
# Result: intercept = 3.56, log(total_units) = 0.686

# Odds ratio when project size doubles
exp(coef(q1_glm))[2]^log(2)
# Result: 0.77
# Each time a project doubles in size, its odds of being 100% affordable
# drop by about 23%


# =====================================================================
# QUESTION 2: Which income levels receive the most affordable units?
# =====================================================================

tier_totals <- colSums(df[tier_cols])

# Percent of affordable units in each tier (matches the bar chart)
round(tier_totals / sum(tier_totals) * 100, 1)
# Result:
#   Extremely Low 18.4 | Very Low 27.1 | Low 34.1 | Moderate 6.1 | Middle 14.2


# --- Test 4: Chi-square goodness-of-fit (are the five tiers equal?) ---
q2_chi <- chisq.test(tier_totals)
q2_chi
# Result: X-squared = 76,356, df = 4, p < 2.2e-16

# Effect size: Cohen's w
sqrt(q2_chi$statistic / sum(tier_totals))
# Result: w = 0.49 (medium to large)
# Units are not split evenly: Low gets the most, Moderate the least


# --- Test 5: Friedman test + paired Wilcoxon (tiers within each project) ---
friedman.test(as.matrix(df[tier_cols]))
# Result: Friedman chi-squared = 2814.5, df = 4, p < 2.2e-16

long <- data.frame(units = unlist(df[tier_cols]),
                   tier  = factor(rep(tier_cols, each = nrow(df)), levels = tier_cols))

pairwise.wilcox.test(long$units, long$tier, paired = TRUE, p.adjust.method = "holm")
# Result (Holm-adjusted p-values):
#                 Ext. Low   Very Low   Low       Moderate
#   Very Low      0.0021     -          -         -
#   Low           < 2e-16    < 2e-16    -         -
#   Moderate      < 2e-16    < 2e-16    < 2e-16   -
#   Middle        < 2e-16    3.3e-15    2.3e-09   < 2e-16
# All 10 pairs of tiers differ; the closest pair is Extremely Low vs. Very Low


# --- Test 6: Chi-square (does the tier mix differ by program?) ---
q2_prog <- rowsum(df[tier_cols], df$program_group)

# Each program's tier mix (rows add to 100)
round(prop.table(as.matrix(q2_prog), 1) * 100, 1)
# Result:
#                            Ext.Low  VeryLow   Low   Moderate  Middle
#   Multifamily Finance        24.6     31.7    32.3     6.3      5.2
#   Homeowner Assistance        4.8     12.6    57.1    20.5      4.9
#   Multifamily Incentives      3.1     15.9    38.0     5.0     37.9
#   Small Homes                12.5     23.3    39.0    20.1      5.1

q2_prog_chi <- chisq.test(q2_prog)
q2_prog_chi
# Result: X-squared = 73,021, df = 12, p < 2.2e-16

# Effect size: Cramer's V
sqrt(q2_prog_chi$statistic / (sum(q2_prog) * (min(dim(q2_prog)) - 1)))
# Result: V = 0.28 (small to moderate)
# Multifamily Finance serves the lowest incomes most;
# Multifamily Incentives puts over a third of its units into Middle Income


# =====================================================================
# QUESTION 3: How do program groups differ in project size?
# =====================================================================

# Median affordable units per project (matches the boxplot)
tapply(df$all_counted_units, df$program_group, median)
# Result:
#   Multifamily Finance 104 | Homeowner Assistance 1 |
#   Multifamily Incentives 9 | Small Homes 36


# --- Test 7: Welch's ANOVA + eta squared (log size) ---
oneway.test(log_units ~ program_group, data = df, var.equal = FALSE)
# Result: F = 10,015, num df = 3, denom df = 217.24, p < 2.2e-16

q3_aov <- aov(log_units ~ program_group, data = df)
q3_ss  <- summary(q3_aov)[[1]][["Sum Sq"]]

# Effect size: eta squared
q3_ss[1] / sum(q3_ss)
# Result: eta squared = 0.73 (very large)
# Program explains about 73% of the variation in project size


# --- Test 8: Tukey HSD (which pairs of programs differ) ---
TukeyHSD(q3_aov)
# Result (difference in log size, 95% CI, adjusted p):
#   Homeowner Assistance - MF Finance       -4.52  [-4.62, -4.43]   p < .001
#   MF Incentives - MF Finance              -2.26  [-2.34, -2.17]   p < .001
#   Small Homes - MF Finance                -1.14  [-1.52, -0.76]   p < .001
#   MF Incentives - Homeowner Assistance     2.27  [ 2.19,  2.34]   p < .001
#   Small Homes - Homeowner Assistance       3.38  [ 3.00,  3.76]   p < .001
#   Small Homes - MF Incentives              1.11  [ 0.73,  1.49]   p < .001
# Every pair of programs differs


# --- Test 9: Kruskal-Wallis (raw units, no normality needed) ---
kruskal.test(all_counted_units ~ program_group, data = df)
# Result: chi-squared = 4653.2, df = 3, p < 2.2e-16
# Confirms the ANOVA result


# --- Test 10: Multiple regression (log size ~ program + controls) ---
q3_lm <- lm(log_units ~ program_group + start_year + extended_affordability_only, data = df)
summary(q3_lm)
# Result (reference group = Multifamily Finance):
#                              Estimate   Std. Error   t value    p
#   (Intercept)                 3.926      7.384        0.53     0.595
#   Homeowner Assistance       -4.435      0.039     -114.10    < 2e-16
#   Multifamily Incentives     -2.176      0.037      -58.56    < 2e-16
#   Small Homes                -1.062      0.149       -7.12    1.26e-12
#   start_year                  0.0003     0.004        0.09     0.929
#   Extended Affordability=Yes  0.392      0.061        6.41    1.61e-10
#   Residual SE = 0.99 (df 5922)
#   R-squared = 0.730, Adjusted R-squared = 0.730
#   F = 3208 on 5 and 5922 df, p < 2.2e-16

# Percent difference vs. Multifamily Finance
(exp(coef(q3_lm)) - 1) * 100
# Result:
#   Homeowner Assistance        -98.8%
#   Multifamily Incentives      -88.6%
#   Small Homes                 -65.4%
#   start_year                  +0.03% per year (not significant)
#   Extended Affordability=Yes  +48.0%
# The program gaps barely change after the controls; start year has no
# effect, and Extended Affordability Only projects are about 48% larger