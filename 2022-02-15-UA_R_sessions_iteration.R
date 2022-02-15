# source url: https://www.dl.dropboxusercontent.com/s/5y2zeht7a3e9rmm/UA_R_sessions_iteration.R?dl=0

# live code: https://tinyurl.com/ua-r-iteration

# most of the lesson materials: https://mcmaurer.github.io/R-DAVIS-3.0/lesson_iteration.html

# useful (to me) snippets using these sorts of patterns: https://github.com/MCMaurer/R_snippets

library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(broom)

x <- 1:10
x
log(x)

# for loop

for (i in 1:10){
  print(i)
} 

for (i in 1:10){
  print(i)
  print(i^2)
}

# use i for indexing

for (i in 1:10){
  print(letters[i])
  print(mtcars[1, ])
}


for (cat in 3:5){
  print(letters[cat])
}

for (i in 10){
  print(letters[i])
}

for (i in c(2, 4, 5, 9, 12)){
  print(letters[i])
}

# generate empty object to hold results before running for loop

results <- rep(NA, nrow(mtcars))
results

for (i in 1:nrow(mtcars)){
  results[i] <- round(mtcars$wt[i] * mtcars$disp[i], 2)
}

results

round(results, 2)

mtcars %>% 
  mutate(result = wt*disp)


mtcars$wt[i] * mtcars$disp[i]

# introducing purrr and the map_ functions

# https://jennybc.github.io/purrr-tutorial/
# https://emoriebeck.github.io/R-tutorials/purrr/

map(1:10, sqrt)

map_dbl(1:10, sqrt)

map_chr(1:10, sqrt)

map_dbl(1:10, ~ round(sqrt(.x), digits = 2))

mtcars2 <- mtcars

mtcars2[3, c(1, 6, 8)] <- NA

mtcars2

map_dbl(mtcars, mean)
map_dbl(mtcars2, mean, na.rm = T)

# bootstrapping with map

slice_sample(mtcars, prop = 0.8, replace = T) %>% 
  lm(mpg ~ wt, data = .) %>% 
  tidy()

folds <- map(1:100, ~slice_sample(mtcars, prop = 0.8, replace = T))

m <- map(.x = folds, .f = ~lm(mpg ~ wt, data = .x)) %>% 
  map_dfr(.f = broom::tidy, .id = "iter")

m

m %>% 
  ggplot(aes(x = estimate)) +
  geom_density() +
  facet_wrap(vars(term), scales = "free")

# conditional statements

for (i in 1:10){
  if (i < 5){
    print(paste(i, "is less than 5"))
  } else {
    if (i == 5){
      print(paste(i, "is 5"))
    } else {
      print(paste(i, "is greater than 5")) 
    }
  }
}

# case_when

mtcars %>% 
  mutate(
    car_size = case_when(
      wt > 3.5 | cyl == 8 ~ "big",
      wt > 2.5 ~ "medium",
      TRUE ~ NA_character_
    )
  )

mtcars %>% 
  mutate(car_size = ifelse(wt > 2.5, "big", "small"))

mtcars %>% 
  mutate(gear = ifelse(gear == 3, NA, gear))

# writing multiple CSVs
# and using *nested* dataframes

storms %>% 
  group_by(year) %>% 
  nest() %>% 
  pwalk(.f = function(year, data){
    write.csv(x = data, file = paste0("work_projects/storms_", year, ".csv"))
  })
  
# using nest for data simulation

expand_grid(mean = 1:3, sd = c(0.1, 1)) %>% 
  rowwise() %>% 
  mutate(data = list(rnorm(n = 100, mean = mean, sd = sd))) %>% 
  unnest(data) %>% 
  ggplot(aes(x = data)) +
  geom_histogram(bins = 50) +
  facet_grid(rows = vars(mean), cols = vars(sd))

# conditional mutate

diamonds %>% 
  mutate(x = round(x, digits = 1),
         y = round(y, digits = 1),
         z = round(z, digits = 1))

diamonds %>% 
  mutate(across(.cols = everything(), as.character))

diamonds %>% 
  mutate(across(where(is.numeric), round, digits = 1))

diamonds %>% 
  mutate(across(where(is.numeric), .fns = list(rd = round)))
