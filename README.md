# Affordable Housing Analysis

An analysis of **5,928 projects** in NYC's *Affordable Housing Production by Project* dataset (NYC HPD, via NYC Open Data).

## Disclaimers

- **Program and size are tangled together.** Homeowner Assistance projects are almost all 1-unit and 100% affordable, so they drive much of the "small projects are fully affordable" result. A next step is to rerun Q1 within each program.
- **With n = 5,928, almost every test is significant.** I report effect sizes (V, w, η², odds ratios) so the reader can judge how large each difference is.
- **Unit counts are not people or rents.** A "low-income" unit at 80% AMI can still rent for more than many low-income households can pay.
- **Preservation and new construction are counted together** in this dataset, so these numbers are not net new supply.
- **MOST IMPORTANTLY:** these results down below are solely based from this dataset.

## Approach

- **Python (pandas/matplotlib):** cleaned and rearranged the data and a chart for each question (charts can be found on my LinkedIn page)
- **SQL:** exploring and summarizing the data for each question
- **R:** running statistical tests for each question

## Data

| | |
|---|---|
| Source | [Affordable Housing Production by Project](https://data.cityofnewyork.us/d/hq68-rnsi), NYC Department of Housing Preservation and Development (HPD) |
| Coverage | Projects that started after January 1, 2014 and count toward the *Housing New York* / *Housing Our Neighbors* plans |
| Rows | 5,928 projects (none dropped; every project had at least 1 counted unit) |
| Key fields | units by income tier, total units, counted (affordable) units, program group, start date, extended-affordability flag |

## Findings

### Question 1: How much of each project is affordable?

| Project size | 100% affordable | Mixed-income |
|---|---|---|
| Small (1–10 units) | 74.5% | 25.5% |
| Medium (11–100 units) | 31.5% | 68.5% |
| Large (100+ units) | 60.5% | 39.5% |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Spearman correlation (size vs. affordable share) | ρ = −0.34, p < 0.001 | Bigger projects have a smaller affordable share (moderate effect) |
| Chi-square (size group × fully affordable) | χ²(2) = 906.0, p < 0.001, Cramér's V = 0.39 | Size group and being 100% affordable are related (moderate to strong) |
| Logistic regression (fully affordable ~ log size) | b = −0.376, z = −25.7, p < 0.001; OR per doubling = 0.77 | Each time size doubles, the odds of being 100% affordable drop by about 23% |

- Projects fall into two groups: **100% affordable**, or **mixed-income at about 20–30% affordable**. Few projects land in between.
- The 20–30% band matches the city's rules. In fact, policies like Mandatory Inclusionary Housing (MIH) and the 421-a / Affordable New York tax break require developers to set aside 25-30% of a building's units to be affordable and income-restricted.
- Bigger projects tend to have a smaller affordable share.
- **Medium projects (11–100 units) are the most likely to be mixed-income:** only 31.5% are fully affordable, compared with 74.5% of small projects and 60.5% of large projects.

### Question 2: Which income levels receive the most units?

| Income tier | % of AMI | Share of affordable units |
|---|---|---|
| Extremely Low | 0–30% | 18.4% |
| Very Low | 31–50% | 27.1% |
| Low | 51–80% | **34.1%** |
| Moderate | 81–120% | 6.1% |
| Middle | 121–165% | 14.2% |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Chi-square goodness-of-fit (are the 5 tiers equal?) | χ²(4) = 76,356, p < 0.001, Cohen's w = 0.49 | Units are not split evenly across tiers (medium to large effect) |
| Friedman test (tiers within each project) | χ²(4) = 2,814.5, p < 0.001 | Tier counts differ within the same projects |
| Paired Wilcoxon, Holm-adjusted | All 10 pairs p < 0.01 | Every pair of tiers differs; the closest pair is Extremely Low vs. Very Low (p = 0.002) |
| Chi-square (program × tier) | χ²(12) = 73,021, p < 0.001, Cramér's V = 0.28 | Each program has a different tier mix (small to moderate effect) |

- **Low income gets the largest share. Moderate income gets the smallest.**
- The mix depends on the program:
  - **Multifamily Finance** serves the lowest incomes most: 56% of its units go to Extremely Low or Very Low.
  - **Multifamily Incentives** (tax-incentive and inclusionary projects) puts **38% of its units in the Middle tier.** This fits 421-a options that allowed affordable units at up to 130% of AMI.

### Question 3: How do program groups differ in size?

| Program | Projects | Median affordable units |
|---|---|---|
| Multifamily Finance | 1,196 | 104 |
| Small Homes | 46 | 36 |
| Multifamily Incentives | 2,742 | 9 |
| Homeowner Assistance | 1,944 | 1 |

**Statistical Tests**

| Test | Result | What it means |
|---|---|---|
| Welch's ANOVA (log size ~ program) | F(3, 217.2) = 10,015, p < 0.001, η² = 0.73 | Program explains about 73% of the variation in project size (very large effect) |
| Tukey HSD (pairs of programs) | All 6 pairs p < 0.001 | Every program differs in size from every other program |
| Kruskal-Wallis (raw units) | χ²(3) = 4,653.2, p < 0.001 | Confirms the ANOVA result without assuming normality |
| Multiple regression (log size ~ program + start year + extended affordability) | R² = 0.73, F(5, 5922) = 3,208, p < 0.001 | Program gaps hold after the controls (see the next table) |

- **Program explains about 73% of the variation in project size** (Welch's ANOVA on log units, η² = 0.73). Every pair of programs differs (Tukey HSD), and Kruskal-Wallis confirms this without assuming normality.
- After controlling for start year and extended affordability, the gaps barely change. Start year has no effect. Extended-affordability-only projects are about 48% larger.
