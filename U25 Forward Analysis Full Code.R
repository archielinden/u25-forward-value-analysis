# ============================================================
# U25 FORWARD VALUE ANALYSIS
# ============================================================

library(ggplot2)
library(ggrepel)


# ============================================================
# 1. LOAD DATA
# ============================================================

# Full-season 2025/26 performance data
perf <- read.csv("player_seasons.csv")

# Sofascore-derived player profiles used for market value
profiles <- read.csv("all_player_profiles.csv")


# ============================================================
# 2. FILTER TO 2025/26 TOP-FIVE-LEAGUE PLAYERS
# ============================================================

perf <- perf[
  perf$season_label == "2025/26",
]

# Standardise league names to match the market-value dataset
perf$league_clean <- ifelse(
  grepl("Premier League", perf$league), "Premier League",
  ifelse(
    grepl("La Liga", perf$league), "LaLiga",
    ifelse(
      grepl("Ligue 1", perf$league), "Ligue 1",
      ifelse(
        grepl("Serie A", perf$league), "Serie A",
        ifelse(
          grepl("Bundesliga", perf$league), "Bundesliga",
          NA
        )
      )
    )
  )
)

perf <- perf[
  !is.na(perf$league_clean),
]


# ============================================================
# 3. KEEP U25 PRIMARY FORWARDS WITH 900+ MINUTES
# ============================================================

# Include players listed as FW or FW,MF.
# MF,FW players are excluded because they were primarily classified as midfielders during the season.

perf <- perf[
  perf$pos %in% c("FW", "FW,MF") &
    !is.na(perf$age) &
    perf$age < 25 &
    !is.na(perf$ss_minutesPlayed) &
    perf$ss_minutesPlayed >= 900,
]

cat(
  "Eligible U25 forwards before market-value matching:",
  nrow(perf),
  "players\n"
)


# ============================================================
# 4. CLEAN NAMES AND MATCH MARKET VALUES
# ============================================================

clean_name <- function(x) {
  x <- iconv(
    x,
    from = "UTF-8",
    to = "ASCII//TRANSLIT"
  )
  
  x <- tolower(x)
  
  x <- gsub(
    "[^a-z ]",
    " ",
    x
  )
  
  x <- gsub(
    "\\s+",
    " ",
    x
  )
  
  trimws(x)
}

perf$name_clean <- clean_name(perf$player)
profiles$name_clean <- clean_name(profiles$name)


# Known naming differences between datasets
perf$name_clean[
  perf$name_clean == "francesco esposito"
] <- "francesco pio esposito"

perf$name_clean[
  perf$name_clean == "henrik meister"
] <- "henrik wendel meister"


# First match using player name and league
analysis <- merge(
  perf,
  profiles[, c(
    "name_clean",
    "league",
    "market_value"
  )],
  by.x = c(
    "name_clean",
    "league_clean"
  ),
  by.y = c(
    "name_clean",
    "league"
  ),
  all.x = TRUE
)


# Fallback match by player name only
# for players whose league differs between dataset snapshots

profile_values <- profiles[
  !is.na(profiles$market_value),
  c(
    "name_clean",
    "market_value"
  )
]

name_counts <- table(
  profile_values$name_clean
)

unique_profile_names <- names(
  name_counts[
    name_counts == 1
  ]
)

profile_values_unique <- profile_values[
  profile_values$name_clean %in% unique_profile_names,
]

missing_index <- is.na(
  analysis$market_value
)

fallback_match <- match(
  analysis$name_clean[missing_index],
  profile_values_unique$name_clean
)

analysis$market_value[missing_index] <-
  profile_values_unique$market_value[
    fallback_match
  ]


# Check players still missing a market value
still_missing <- analysis[
  is.na(analysis$market_value),
  c(
    "player",
    "age",
    "pos",
    "team",
    "league_clean",
    "ss_minutesPlayed"
  )
]

cat(
  "\nPlayers still missing a market value:\n"
)

print(
  still_missing
)


# Remove players with no usable market value
analysis <- analysis[
  !is.na(analysis$market_value) &
    analysis$market_value > 0,
]


