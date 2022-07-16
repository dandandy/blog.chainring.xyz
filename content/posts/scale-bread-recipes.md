---
title: "Bakers Percentage Web Tool"
date: 2022-07-09T23:32:49+10:00
draft: false
Author: "Daniel Barrett"
---

![Image of a loaf of sourdough bread](/images/scale-bread-recipes.jpg)

Recipes are great and all, but when a recipe's servings don't match your desired number of servings you can end up with quite a few calculations to perform. And if you're anything like me, you'll wish there was another way ... so I built a website to help scale baking recipes using Bakers Percentages. [Check it out here.](https://bread.chainring.xyz)

Scaling recipes was a common problem I faced during the sourdough baking phase of the 2020 COVID-19 lockdown. Some days I had enough flour to bake a small loaf, other days requests from friends, and some days I had an excess of starter which I didn't want to waste. To keep up I had to regularly perform calculations, to start with these calculations were on the back of a napkin, then later in Excel Spreadsheets to scale my bread recipes. This left me thinking there must be a better way.

Enter the [Bakers Percentage](https://en.wikipedia.org/wiki/Baker_percentage). The baking solution for the recipe scaling problem. What you do is set the portion of ingredients as a percentage relative to the amount of flour. This way flour is always considered 100%. For the other ingredients, we divide their weight by the total weight of flour and then multiply by 100 to get the percentage. For example, the following recipe is converted to Bakers Percentage like so:

```
400g Flour    --> 100%  (because 400/400 * 100)
260g Water    -->  65%  (because 260/400 * 100)
 80g Starter  -->  20%  (because 80/400 * 100)
  8g Salt     -->   2%  (because 8/400 * 100)
```

So now if we wanted to bake 2 loafs with each loaf using 400g flour, then we should multiply the percentages by 800. Following the example from above:

```
100% Flour    --> 800g (because 100/100*800)
 65% Water    --> 520g (because 65/100*800)
 20% Starter  --> 160g (because 20/100*800)
  2% Salt     -->  16g (because 2/100*800)
```

But what if you go to the pantry and find there's only 790g of flour left? No worries! Use my [Bakers Percentage tool](https://bread.chainring.xyz) to quickly scale your recipe.

Each recipe creates a unique URL, so you can bookmark it or share it with your friends and family!

Happy baking!

