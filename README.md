# U25 Forward Value Analysis

Which U25 forwards in Europe’s top five leagues offered the strongest attacking performance relative to their market value last season?

A cheap player is not automatically good value, and an expensive player is not necessarily overpriced. I wanted to identify forwards whose attacking output looked strong relative to the value attached to them.

The aim was to build a simple screening model that could narrow a large group of young forwards into a smaller set worth looking at more closely, rather than trying to decide outright who a club should sign.

## Building the sample

The analysis uses full-season 2025/26 data from the Premier League, LaLiga, Bundesliga, Serie A and Ligue 1.

I restricted the sample to players who were under 25 at the start of the season and played at least 900 league minutes. Players classified primarily as forwards (`FW` or `FW,MF`) were included, while `MF,FW` players were excluded.

After matching the performance data to market values and removing players without usable valuations, the final sample contained **85 players**.

## Measuring Attacking Performance

I did not want the performance ranking to simply become a list of the highest goalscorers.

Six attacking measures were used:

- Goals per 90
- Expected goals per 90
- Assists per 90
- Expected assists per 90
- Shots per 90
- Shot accuracy

Each metric was standardised relative to the other 84 players in the sample, then grouped into three areas. **Scoring** combined goals and expected goals, **creation** combined assists and expected assists, while **shooting** combined shot volume and shot accuracy. The three components were weighted equally to produce one overall **Attacking Performance Score**.

Using expected as well as actual output gives a broader picture than goals alone. Two players can finish with the same goal total but have got there in very different ways, so including xG, chance creation and shooting volume helps separate repeatable attacking output from a hot finishing run.

## Estimating Market Value

Once each player had an attacking performance score, I wanted to estimate what level of market value would normally be associated with that sort of profile.

I used a linear regression based on:

- Attacking Performance Score
- Age
- League
- Minutes played

Market value was log-transformed because football valuations are heavily skewed. Most players sit towards the lower end of the market, while a much smaller number are worth tens of millions more.

The model explained **62.5% of the variation in log market values**, meaning these factors accounted for a substantial share of the differences in valuation across the 85-player sample.

The results made sense. Stronger attacking performances were generally linked with higher values, younger players tended to carry a premium, and the clearest league effect, as one may have guessed, came from the **Premier League**, where comparable players were valued much more highly.

I then used the regression as a benchmark rather than treating its estimate as a player's "true" value. The interesting players were those whose actual market value sat below what the model would normally expect from a similar profile.

## From undervaluation to a final ranking

Ranking players purely by model-implied undervaluation created a problem. Some cheaper players appeared highly undervalued even when their attacking performance was only average.

To avoid that, I combined both sides of the analysis into one final score:

**60% attacking performance + 40% model-implied undervaluation**

The performance percentile was squared before entering the score, giving extra weight to players towards the top of the attacking distribution rather than treating every step up the ranking equally.

Only players whose actual market value was below the regression estimate were included. The 60/40 weighting was deliberately tilted towards performance and fixed before viewing the final ranking.

## Results

### Performance and market value

![Attacking Performance vs Market Value](performance_vs_market_value.png)

The first graph compares attacking performance with market value, with the most interesting players generally sitting towards the lower-right.

Carlos Espí and Igor Matanović stand out immediately, combining strong attacking scores with valuations of just €2.7m and €6.8m respectively. Pavel Šulc offers a similar balance at €12.4m, while Yan Diomandé and Said El Mala sit among the strongest performers in the sample but already carry much higher valuations.

### Who looks undervalued?

![Actual vs Model-Predicted Market Value](actual_vs_predicted_market_value.png)

The regression strengthens some of the initial signals. Carlos Espí is the clearest outlier, while Matanović, Šulc and several other lower-valued players also sit well above the line, indicating that their market values were below what the model expected.

However, undervaluation alone can still reward players simply for being cheap, which is why it was combined with attacking performance for the final ranking.

### Final value ranking

![Top 15 Value Ranking](top15_value_ranking.png)

Combining attacking performance with model-implied undervaluation produced the final shortlist.

**Pavel Šulc ranked first overall**, with 11 goals and 3 assists in 1,568 league minutes. The hybrid forward sat in the 89th percentile for attacking performance,  playing an instrumental role in Lyon's fourth-place finish despite the club operating under serious financial pressure.

**Carlos Espí** finished second after scoring 11 LaLiga goals in 1,350 minutes at just 20 years old, while carrying one of the lowest valuations in the sample. At the other end of the price range, **Yan Diomande**, **Benjamin Šeško** and **Said El Mala** still ranked near the top despite already being highly valued, showing that exceptional attacking output could outweigh a higher starting price. Šeško's third-place ranking may raise a few eyebrows, but his raw totals hide how strong his output was on a per-90 basis, with 11 goals and an assist coming in only 1,635 league minutes.

### The shortlist

The ranking itself only tells part of the story. Looking at the players in more detail, and at what has happened since the end of the 2025/26 season, gives a better picture of which names may be worth following.