# If a player appears more than once,
# keep the row with the most minutes
analysis <- analysis[
  order(
    analysis$name_clean,
    -analysis$ss_minutesPlayed
  ),
]

analysis <- analysis[
  !duplicated(
    analysis$name_clean
  ),
]

cat(
  "\nFinal analysis sample:",
  nrow(analysis),
  "players\n"
)


# ============================================================
# 5. CREATE PER-90 PERFORMANCE METRICS
# ============================================================

analysis$goals_p90 <-
  analysis$ss_goals /
  analysis$ss_minutesPlayed * 90

analysis$assists_p90 <-
  analysis$ss_assists /
  analysis$ss_minutesPlayed * 90

analysis$xg_p90 <-
  analysis$ss_expectedGoals /
  analysis$ss_minutesPlayed * 90

analysis$xa_p90 <-
  analysis$ss_expectedAssists /
  analysis$ss_minutesPlayed * 90

analysis$shots_p90 <-
  analysis$ss_totalShots /
  analysis$ss_minutesPlayed * 90

analysis$shot_accuracy <-
  analysis$ss_shotsOnTarget /
  analysis$ss_totalShots


# Keep complete cases for every metric used
# in the attacking performance score
analysis <- analysis[
  complete.cases(
    analysis[, c(
      "goals_p90",
      "assists_p90",
      "xg_p90",
      "xa_p90",
      "shots_p90",
      "shot_accuracy"
    )]
  ),
]

cat(
  "Final complete sample:",
  nrow(analysis),
  "players\n"
)


# ============================================================
# 6. BUILD ATTACKING PERFORMANCE SCORE
# ============================================================

# Standardise metrics within the sample
analysis$z_goals <-
  as.numeric(
    scale(
      analysis$goals_p90
    )
  )

analysis$z_xg <-
  as.numeric(
    scale(
      analysis$xg_p90
    )
  )

analysis$z_assists <-
  as.numeric(
    scale(
      analysis$assists_p90
    )
  )

analysis$z_xa <-
  as.numeric(
    scale(
      analysis$xa_p90
    )
  )

analysis$z_shots <-
  as.numeric(
    scale(
      analysis$shots_p90
    )
  )

analysis$z_accuracy <-
  as.numeric(
    scale(
      analysis$shot_accuracy
    )
  )


# Scoring component
analysis$scoring_score <- (
  analysis$z_goals +
    analysis$z_xg
) / 2


# Creation component
analysis$creation_score <- (
  analysis$z_assists +
    analysis$z_xa
) / 2


# Shooting component
analysis$shooting_score <- (
  analysis$z_shots +
    analysis$z_accuracy
) / 2


# Overall attacking performance score
analysis$performance_score <- (
  analysis$scoring_score +
    analysis$creation_score +
    analysis$shooting_score
) / 3


# Convert performance to sample percentile
analysis$performance_pct <- rank(
  analysis$performance_score,
  ties.method = "average"
) / nrow(analysis)


# Give extra weight to elite performers
analysis$performance_weighted <-
  analysis$performance_pct^2


# ============================================================
# 7. MARKET VALUE MODEL
# ============================================================

# Market value is right-skewed, so modelling its logarithm

analysis$log_market_value <-
  log(
    analysis$market_value
  )

value_model <- lm(
  log_market_value ~
    performance_score +
    age +
    league_clean +
    log(ss_minutesPlayed),
  data = analysis
)

cat(
  "\nMarket value regression:\n"
)

print(
  summary(
    value_model
  )
)


# ============================================================
# 8. ESTIMATE MODEL-IMPLIED UNDERVALUATION
# ============================================================

analysis$predicted_log_value <-
  predict(
    value_model
  )


# Smearing correction for predictions
# converted back to euros
smearing_factor <- mean(
  exp(
    residuals(
      value_model
    )
  )
)

analysis$predicted_value <-
  exp(
    analysis$predicted_log_value
  ) *
  smearing_factor


# Raw prediction used for the actual-vs-predicted graph
analysis$predicted_value_raw <-
  exp(
    analysis$predicted_log_value
  )


