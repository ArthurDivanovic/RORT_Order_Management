# RORT_Order_Management

This repository is a collaborative work by Arthur Divanovic and Axel Navarro.

The objective of this project is to study a problem of Order Management (OM) in a robotized distribution centre.

## Table of Contents

1. [Introduction](#1-introduction)
2. [Installation](#2-installation)
3. [Structure and Documentation](#3-structure-and-documentation)
4. [Use](#4-use)

## 1. Introduction

This repository aims to provide all the necessary functions to solve the two steps of the OM: the allocation of the orders and their preparation (more precisely the scheduling of the orders).

The repository is organized into two main directories:

- **src**: Contains essential solving functions.
- **data**: Houses instances of the OM problem.

## 2. Installation

This repository can be cloned directly from this webpage.

## 3. Structure and Documentation

### 3.1 src folder

This directory encompasses all the files that allow to parse and solve an instance of the OM problem.

The file `main.jl`: Gathers all the essential imports utilized throughout the project. 
The file `lecture.jl`: Allows the parsing of an instance of the OM problem. 

The remainder of the directory is subdivided into two subdirectories:

#### 3.1.a prob1 - Order Allocation

- `prob1.jl`: Defines the MILP problem associated to the order allocation problem. Only the objective function is not provided. This is covered in the file below.
- `objectives.jl`: Gathers a coollection of functions that are associated to an objective. When one of these functions is called, it initiates a model of the problem thanks to the functions of `prob1.jl`. Then, the objective function is specified. The complete model and it's variables are finally returned.
- `dantzigwolfe.jl`: Gathers the functions required to solve the Dantzig Wolfe "simple decomposition" of the order allocation problem.
- `wentges.jl`: Implements the Wentges perturbation method for the Dantzig Wolfe decomposition.

#### 3.1.b prob2 - Order Scheduling

- `prob2.jl`: Defines the complete MILP problem associated to the order scheduling problem. 

### 3.2 data

The data folder contains .txt files for the OM problem. These files can be interpreted by the problem-specific parsing algorithms mentioned above. 

## 4. Use

Let us consider an example of a problem. 

0. Imports

```julia
include("src/main.jl")
```

1. Instance

```julia
P = 5
Capa = 12 * ones(Int, P)
F = 20
O = 100
FO = collect(1:F)
SO = collect(F+1:O)
filepath = "data/instance_N100_R100_O100_RS25.txt"
data = parseInstance(filepath, P, Capa, FO, SO)
```

2. Optimization parameters

```julia
time_limit = 180
```

3. Define the objective function and generate a CPLEX model

```julia
model, x, y = lexicographic(data) # Here we choose to optimize the number of racks used, then the number of orders fulfilled
```

4. Edit model parameters

```julia
if !isnothing(time_limit)
    set_time_limit_sec(model, time_limit)
end
```

5.Launch the resolution
```julia
optimize!(model)
```




