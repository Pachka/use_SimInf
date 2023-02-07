##################
## Load library ##
##################

library(data.table)
library(SimInf)
cat("Hello")
##################
## Compartments ##
##################

compartments = c("S", "I", "R")

#################
## Transitions ##
#################

transitions = c("S -> beta*S*I/(S+I+R) -> I",
                "I -> gamma*I -> R")

########################
## General parameters ##
########################

gdata = c(beta = 0.16, gamma = 0.077)

###################
## Initial state ##
###################

u0 = data.frame(S = 100, I = 1, R = 0)

##############
## Duration ##
##############

tspan = 1:100

#################
## Build model ##
#################

model <- mparse(
  transitions = transitions,
  compartments = compartments,
  gdata = gdata,
  u0 = u0,
  tspan = tspan
)

#####################
## Run simulations ##
#####################

result <- run(model)
result

#########################
## Explore simulations ##
#########################

plot(result)

traj <- trajectory(result)
setDT(traj)
traj

########################
## Add sub population ##
########################

npop <- 100

u0 = data.frame(S = c(99,rep(100, npop-1)),
                I = c(1,rep(0, npop-1)),
                R = c(rep(0, npop)))


model <- mparse(
  transitions = transitions,
  compartments = compartments,
  gdata = gdata,
  u0 = u0,
  tspan = tspan
)

result <- run(model)
result

plot(result)
plot(result, index = 1)
plot(result, "S", index = 1)

traj <- trajectory(result)
setDT(traj)
traj

##########################
## Add local parameters ##
##########################

ldata = NULL
v0 = NULL
events = NULL
E = NULL
N = NULL

#########################
## Add schedule events ##
#########################

E <- structure(.Data = c(1, 0, 0, #1
                         0, 1, 0, #2
                         0, 0, 1, #3
                         0, 1, 1, #4
                         1, 1, 1, #5
                         1, 1, 0, #6
                         1, 0, 1  #7
),
.Dim = c(length(compartments),7),
.Dimnames = list(compartments,
                 c("1", "2", "3", "4", "5", "6", "7"))
)

# N matrix for the shift process
N <- matrix(rep(0, length(compartments)),
            nrow = length(compartments),
            ncol = 2,
            dimnames = list(compartments,
                            c("1", "2")))

events <- data.frame(
  event      = "enter",  ## Event "extTrans" is a movement between nodes// 0) exit, 1) enter, 2) internal transfer, and 3) external transfer
  time       = 10, ## The time that the event happens
  node       = 1, ## In which node does the event occur
  dest       = 2, ## Which node is the destination node
  n          = 1, ## How many individuals are moved
  proportion = 0, ## This is not used when n > 0
  select     = 2, ## Use the 4th column in the model select matrix
  shift      = 0 ## Not used in this example
)


pts_fun = NULL