# Residual = actual log value - predicted log value
analysis$value_residual <-
  residuals(
    value_model
  )


# Reverse sign so positive values mean
# the player is valued below model expectation
analysis$undervaluation_score <-
  -analysis$value_residual


# Convert undervaluation to sample percentile
analysis$undervaluation_pct <- rank(
  analysis$undervaluation_score,
  ties.method = "average"
) / nrow(analysis)


# Inspect strongest model-implied undervaluation
undervalued_check <- analysis[
  order(
    -analysis$undervaluation_score
  ),
  c(
    "player",
    "age",
    "league_clean",
    "market_value",
    "predicted_value",
    "performance_score",
    "undervaluation_score"
  )
]

cat(
  "\n20 players with the strongest model-implied undervaluation:\n"
)

print(
  head(
    undervalued_check,
    20
  )
)


# ============================================================
# 9. FINAL VALUE SCORE
# ============================================================

# 60% attacking performance
# 40% model-implied undervaluation
#
# Squared performance percentile gives extra
# weight to the strongest attacking performers.

analysis$final_value_score <- (
  0.6 *
    analysis$performance_weighted +
    0.4 *
    analysis$undervaluation_pct
)


# Only shortlist players whose market value
# is below the regression estimate
final_candidates <- analysis[
  analysis$undervaluation_score > 0,
]


# Rank highest to lowest
final_candidates <- final_candidates[
  order(
    -final_candidates$final_value_score
  ),
]


# Create final shortlist
final_shortlist <- final_candidates[
  ,
  c(
    "player",
    "age",
    "league_clean",
    "market_value",
    "predicted_value",
    "performance_score",
    "performance_pct",
    "undervaluation_score",
    "undervaluation_pct",
    "final_value_score",
    "ss_minutesPlayed",
    "ss_goals",
    "ss_assists",
    "goals_p90",
    "xg_p90",
    "assists_p90",
    "xa_p90"
  )
]

cat(
  "\nTop 15 value ranking:\n"
)

print(
  head(
    final_shortlist,
    15
  )
)


# ============================================================
# 10. IDENTIFY TOP 15 FOR VISUALISATIONS
# ============================================================

top15_names <- head(
  final_shortlist$player,
  15
)

analysis$top15 <- ifelse(
  analysis$player %in% top15_names,
  "Top 15",
  "Other"
)


# ============================================================
# 11. GRAPH 1 - PERFORMANCE VS MARKET VALUE
# ============================================================

performance_value_plot <- ggplot(
  analysis,
  aes(
    x = performance_score,
    y = market_value / 1000000
  )
) +
  
  geom_vline(
    xintercept = 0,
    linetype = "dashed",
    alpha = 0.4
  ) +
  
  geom_point(
    data = analysis[
      analysis$top15 == "Other",
    ],
    alpha = 0.35,
    size = 2
  ) +
  
  geom_point(
    data = analysis[
      analysis$top15 == "Top 15",
    ],
    size = 3.2
  ) +
  
  geom_text_repel(
    data = analysis[
      analysis$top15 == "Top 15",
    ],
    aes(
      label = player
    ),
    size = 3.2,
    box.padding = 0.7,
    point.padding = 0.5,
    force = 2,
    max.overlaps = Inf,
    min.segment.length = 0,
    seed = 123
  ) +
  
  scale_y_log10(
    labels = scales::label_number(
      suffix = "m",
      accuracy = 1
    )
  ) +
  
  labs(
    title =
      "Attacking Performance vs Market Value",
    
    subtitle =
      "U25 primary forwards in Europe's top five leagues with at least 900 minutes",
    
    x =
      "Attacking Performance Score",
    
    y =
      "Market Value (€m, log scale)",
    
    caption =
      "Highlighted players are the top 15 identified by the final value ranking"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold"
    ),
    
    plot.subtitle = element_text(
      size = 10
    ),
    
    axis.title = element_text(
      size = 11
    ),
    
    plot.caption = element_text(
      size = 9
    ),
    
    legend.position = "none",
    
    plot.margin = margin(
      10,
      30,
      10,
      10
    )
  )