| Rank | Player | Age | 25/26 League | 25/26 G+A | Summer 2026 update |
|---|---|---:|---|---:|---|
| 1 | Pavel Šulc | 25 | Ligue 1 | 14 | Juventus & Leeds interest |
| 2 | Carlos Espí | 21 | LaLiga | 11 | Real Madrid — €25m release clause |
| 3 | Benjamin Šeško | 23 | Premier League | 12 | - |
| 4 | Igor Matanović | 23 | Bundesliga | 13 | - |
| 5 | Yan Diomande | 19 | Bundesliga | 20 | Real Madrid — €140m package |
| 6 | Said El Mala | 20 | Bundesliga | 17 | €55m+ Dortmund bid rejected |
| 7 | Christian Kofane | 20 | Bundesliga | 9 | Arsenal interest |
| 8 | Sambou Soumano | 25 | Ligue 1 | 6 | Reims — free transfer |
| 9 | Joaquín Panichelli | 23 | Ligue 1 | 17 | - |
| 10 | Folarin Balogun | 25 | Ligue 1 | 17 | £40m Everton move collapsed |
| 11 | Igor Thiago | 25 | Premier League | 23 | - |
| 12 | Dženan Pejčinović | 21 | Bundesliga | 8 | Stuttgart — €25m |
| 13 | Álvaro Rodríguez | 22 | LaLiga | 12 | Bournemouth — €25m + €5m add-ons |
| 14 | Emersonn | 22 | Ligue 1 | 8 | Ipswich — £24m |
| 15 | Gift Orban | 24 | Serie A | 9 | Amedspor — loan |

*Age shown as of October 2026. Every player was under 25 at the start of the 2025/26 season.*

**Yan Diomande** is impossible to ignore. He produced 12 goals and eight assists at just 18 years old and still finished fifth despite already carrying one of the highest valuations in the sample. His rise has been remarkable, going from high-school football in the United States to Real Madrid in roughly two years, with Madrid eventually paying €125m plus a possible €15m in add-ons. He is no longer an undiscovered player, but his 2025/26 output explains why his reputation has risen so quickly.

**Carlos Espí** also earned a move to Los Blancos after they paid his €25m release clause. He's already showed his value early on with 2 late winners and is worth keeping an eye on. 

**Igor Matanović** is another player I would be particularly interested in following. His 11 goals and two assists came in only 1,570 league minutes, helping him finish fourth in the ranking. He remained at Freiburg over the summer and has since started 2026/27 with three goals and an assist in his first four Bundesliga appearances.

**Joaquín Panichelli also needs some context beyond his final ranking.** He had reached 16 Ligue 1 goals and was leading the league's scoring chart when an ACL injury ended his season in March. His return from injury therefore makes him one of the more interesting players on the list to revisit.

There has also been significant movement elsewhere in the shortlist. Pejčinović, Álvaro Rodríguez and Emersonn all earned substantial transfers, while El Mala, Kofane and Balogun attracted serious interest without ultimately moving. That does not validate every part of the model, but it is encouraging that so many of the players highlighted by the analysis have since attracted attention at a much higher level.

## Limitations of the analysis

The biggest limitation is the use of estimated market values. The SofaScore-derived figures provide a consistent way of comparing the full sample, but they should not be treated as live or perfectly accurate valuations. They are snapshots and can lag behind a player whose reputation is changing quickly. Carlos Espí is a good example: the €2.7m value used in the analysis was useful for comparison, but by the latter stages of an 11-goal LaLiga season it was clearly unlikely to reflect how highly clubs viewed him.

Even an accurate market value would still not be the same as the price required to actually buy a player. Transfer fees depend on contract situations, competition between buyers and how willing the selling club is to lose the player. Elliot Anderson's £116m move from Nottingham Forest to Manchester City is a good example: the fee reflects his quality, but also how important he was to Forest and how difficult he would be for them to replace.

Attacking numbers also depend heavily on context. A forward in a dominant side may receive more chances, touches and possession than somebody producing similar numbers in a weaker team, while tactical role can also change what good performance looks like.

Finally, the performance score only captures part of a player's attacking game. Metrics such as pressing data, touches in the penalty area and shot-creating actions could add more detail, while the data used here says little about physical qualities, defensive work, injuries, tactical fit, mentality or future development.

Finally, the **60/40 weighting** is a modelling choice rather than an objectively correct formula. I chose it because I wanted attacking performance to matter more than simply being cheap. A different analyst could reasonably place more or less emphasis on either side.

## Final thoughts - From data to recruitment

This is still a relatively simple analysis of young forwards. It uses a limited set of attacking metrics and cannot capture everything that determines whether a player will succeed at a new club. Even so, it provides a useful foundation for identifying players worth investigating further.

The subsequent transfer market provides some support for that. Several players highlighted by the analysis went on to earn major moves, attract substantial bids or receive increased interest from leading European clubs. That does not mean the model predicted those transfers, but there is clear overlap between the performances picked up here and the players clubs were subsequently willing to invest heavily in.

There is also plenty of scope to take the analysis further. Adding more detailed attacking metrics could give a much fuller picture of each player's style and potentially improve how closely the model reflects the way clubs evaluate young forwards.

Ultimately, though, the data should be the starting point rather than the final decision. Once a shortlist has been created, the next step is to understand the context behind the numbers. Would the player suit the tactical system of the club recruiting them? Do they have the work rate and attitude required? Are their numbers sustainable, or were they produced by one unusually strong season? And, most importantly, is there evidence that the player can continue developing rather than having already reached their current level?

That is where scouting and data analysis work best together. Statistics can reduce a large pool of players to a much more manageable shortlist and highlight names that might otherwise be overlooked. From there, detailed scouting can determine whether the numbers represent a genuine recruitment opportunity — or simply an impressive season.

## Data and code

Full-season performance data was taken from the [Top 5 Football Dataset](https://github.com/m-mahadi/top5-football-dataset), with SofaScore metrics used consistently for the attacking analysis.

Market values came from a separate SofaScore-derived player profile dataset.

The analysis was completed in **R**, with **ggplot2** and **ggrepel** used for the visualisations. The full R script and final ranking data are included in this repository.



