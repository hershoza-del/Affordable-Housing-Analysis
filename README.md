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
| Key fields | Units by income tier, total units, counted (affordable) units, program group, start date, extended-affordability flag |

**Income tiers.** HPD defines them as a share of Area Median Income (AMI):

| Tier | % of AMI |
|---|---|
| Extremely Low | 0–30% |
| Very Low | 31–50% |
| Low | 51–80% |
| Moderate | 81–120% |
| Middle | 121–165% |

## Findings

### Question 1: How much of each project is affordable?



### Question 2: Which income levels receive the most units?



### Question 3: How do program groups differ in size?

| Program | Projects | Median affordable units |
|---|---|---|
| Multifamily Finance | 1,196 | 104 |
| Small Homes | 46 | 36 |
| Multifamily Incentives | 2,742 | 9 |
| Homeowner Assistance | 1,944 | 1 |

