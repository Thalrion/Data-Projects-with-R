title: "Forecasting Credit Default Probability in R"
author: 'Author: Matthew Ludwig'
date: 'Date: 6 Mai 2017'
output: pdf_document
---
  # Introduction 
In this paper i will try to discuss some ways to **forecast** the chance that a specific costumer,
who wants to apply for a loan, will default on his payments(or not).

First at all, to *"forecast"* something is a really strange expression, isn´t it? 
Ordinary People are likely to connect *"forecasting"* with the daily weather report - and we all
know that this kind of *forecast* is not reliable all the time.

So, why making the efford trying to look into the future to estimate **default probability**?
Why banks just don´t give anyone who need it some money knowing that they can do nothing 
to reduce bad debtors? 

That´s of course not how this works - the most intuitiv way (and av really still popular one) is that
a skilled and experienced *loan officier* does his/her best to decide whether an applicant gets approved - or not.

Well, even though i personally lended a few bucks to others via P2P-Lending, i don´t consider myself "skilled"
and "experienced" enough to estimate the credit-worthiness of a customer. But with some *"Statistic-Magic"*, i will
try my best, so let´s just dive right in!
  
  **Note: This little project is strongly based on [Lore Dirick´s "Credit Risk Modeling in R"- DataCamp Course](https://www.datacamp.com/courses/introduction-to-credit-risk-modeling-in-r), but
i will try to make it even more straightforward to grasp the principles and ideas behind every code and calculation.**
  
  ## Importing Data
  
  
  ```{r}
# Import Data
database <- readRDS("loan_data_ch1.rds")
# Show first 4 lines
head(database[1:6], n = 4)                
```

Let´s get started - if you are new to *Programming with R*, please don´t mind any gray backgrounded box - 
  you don´t have to understand exactly what they mean. It´s just the R-Code i execute to display the results
shown in the white boxes. They are also useful if you want to replicate everything i do here.

**Note: If you want to understand what a line of code does, just look at the *hashtaged #comment* above it.**

In this case, i import the necessary database from DataCamp (see link above) and display the first 4 lines (+ header)
of our new database.

But that´s not all - we have about 29.000 Customers (who where already given a loan and we know whether they repaid it or not) to *"play with"*, as you can see here:
  
  ```{r}
tail(database[1:6], n = 4)                # Show last 4 lines
```


What can we conclude by looking at these 2 boxes?

1. They are about 29.000 Customers
2. They are 8 variables recorded:
  + loan_status   ( 1 = default, 0 = repaid)
+ loan_amnt     (total loan amount in $)
+ int_rate      (annual interest rate)
+ grade         (calculated score of credit-worthiness; compareable with "Schufa" here in Germany)
+ emp_length    (how long the customer were employed in total years)
+ home_ownership(how does the customers lives? Mortage/Rent/Own/Others)
+ annual_inc    (Annual income in $)
+ age           (Age in years since his/her birth)
+  **(annual_inc + age are not displayed above for reasons of clarity and comprehensibility)**
  3. We have missing data (look at the "NA´s" under the "int_rate"-column)
4. Before we can start, we need to do some preparations

Here are the 2 missing columns:
  
  ```{r}
head(database[7:8], n = 4)                # Show first 4 lines of the 2 missing columns
```

## Further Insides

We now have our Database and we roughly know how it looks like. But that´s not enough - with some
simple functions here in R, we can gain even more detailed informations. Instead of just building
a statistical model without knowing what it does, let´s have a look on some interesting tables:
  
  ```{r}
library(gmodels)
```

**Note: To this point, i worked only with the basic version of R. But since R is a "open-sourced-programming-language", basically everyone can contribute to make R even more powerful (like Wikipedia for example). But in order to use functions build by other users/developer, we need to import it. Everytime you see
me using `library`, i make use of an extern R package.**
  
  ```{r}
CrossTable(database$loan_status)
```

So this table is actually way more interesting, isn´t it?
It simply splits our data and shows the amount of people who succesfully repaid their loan - and those,
who didn´t.

About 3227 Customers (or 11.1%) defaulted on their loans. Please note that we don´t know on which
point of loan duration they defaulted - we just know that at some point, these customers weren´t able
to pay for interest and principals (i will come to this on a later point).

We can do the same thing to find out how many people in total lived under different circumstances:
  
  ```{r}
CrossTable(database$home_ownership)
```

The biggest part of customers were paying rent ( ~50% ), while the second biggest part lived in a mortgage-financed house ( ~41% ).
Only ~ 8% lived in their own house.

Well, i honestly don´t know what "Others" could mean. Apparently, they are 97 customers who may lived under
a Bridge or temporarly rentfree in some other places (maybe soldiers living in a barrack or grown adults
                                                      living rentfree at hotel mama?)

What we don´t see is, how a different home ownership has an impact on default probability.
But that would be quit interesting - what do you think? Which group has the highest chance of defaulting?

The `CrossTable` function can give us the answer:
  
  ```{r}
CrossTable(database$home_ownership, database$loan_status, prop.r = TRUE, 
           prop.c = FALSE, prop.t = FALSE, prop.chisq = FALSE)
```

This table looks way more confusing, but it´s quite powerful. 
It gives us some really interesting insides.

Can you see which group of home ownership has the highest chance of defaulting? (remember: default = loan_status 1)

With a chance of 17.5%, the group of "Others" are most likely to default. So it seems that living under a Bridge
or living rentfree with your parents are not a good sign for your credit worthiness. Please note that
- due to the small amount of "Others" - this is not a really significant conclusion.

Suprisingly, the best creditors ( = lowest default probability) are those who live in a mortgage-financed house!
  That´s quite interesting - intuitivly, you should think that those who actually own a house are more likely to
pay their loans. Well, that´s  a topic better discussed somewhere else.

Remember that every costumer were given a "Grade" 
from A-G, representing their credit-worthiness? Obviously, someone already did some analyses of the default-probability. With this information, we can evaluate the existing grade-system:
  
  ```{r}
CrossTable(database$grade, database$loan_status, prop.r = TRUE, 
           prop.c = FALSE, prop.t = FALSE, prop.chisq = FALSE)
```

If you want to understand this kind of table, don´t try to understand every single cell displayed.
Just have a look at the really interesting part: The evolution of default-probability from A (=best grade)
to G (=worst grade).

It seems that this grade model is quite useful - can you see the linear relationship? 
With every downgrade, the group of customers are more likely to default. "A"-graded customers have a
5,9% default-probability on average, while the worst Grade "G" have an enourmes default-quote of 37,5%!
  
  Of course, i don´t want to do this for every of our 8 variables - that´s the task of my model i will build.

A more intuitiv way of displaying a linear relationship is by plotting it:
  
  **Note: Usually, you don´t display the code when you plot something, since the only interesting thing is 
the actual plot. But for reasons of replicability, i will show the code anyway.**
  
  ```{r results = 'hide'}
# Creating a variable that contains our CrossTable shown above
data <-CrossTable(database$grade, database$loan_status, prop.r = TRUE, prop.c = FALSE, prop.t = FALSE, prop.chisq = FALSE)
```
```{r}
# Creating a variable that contains only the default probability
data_relationship <- data$prop.row[,2]  
# Plotting it
position <- data_relationship / 2
text(x = barplot(data_relationship),labels=names(data_relationship), y = position)
title("The worse the grade, the higher the default probability")

```

Now the linear relationship is even more identifiable! 
  
  While the difference between every downgrade is decreasing down to "E", it´s dramatically changing
from "E" to "F" and even more from "F" to "G."
That indicates that the bank should probably stop giving loans to "E" and "G" debtors or demand a 
way higher interest rate.

In R, it´s really straightforward to show this. All we do is plotting the difference between the grades:
  
  ```{r}
difference <- diff(data_relationship)
plot(difference, type = "b", xlab = "Grades", ylab = "Changes in Default Probability",xaxt="n") 
axis(1, at=1:6, labels=names(difference))
title("Probability of Default are changing dramatically from E/F and F/G")
```


# Preparing Data

I think we gained enough insides from our database. We now know that the grade is a good indicator to estimate
default-probability - also the home ownership should be a variable to consider when we want to give a future customer a loan.

By now, we have actually a really simple Forecast-System:
  Imagine you are a loan officer, responsible to decide whether a customer get´s a loan or not.
When someone enters your office, asking for some money, you could just ask "Okay, what´s your grade?"
When the customer says "My grade is C", then you just look up the CrossTable shown above to estimate,
how likely future default of this specific costumer is.

This approach is - of course - not really scientificly correct, because we need to incorporate every variable (and
                                                                                                               their relation to each other) we have. 

A really non-trivial and critical task for every ongoing-DataScientist is to prepare his/her Data
for further analyses. Of course, this may not be the most interesting part of this project.
Feel free to skip this part and go ahead to **Building the Forecast Model**. (by clicking on the Table of Content 
                                                                              on the left side)

After this chapter, our Database will look a little bit different - but don´t worry, i will briefly
explain the changes made.

## Replacing Missing Data

```{r}
summary(database)
```
Most of the time when you handle large dataset, you are confronted with NA´s. In this case, they are
much NA´s in the int_rate - column and some in the emp_length-column.

```{r}
head(database[1:6], n = 4)  
```

For example - for customer 2 and 4 here are no annual interest rate given. This can have different reasons (failed recording, customer refused to share information etc.).

They are some ways how to handle them:
  ```{r}
library(xts)
data_locf <- na.locf(database)
head(data_locf[1:6], n = 5)
```

Look, the `NA´s` are gone! What is this kind of sorcery? 
In this example, i used the `locf`-function ( "last observation carried forward") from the `xts`-package
to simply fill the `NA´s` with the last obvervation. Customer 2 now has the same rate as customer 1
and customer 4 the same as customer 3.

Here is the other way: ("next observation carried backwards")

```{r}
library(xts)
```
```{r}
data_nocb <- na.locf(database, fromLast = TRUE)
head(data_nocb[1:6], n = 5)
```

Well, while both of this approaches come really handy when you work with Time-Series-Data (like stock prices), 
in this special case they don´t make any sense. Why should costumer 2 have the same rate like costumer 1 or 3? 
They are not related to each other in any way - so, let´s dismiss this idea.

But wait.. what if we don´t want to remove all those `NA´s` or replace them with (useless) numbers?
What if a not known interest rate is actually something we can use to improve our forecast?

Let´s try something different: Why we don´t create "bins" of interest rates (like 0-7, 7-9, etc.)?
Since these categories are non-numerical factors, we can create a last bin called "Missing" and calculate with them!
  
  ```{r}
database$int_bin <- rep(NA, length(database$int_rate))

database$int_bin[which(database$int_rate <= 7)] <- "0-7"
database$int_bin[which(database$int_rate > 7 & database$int_rate <= 9)] <- "7-9"
database$int_bin[which(database$int_rate > 9 & database$int_rate <= 11)] <- "9-11"
database$int_bin[which(database$int_rate > 11 & database$int_rate <= 13.5)] <- "11-13.5"
database$int_bin[which(database$int_rate > 13.5)] <- "13.5+"
database$int_bin[which(is.na(database$int_rate))] <- "Missing"
database$int_bin <- as.factor(database$int_bin)

```

Okay, i know - that´s a lot of confusing code.
Let me explain it:
  
  1. We create a new column in our database called "int_bin" ("interest-bin").
2. This column is filled with nothing but `NA´s` and has the same length like all the other columns.
3. Now we start to create our bins:
  + Every customer with less than 7% interest rate is in our first bin "0-7".
+ Every customer with less than 9%, but with more than 7% is in our 2nd bin "7-9".
+ etc. up to "13.5+".
4. The most important point: Every customer with no interest rate is now in a "Missing"-bin!
  5. Lastly, we transform the whole column into a factor.


Here you can see how many customers are in each bin: (maybe i should do the first bin larger?)
```{r}
plot(database$int_bin)
```

Now we do the same for the "emp_length" - column. To make this look a little bid less confusing, 
i removed the code for the bin - creation. Just know that they are new bins for the emp_length 
and they look like this:
  
  ```{r, echo = FALSE}
database$emp_bin <- rep(NA, length(database$emp_length))

database$emp_bin[which(database$emp_length <= 1)] <- "0-1"
database$emp_bin[which(database$emp_length > 1 & database$emp_length <= 3)] <- "1-3"
database$emp_bin[which(database$emp_length > 3 & database$emp_length <= 7)] <- "3-7"
database$emp_bin[which(database$emp_length > 7)] <- "7+"
database$emp_bin[which(is.na(database$emp_length))] <- "Missing"

database$emp_bin <- as.factor(database$emp_bin)
```
```{r}
plot(database$emp_bin)
```

Now that we have new and improved columns for our interest rates and employment length, let´s remove
the old ones:
  ```{r}
database$int_rate <- NULL
database$emp_length<- NULL
```
## Removing Outliers

Before i finish the Data-preparation, let me look for something called "Outliers".
Outliers are specific datapoints that significantly differ from all the others.
Imagine you have a set of data with Ages of People reaching from 18-60. Now, there 
is one who is like 1000 years old. Obviously, this can´t be right, so you have to remove this datapoint
before you can go ahead and analyse the data.

Let´s have another look on our summary:
  
  ```{r}
summary(database)
```

Feel free to compare the new summary to our old ones computed above.

You now know what an "Outlier" is - actually, there is a really big one. Can you spot it?

Maybe this plot can help you:
  
  ```{r}
plot(database$age, ylab = "Age")
```

Do you see this lonely point on the top of the image? Apparently, one of the creditors was more than 144 age old!
  This is ether Wolverine who asked for money or it´s a mistake - maybe it was meant to be "44" and someone added a 1?
Who knows, but let´s remove it:
  ```{r}
index_highage <- which(database$age > 100)
database <- database[-index_highage, ]
```
Great! How old is our new, oldest customer?
```{r}
max(database$age)
```
Okay, a 94 year old who applied for a loan? At least that´s more realistic than a 144 year old, so let´s keep it.

When you looked at the summary closely, you maybe saw another outlier:
  
  ```{r}
plot(database$annual_inc, ylab = "Annual Income")
```

Here, we have a few of them! Why you should apply for a loan for a few thousend dollars, when you earn more than
1 Million $/year? This may be legit, but let´s remove them anyway.

```{r}
index_highincome <- which(database$annual_inc > 1000000)
database <- database[-index_highincome, ]
```

# Building the Forecast Model

If you skipped the last 2 part´s, here are the changes made:
  
  1. Our Database now contains "interest-bins" instead of numeric interest rates
2. We did the same for "the emp_length"-column
3. Outliers (= datapoints, that are clearly false) were removed

Let´s get to the " meat and potatoes"-part of this project - building the Forecast-Model

I will shortly explain how we will do this:
  
  1. Import Data (check)
2. Prepare Data (check)
3. Find out, which variables are important (next)
4. Build the model (last)

## Sampling

Do you remember that we want to forecast default probability of **future-customers**? We don´t want to
find out if past customers were able to repay their loan - we already know this!
  
  If you ever want to build a forecast-model (or something similiar like a Trading Backtest), 
*NEVER EVER* use your whole dataset to fit your model on. Please, remember this - NEVER. Just don´t.

This process is called **Sampling**. For this, we split our data into 2 groups:
  
  1. Our Training Group (we will fit our model on this group)
```{r}
training <- database[1:20000,]
```
2. Our Test Group ( we will test our Model on them)
```{r}
test <- database[20000:29092,]
```

We will **only** fit the model on the training group - we are not allowed to touch the test set in any way.

But why this? Would a Model build on all 29000 Customers not be more useful? 
The answer is: No, absolutly not.

In Statistic-Testing, this is something called "Overfitting". 

Let me give you an example:
  
  Imagine you are a intern at a bank and your task is to find a trading system, that - literally - printed money
in the past. So you look at your database (4 weeks of Stock-data in May) and you see something interesting: 
  Every Wednesday in all 4 weeks, there was a really shift uptrend! On Average, you find out that stock prices rised 
between +1% and + 3% - every Wednesday! WoW, that was easy. Now you simulate a backtest, were your System bought
on every Wednesday and the System made 10% in only 1 month! That´s great - now you can show your results to your 
manager and get a well-paid permanent contract, because you just showed your bank that they can make 10%/month
when they just buy on every Wednesday.

You probably know that this is not how this works - why? Because the intern in this example was totally overfitting
his System - he build the Model based on all 4 weeks, and how he tested it? Right - he tested it on the same 4 weeks!
  That´s a absolut no-go - you never ever test your model on the same data that the model was build on.

In this example, the intern should try how is "Printing-Machine" would perform when tested on a different month (like June).

I hope you get the Concept of **Overfitting**. A overfitted Model is a useless Model.

**Note: If you ever encounter an ad that claim´s something like "this Trading System made 1000% in the last 2 years", 
you can be sure that it´s just a absolutly overfitted model, used to bait naive people into buying those systems. Researches proved that overfitted System are absolutly likely to lose money when used in real-life.**
  
  ## Logistic Regression
  
  Let´s find out which parameters are actually useful for our model:
  
  ```{r}
model_age <- glm(loan_status ~ age, family = "binomial", data = training)
model_age
```
You may ask now: Wait - what is this? No introduction to logistic regression or something? What does all those numbers mean?

Look at the used code: 
  
  `glm(loan_status ~ age, family = "binomial", data = training)`

1.`glm` stands for "general logistic model" and is a common used function when building forecast models.
2.`loan_status` the first variable we put in this function is just the outcome we want to predict
3.`age` is the so called "predictor"- simply said, the variable used to predict the outcome of the desired variable
4.`family = "binomial"` "binomial" just means: They are 2 possible outcomes. Customers can ether default - or not. If you want to predict way more complex outcomes, you need to choose another `family`, but they are way beyond this project.
5.`data = training` The data used. Remember: NEVER use the `test` set.

Basically, we tell the computer: "Hey, i have this variable i want to predict ("loan status"). Please look if you
can predict it´s outcome with these variable("age")."

As is said above - when you have to handle results with a varity of outputs, try to concentrate on the only
output of interest - in this case, it´s the `coefficents`:
  
  ```{r}
model_age$coefficients
```

There is a reason we don´t calculate these numbers manually, because there is some crazy math going on under the hood. If you have a PhD in Statistics or Math, you may know what the `glm` - function does, but for everyone with "mortal professions"", let me just interpret the results in plain english:

All other variables fixed, the older our customer is, the less likely he/she is to default on his payments.
Exactly, the odds in favor of defaulting decrease by  **e^-0.00913828^ = 0.9909033 ~ 1,00%**.

Here is the exact calculation:
```{r}
coefficient <- model_age$coefficients   # age coefficient
e <- exp(1)  # e equals the exponantional function from 1, do you remember from school math?
Percentage <- e^coefficient
Percentage
```

If you think this looks like complicated math, try to check out the formulas and calculations made behind the
`glm` function. This is not supposed to be a Intermediate Course for Statistics, so let us be satiesfied with 
2 things:
1. We roughly know what the function does and what input it needs.
2. We can interpret the results and can "translate" it into plane english.

## Statistical Significance

Of course, we could do this for all 8 variables now. But while poor Statistic-Students are forced to calculate this
by hand, let us use our `glm` - function again - but now on every variable!

```{r}
model_all <- glm(loan_status ~ ., family = "binomial", data = training)
summary(model_all)
```

I know that i "promised" you to be straigthforward here and i don´t want you to be overwelmed by those informations displayed, but let me make it simple: What is this?

As you can see in our call to the `glm` - function, i now try to predict the `loan_status` - outcome with the variable `.`. This `.` just means that we use ALL other variables given.

Instead of printing out the results, i used the `summary` - function to help us answering following question: 
**Which variables should we include?**

In Statistic, this is called the "Significance" of a variable - meassured by it´s p-value. And now again - i don´t want to get to deep into calculations, just have a look at the results: Can you see the numbers of `*` computed on the right side of a variable?

They tell us how "important" one variable is to forecast the `loan_status` outcome. Can you remember that in the Chapter **Further Insides**, i said that they are 97 People (out of 29000!) living in "Other" circumstances? I also said that 97 People are waaaay to less to use it. 

The computer now tells us the exact same thing, just "scientificly correct" for EVERY variable we have.

## Final Version

Suprisingly, this chapter will be the shortest one. Why? Because actually building the model is a really 
short task. 

We now know 2 important things:
1. Which function (`glm`) we need to use.
2. What it roughly does (in the next chapter, you can see a concrete calculation).
3. Which Variables are `signifcant`.

So, here it is:

```{r}
Final_Model <- glm(loan_status ~ loan_amnt + grade + annual_inc + int_bin + emp_bin, family = "binomial", data = training)
```

**Note: We don´t use variables like "Age" or "Home_Ownership" due to their unsignificants. When you try to predict, what wheter tomorrow will be and you find out that the amount of chocolate you ate today has absolutly no effect on the wheter, would you use this variable for prediction? No, because it´s not `significant`.**

# Testing

We nearly did it! In the next chapters, i will try to predict the default chance of 1 single customer just
by his age so you can see what calculations are been made (be careful, they are not really easy to grasp).

And finally, we will test our newly build model on the UNUSED AND NEVER touched `test-set`.

## Predicting Default Probability with 1 Variable

Before we try to predict the outcomes of loan_status for 9.000 customers, let my give you an example
how this works. Imagine, we build our model ONLY with the `age` - variable. Of course, this is not a really good
model since age has absolutly NO Significance and thus should not be used (please check it for yourself that the `age` variable has not a single `*`).

But for explanation, it should be enough. We already build our model:
```{r}
model_age$coefficients
```
Do you remember that i used this info to make following Statement: **When all other variables are fixed, the default chance decreases by ~ 1.00% when someone is 1 year older** ?

But older than whom? You probably asked what this strange `intercept` could mean. 

The `intercept` gives us the probabilty of default of the `reference categorial`. Every default-chance is
compared to this `reference categorial`. 

Here is the formula the computer will use to predict that loan_status will be 1 ("loanstatus = 1") given the age of
the customer.

$$ Probability(loanstatus = 1 | age) = \frac{1}{e^-(intercept + age\times Coeffcient )} $$
First, let us calculate the default probability of our `reference categorial`:

```{r}

DefaultProp <- 1 / (e^-(-1.905870516+0*(-0.009138289)))
DefaultProp
```
Now we know this, we can calculate the expected default chance of all customers when we just use their age!

Person1, Age 25:
```{r}
DefaultProp_Person1 <- 1 / (e^-(-1.905870516+25*(-0.009138289)))    # 
DefaultProp_Person1
```
A Person aged 25 has a 11.83241% chance of defaulting. So, let us check my statement made that this number should
decrease by ~ 1.00%, when we have a person aged 26.

Person2, Age26
Way1: (the easy, simplified way)
```{r}
Change <- -0.9909033/100
DefaultProp_Person2_Easy <- DefaultProp_Person1 * (1 + Change)
DefaultProp_Person2_Easy
```
Way2: (using the formula)
```{r}
DefaultProp_Person2_Formula <- 1 / (e^-(-1.905870516+26*(-0.009138289)))    # 
DefaultProp_Person2_Formula
```
Okay, they are not exactly the same(they are always rounding errors), but my statement was nearly correct!

## Predict Default Probability with our Model

Imagine, on Monday you finised your work on the Forecasting-Model and you want to use it + you want to see if it´s usefull or not.
On Thusday, their is coming a customer - the first one of our test set:
```{r}
test[1,]  #Show the 1st Customer
```

You maybe think now: Wait. We know if these customer will default or not since the loan_status is equal to 0. Why
we should try to predict it?
Simply said - our model doesn´t know it! It´s doesn´t know whether this customer will repay his/her loan, it only sees the values of the variables shown.

So, would our model give this customer a loan? 

```{r}
predictions_1st <- predict(Final_Model, newdata = test[1,], type = "response")
predictions_1st
```
Wow! Our model says that this customer will only default with a chance of  about 2,1%! That´s really small (compare
to averaged 11,11%), so our first Customer would have been approved.
And, suprise, suprise, our model was succesfull, since our 1st customer was NOT defaulting (loan_status = 0).

Let us have a look on our second customer:
```{r}
test[2,]
predictions_2st <- predict(Final_Model, newdata = test[2,], type = "response")
predictions_2st
```
Now, our Model says that this customer is way more likely to default - with a chance of ~ 9,367%.

Would we give this customer a credit? With this question, i want to continue to our next important task.

## Choosing the Cut-Off-Level

In the last chapter, you saw that the 1st customer was given a loan since a default chance of ~ 2,1% is really low. But our 2nd customer was a little bit more difficult.. should we accept a ~ 9,367% chance or not?

Of course, we don´t want to ask this every time for every customer, so let us define a `cut-off` level, that
just says: "Every customer with a default chance of over this `cut-off-level` will be denied"

Instead of calculating the Default Chance of only 1 customer, let us calculate it for all 9084:
```{r}
predictions_All <- predict(Final_Model, newdata = test, type = "response")
head(predictions_All)
```
We now have a really powerfull dataset. It cointains a calculated Default-Chance for every customer. 

# Evaluation
## Beeing Fannie May & Freddy Mac

Now, let us play Fannie May and Freddy Mac ("FandFrad") in the year 2007. (They just gave everyone a loan who was able to spell their names with less than 2 errors). Since we don´t care about default-chance, we just give EVERYONE a loan - no matter what our model says:
```{r}
cutoff <- 0.00
pred_cutoff_0 <- ifelse(predictions_All > cutoff,1,0)
table(test$loan_status,pred_cutoff_0)
```
The results are - as expected - devasting! Out of 9084 customers, we gave 9084 customers a loan! 
While 7929 (or ~ 87%) were repaying, 1155 (~13%) were defaulting!

So, the `Accuracity` (how many times our Model was correct) equals to:

$$ Accuracity = \frac {Right Choices}{Total Choices} $$
```{r}
Accuracity_0 <- 7929 / 9084
Accuracity_0
```

The FanFred-Method was right in 87% of all choices, since it predicted 87% of all loan_status outcomes right.

## Way more convervative

Let us enhance the complexity: After our Bank was bailed out with Billions of Tax-payers-Money because we just gave everyone a credit, the government excpect us to set our `cut-off-level` to only **5%**. So, when our model says that a specific customer will default with a chance of more than 5%, he will be denied:

```{r}
cutoff <- 0.05
pred_cutoff_5 <- ifelse(predictions_All > cutoff,1,0)
table(test$loan_status,pred_cutoff_5)
```

Oh no, it´s nearly the same code but now we have an additional column named "0"! Don´t worry, the results are really easy to understand:

1. The 0/0-Cell means: **538** customers were given a loan **AND** they repaid it, so it was `RIGHT`.
2. The 0/1-Cell means: **7391** customers were denied a loan, **BUT** it was `FALSE` because they would have repaid them.
3. The 1/1-Cell means: **1112** customers were denied a loan **AND** it was `RIGHT` because they would have defaulted.
4. The 1/0-Cell means: **43** customers were given a loan, **BUT** it was `FALSE` because they defaulted.

Ignoring the fact that we just gave 6.40% ((538 + 43 ) / 9084) of all customers a loan, at least we have only 43 Defaulters (compared to 1155).

To calculate our new `Accuracity`, we have to modify our formula, because now we have 2 right choices:

1. Giving someone a loan and he repaid it (True loan = TL)
2. Denying a loan to someone who would have defaulted (True default = TD)

$$ Accuracity = \frac {TL + TD}{Total Choices} $$

```{r}
Accuracity_5 <- (538 + 1112) / 9084
Accuracity_5
```
In only 18% of all cases, our Model was right? This can´t be true - is a `cut-off-level` of conservative 5% really so bad? Especially in comparison to the ridiculous FanFred-System?

## Profit vs. Loss. What´s more important?

You probably figured out that it´s not possible to evaluate a model only by it´s `Accuracity`. The intuition behind this is really straightforward: What is more important? Succesfully forecast someone, who were given a loan and he/she repaid it? Or someone who was denied a loan and he/she really defaulted?

That´s easy - in most cases, predicting a defaulter is way more important.

The simplified calculation behind this statement:

$$ Profit Of The Bank When Debtor Is Succesfull = \sum_{i=1}^{n} Interest Paymants$$
where "n" = Total loan Duration in years.

Simply said - when a debtor repays it´s loan, the profit for the bank is the sum of all Interest Paymants.

But what amount is lost when a customer is defaulting?

$$ Loss Of The Bank When Debtor Is Failing = LoanAmmount - (\sum_{i=1}^{n} Interest Paymants+Principals)$$ 

In most cases, the Loss (2nd Formula) exceeds the Profit (1st Formula), so it´s more important to find a potential defaulter to prevend this losses.

## Maybe something in between?

Now the government is complaining that we don´t give enough loans to the citizens and thus preventing them from living the "American-Dream" - finance unnecessary Stuff like 2nd Cars / Swimming Pools and College tuition fees. In the future, we are forced to set our `cut-off-level` to 15% for a "balanced" - method:

```{r}
cutoff <- 0.15
pred_cutoff_15 <- ifelse(predictions_All > cutoff,1,0)
table(test$loan_status,pred_cutoff_15)
```

Feel free to evaluate the results on your own! (Try to understand what each number mean)
# Conclusion

They are 2 main questions to be answered:
1.  Is our Model usefull?
2.  Which System (of different `cut-off-levels`) is the best?

Unfortunaly, with the Data given in the Dataset, it´s not possible to say whether our Model is usefull, since 
we

1.  Don´t know the loan-durations.
2.  Don´t know on which point of loan-duration the specific customer defaulted.

Without knowing these 2 Variables, we can´t calculate the amount of both Key Figurs displayed in **"Profit vs. Loss. What´s more important?"** and thus we can´t decide how many "Winners" we need to compensate for 1 "Defaulter".

But that was´nt the porpuse of this Project. We succesfully build a model which is able to estimate the default
probabilty of a customer who want´s to apply for a loan.

Next time you fill out your application for a credit, you know what happends to the data you provide and how the bank calculate it to estimate if you can repay your loan - or not.


