module ProductDistributions

import Distributions: ContinuousDistribution, ContinuousMultivariateDistribution,
## Univariate Distributions
logpdf, pdf, rand!
using Reexport
@reexport using Distributions

import Base: first, start, next, done

immutable ProductDistribution <: ContinuousMultivariateDistribution
    ## Assign a prior on α, β such that
    marginals::Array{ContinuousDistribution, 1}
end

Base.length(d::ProductDistribution) = length(d.marginals)

function ProductDistribution(args...)
    ProductDistribution([args...])
end

function Distributions.insupport{T<:Real}(d::ProductDistribution, x::AbstractVector{T})
    all(map(insupport, d.marginals, x))
end

function Distributions.logpdf{T<:Real}(d::ProductDistribution, x::AbstractVector{T})
    if Distributions.insupport(d, x)
        l = zero(T)
        @inbounds for i = 1:length(d.marginals)
            l += logpdf(d.marginals[i], x[i])
        end
    else
        l = convert(T, -Inf)
    end
    l
end

function Distributions.pdf{T<:Real}(d::ProductDistribution, x::AbstractVector{T})
    exp(logpdf(d, x))
end


function Distributions.rand!{T<:Real}(d::ProductDistribution, x::DenseMatrix{T})
    P, N = size(x)
    @inbounds for i = 1:N
        for p = 1:P
            x[p, i] = rand(d.marginals[p])
        end
    end
    x
end

Base.start(d::ProductDistribution) = 1
Base.first(d::ProductDistribution) = d.marginals[1]
Base.done(d::ProductDistribution, state) = state == length(d) + 1
Base.next(d::ProductDistribution, state) = (d.marginals[state], state + 1)


export ProductDistribution

end