performance_value_plot


# ============================================================
# 12. GRAPH 2 - ACTUAL VS MODEL-PREDICTED MARKET VALUE
# ============================================================

actual_predicted_plot <- ggplot(
  analysis,
  aes(
    x = market_value / 1000000,
    y = predicted_value_raw / 1000000
  )
) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    alpha = 0.5
  ) +
  
  geom_point(
    data = analysis[
      analysis$top15 == "Other",
    ],
    alpha = 0.35,
    size = 2
  ) +
  
  geom_point(
    data = analysis[
      analysis$top15 == "Top 15",
    ],
    size = 3.2
  ) +
  
  geom_text_repel(
    data = analysis[
      analysis$top15 == "Top 15",
    ],
    aes(
      label = player
    ),
    size = 3.2,
    box.padding = 0.7,
    point.padding = 0.5,
    force = 2,
    max.overlaps = Inf,
    min.segment.length = 0,
    seed = 123
  ) +
  
  scale_x_log10(
    labels = scales::label_number(
      suffix = "m",
      accuracy = 1
    )
  ) +
  
  scale_y_log10(
    labels = scales::label_number(
      suffix = "m",
      accuracy = 1
    )
  ) +
  
  labs(
    title =
      "Actual vs Model-Predicted Market Value",
    
    subtitle =
      "U25 primary forwards in Europe's top five leagues with at least 900 minutes",
    
    x =
      "Actual Market Value (€m, log scale)",
    
    y =
      "Model-Predicted Market Value (€m, log scale)",
    
    caption =
      "Players above the dashed line are valued below the level predicted by the model"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold"
    ),
    
    plot.subtitle = element_text(
      size = 10
    ),
    
    axis.title = element_text(
      size = 11
    ),
    
    plot.caption = element_text(
      size = 9
    ),
    
    legend.position = "none",
    
    plot.margin = margin(
      10,
      30,
      10,
      10
    )
  )

actual_predicted_plot


# ============================================================
# 13. GRAPH 3 - TOP 15 VALUE RANKING
# ============================================================

top15_plot_data <- head(
  final_shortlist,
  15
)

top15_plot_data$player <- factor(
  top15_plot_data$player,
  levels = rev(
    top15_plot_data$player
  )
)

top15_ranking_plot <- ggplot(
  top15_plot_data,
  aes(
    x = player,
    y = final_value_score
  )
) +
  
  geom_col(
    width = 0.7
  ) +
  
  geom_text(
    aes(
      label = round(
        final_value_score,
        3
      )
    ),
    hjust = -0.15,
    size = 3.5
  ) +
  
  coord_flip() +
  
  scale_y_continuous(
    expand = expansion(
      mult = c(
        0,
        0.12
      )
    )
  ) +
  
  labs(
    title =
      "Top 15 U25 Forward Value Rankings",
    
    subtitle =
      "Ranking combines attacking performance with model-implied undervaluation",
    
    x = NULL,
    
    y =
      "Final Value Score",
    
    caption =
      "60% performance component (with extra weight on elite performers) and 40% model-implied undervaluation"
  ) +
  
  theme_minimal() +
  
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold"
    ),
    
    plot.subtitle = element_text(
      size = 10
    ),
    
    axis.title = element_text(
      size = 11
    ),
    
    axis.text.y = element_text(
      size = 9
    ),
    
    plot.caption = element_text(
      size = 9
    ),
    
    panel.grid.major.y =
      element_blank()
  )

top15_ranking_plot


# ============================================================
# 14. SAVE OUTPUTS
# ============================================================

ggsave(
  "performance_vs_market_value.png",
  performance_value_plot,
  width = 11,
  height = 7,
  dpi = 300
)

ggsave(
  "actual_vs_predicted_market_value.png",
  actual_predicted_plot,
  width = 11,
  height = 7,
  dpi = 300
)

ggsave(
  "top15_value_ranking.png",
  top15_ranking_plot,
  width = 9,
  height = 7,
  dpi = 300
)

write.csv(
  final_shortlist,
  "final_u25_forward_value_ranking.csv",
  row.names = FALSE
)