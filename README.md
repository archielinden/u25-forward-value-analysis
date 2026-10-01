# U25 Forward Value Analysis

## Tools

R • ggplot2 • ggrepel • Linear Regression • Data Visualisation

## Question

Which U25 forwards in Europe’s top five leagues offer the strongest attacking performance relative to their market value?

The aim of this project is to identify young forwards who combine strong attacking output with a market valuation that appears low relative to comparable players. Rather than simply ranking the cheapest players, the analysis combines attacking performance with a regression-based estimate of market value to highlight players who perform strongly while also appearing relatively undervalued.


## Data

The analysis uses 2025/26 player data from Europe’s top five leagues:

- Premier League
- LaLiga
- Bundesliga
- Serie A
- Ligue 1

Full-season performance data was taken from the [Top 5 Football Dataset](https://github.com/m-mahadi/top5-football-dataset), which combines data from sources including FBref, Understat and SofaScore.

SofaScore performance metrics were used throughout the analysis to maintain a consistent source across goals, assists, expected goals, expected assists, shots and minutes played.

Market values were taken from a separate SofaScore-derived player profile dataset.

The analysis focuses on players aged under 25 who played at least 900 minutes during the 2025/26 season.

Players were also required to have been primarily classified as forwards. Players listed as `FW` or `FW,MF` were included, while players listed as `MF,FW` were excluded. This keeps the sample focused on players who operated predominantly as forwards during the season, even if some also played in midfield.

After matching market values and removing duplicate player entries, the final sample contained **85 players**.


## Method

### Attacking Performance

Six attacking metrics were converted to per-90 values:

- Goals
- Expected goals (xG)
- Assists
- Expected assists (xA)
- Shots
- Shot accuracy

Each metric was standardised using a z-score so that metrics measured on different scales could be compared directly.

To reduce the effect of closely related statistics being counted multiple times, the metrics were grouped into three components.

**Scoring**

- Goals per 90
- xG per 90

**Creation**

- Assists per 90
- xA per 90

**Shooting**

- Shots per 90
- Shot accuracy

The two metrics within each component were given equal weight, before the three components were averaged to create an overall **Attacking Performance Score**.

A score of approximately zero represents average attacking performance within the 85-player sample. Positive values indicate above-average performance, while negative values indicate below-average performance.


## Market Value Model

A linear regression model was used to estimate each player's expected market value based on:

- Attacking Performance Score
- Age
- League
- Minutes played

Market value was log-transformed because player valuations are highly right-skewed.

The model was:

`log(Market Value) = Performance + Age + League + log(Minutes Played)`

The model explained **62.5% of the variation in log market values**, with an adjusted R² of **59.1%**.

Attacking performance was strongly associated with market value. The coefficient on the Attacking Performance Score was **0.917** and statistically significant at the 1% level.

Age also had a statistically significant negative coefficient within the U25 sample, indicating that, after controlling for performance, league and minutes, younger players tended to carry higher valuations.

The Premier League also had a large positive coefficient relative to the Bundesliga reference category, reflecting the substantially higher valuations attached to comparable players in the Premier League within this sample.

The regression is not intended to produce a definitive transfer valuation. Instead, it provides a benchmark against which each player's existing market value can be compared.


## Model-Implied Undervaluation

The regression residual was used to measure relative valuation.

A player whose actual market value was below the value implied by the model received a positive **Undervaluation Score**.

This allows the analysis to distinguish between a player who is simply inexpensive and a player who appears inexpensive relative to their age, league, minutes and attacking performance.

For displaying predicted values in euros, a smearing adjustment was applied when converting predictions from the logarithmic scale back to the original market-value scale.


## Final Value Score

Ranking players purely by model-implied undervaluation can favour players whose market values are low but whose attacking output is also relatively weak. For example, some players appeared highly undervalued by the regression despite recording below-average attacking performance within the sample. To prevent the final ranking from simply rewarding cheap players, attacking performance was given greater importance. Each player's performance and undervaluation were converted into percentile ranks.

The final score was calculated as:

**Final Value Score = 60% Performance + 40% Model-Implied Undervaluation**

The performance percentile was squared before being included in the final score. This gives additional weight to players towards the top of the attacking performance distribution rather than treating small differences across the entire ranking equally. Only players whose actual market value was below the regression estimate were included in the final shortlist. The weighting was fixed before reviewing the final ranking rather than being adjusted to favour particular players.


## Results

The final ranking produced the following top 15:

| Rank | Player | Age | League | Market Value | Model Value | Performance Score | Final Score |
|---|---|---:|---|---:|---:|---:|---:|
| 1 | Pavel Šulc | 24 | Ligue 1 | €12.4m | €23.4m | 0.715 | 0.809 |
| 2 | Carlos Espí | 20 | LaLiga | €2.7m | €21.6m | 0.604 | 0.795 |
| 3 | Benjamin Šeško | 22 | Premier League | €68.0m | €111.1m | 0.702 | 0.764 |
| 4 | Igor Matanović | 22 | Bundesliga | €6.8m | €22.6m | 0.599 | 0.760 |
| 5 | Yan Diomandé | 18 | Bundesliga | €49.0m | €61.5m | 1.049 | 0.757 |
| 6 | Said El Mala | 18 | Bundesliga | €41.0m | €50.0m | 0.911 | 0.721 |
| 7 | Christian Kofane | 19 | Bundesliga | €23.0m | €31.5m | 0.686 | 0.704 |
| 8 | Sambou Soumano | 24 | Ligue 1 | €4.2m | €14.3m | 0.372 | 0.690 |
| 9 | Joaquín Panichelli | 22 | Ligue 1 | €23.0m | €30.8m | 0.655 | 0.671 |
| 10 | Folarin Balogun | 24 | Ligue 1 | €20.0m | €25.1m | 0.661 | 0.659 |
| 11 | Igor Thiago | 24 | Premier League | €52.0m | €92.2m | 0.479 | 0.655 |
| 12 | Dženan Pejčinović | 20 | Bundesliga | €6.6m | €19.7m | 0.234 | 0.627 |
| 13 | Álvaro Rodríguez | 21 | LaLiga | €4.6m | €15.6m | 0.188 | 0.619 |
| 14 | Emersonn | 21 | Ligue 1 | €3.9m | €19.0m | 0.148 | 0.611 |
| 15 | Gift Orban | 23 | Serie A | €8.9m | €19.9m | 0.194 | 0.590 |


## Attacking Performance vs Market Value

![Attacking Performance vs Market Value](performance_vs_market_value.png)

The graph compares attacking performance with estimated market value across the full sample.

Players further to the right recorded stronger attacking performance, while players lower on the graph had lower market values. This makes the lower-right area particularly interesting when looking for potential recruitment value.

**Pavel Šulc** stands out as one of the clearest combinations of the two. His attacking performance was around the 89th percentile of the sample, while his €12.4m market value remained well below several players with similar or weaker output.

**Carlos Espí** presents an even more extreme value case. He combined an above-average attacking performance score with a market value of just €2.7m, making him one of the cheapest high-performing forwards in the sample.

**Igor Matanović** shows a similar pattern at €6.8m, combining strong attacking output with a relatively modest valuation.

At the other end of the price range, players such as **Yan Diomandé** and **Said El Mala** rank highly mainly because of their exceptional attacking performance. They are already considerably more expensive, meaning their case is based less on being cheap and more on the strength of their output.


## Actual vs Model-Predicted Market Value

![Actual vs Model-Predicted Market Value](actual_vs_predicted_market_value.png)

The second graph compares each player's actual market value with the value implied by the regression model.

The dashed line represents equal actual and model-predicted values. Players above the line are valued below the level implied by the model, while players below it are valued above that level.

**Carlos Espí** produces the largest model-implied valuation gap in the sample, with an actual value of just €2.7m despite his age, playing time and attacking performance.

**Igor Matanović** and **Pavel Šulc** also sit clearly above the line, supporting their high positions in the final ranking.

The graph also demonstrates why an expensive player can still appear relatively undervalued. **Igor Thiago**, for example, has a market value of €52m, but his performance and other characteristics cause the model to place him substantially higher.

This is therefore a measure of **relative value**, rather than simply a search for low-cost players.


## Final Ranking

![Top 15 U25 Forward Value Rankings](top15_value_ranking.png)

The final ranking combines the two sides of the analysis.

**Pavel Šulc ranks first** because he offers one of the strongest overall combinations of attacking performance and model-implied undervaluation.

**Carlos Espí ranks second**, driven by the strongest undervaluation signal in the sample while still producing strong attacking output.

Players such as **Benjamin Šeško, Yan Diomandé and Said El Mala** rank highly because their attacking performance is among the strongest in the sample, even though their existing valuations are considerably higher.

Meanwhile, players including **Matanović, Soumano, Pejčinović, Álvaro Rodríguez and Emersonn** receive a larger contribution from the value side of the ranking.

The result is a shortlist containing different types of potential recruitment targets rather than simply the fifteen cheapest or fifteen highest-performing players.


## Conclusion

This analysis provides a simple data-led approach to identifying potential recruitment value among young forwards.

The results suggest that strong value can appear in different forms. Some players, such as Pavel Šulc and Igor Matanović, combine strong attacking performance with relatively modest valuations. Carlos Espí stands out because of the size of the gap between his existing market value and the value implied by the model.

Other players, such as Yan Diomandé and Said El Mala, are already expensive but remain attractive within the ranking because of the strength of their attacking output.

The model should therefore be viewed as a **screening tool** rather than a definitive recruitment model. Its main purpose is to narrow a large group of players into a smaller set whose performance and valuation may justify further investigation.


## Limitations

There are several important limitations to the analysis.

- Market values are estimates rather than actual transfer prices and may not represent the price at which a club would be willing to sell a player.
- Performance and market-value data come from different dataset snapshots, so the valuation date may not perfectly align with the end of the 2025/26 performance period.
- The analysis uses a broad forward classification. Centre-forwards, wide forwards and hybrid attacking players can have substantially different tactical roles.
- Players classified primarily as midfielders were excluded even if they also played significant minutes as forwards.
- The model only considers attacking output, age, league and minutes. It does not account for contract length, wages, injury history, physical attributes, defensive contribution or tactical fit.
- Performance is not adjusted for team strength, possession, tactical system or quality of teammates.
- The regression is fitted and evaluated on the same 85-player sample. The residuals are therefore used as a descriptive measure of relative valuation rather than evidence of out-of-sample predictive accuracy.
- The 60/40 weighting and the decision to square the performance percentile are modelling choices rather than objectively correct weights.
- Matching players across separate data sources is imperfect, and a small number of eligible players could not be assigned a usable market value.

For these reasons, the ranking is best interpreted as a way of identifying players for further analysis rather than as a complete scouting or transfer valuation system.
