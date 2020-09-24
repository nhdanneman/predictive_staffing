# predictive_staffing
Simulations to predict levels of future staffing needs

I'm the Chief Data Scientist at Data Machines Corp. We do mainly consulting and contract work that involves standing up tailored private and hybrid clouds for compute-intensive research endeavors, as well as high-end data science.

From 2017 when I started through 2020, we've doubled in employee count (or more) annually. Part of handling this growth is having a feel for the core competencies of our staff at a personal level. Up at the 10,000-foot view, we keep track of the types of employees we have, the timeframes of our current contracts, and the scope (in terms of duration and number and type of employees needed) and likelihood (predicted, subjective) of proposed work in our business development pipeline.

We used to predict staffing needs into the future pretty casually; however, with better data and a couple hours, we decided to simulate possible events to get a sense for what the bounds and timing might be for future staffing needs. Enter 'predictive_staffing.' It takes in information about current staff, current contracts, and contracts under bid, runs a bunch of simulations, and projects staffing needs out into the future.

If you get use out of this tool, drop me a note!

## Assumptions, caveats, roadmap
- Currently, the simulations assume all bids are separate. That is, very simplisitc Monte Carlo simulation. In the future, I'll likely add hierarchical terms to account for likely correlations within customers or industries.
- Don't be afraid if your predicted staffing is hump-shaped. This just means you have, or are bidding on, work that ends. For instance, we have no employees projected to be needed in 2070 -- that's outside of our typical contract length!
- Garbage in, garbage out. It's typical for people to overestimate the likelihood of their own success -- if you are overconfident in the probability of winning each contract, you'll over-staff, and that will likely cause you long-term trouble.
- The simulations are based on monthly data. If your contracts are long (5-20 years) or short (frequently < 4 months) it might make sense for you to change to annual or weekly simulations, respectively.
