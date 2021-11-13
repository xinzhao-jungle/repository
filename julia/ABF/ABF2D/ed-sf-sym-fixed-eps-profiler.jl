using LinearAlgebra, SparseArrays, Arpack
using LinearMaps
using Random
using DataFrames, CSV
using ArgParse, JSON
# Custom modules
using ABFSym
using Lattice
using PN
LinearAlgebra.BLAS.set_num_threads(1)

include("./ed-sf-sym-fixed-eps-func-threaded.jl") # read parameters from configuration file
config  = JSON.parsefile("ed-sf-sym-fixed-eps-config")
p = readconfig(config)

@time abf3d_scan(p)
