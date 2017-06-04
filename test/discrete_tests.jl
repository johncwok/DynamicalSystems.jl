#towel map:
using StaticArrays, Base.Test, DynamicalSystems
@inline function eom_towel(x)
  x1, x2, x3 = x[1], x[2], x[3]
  SVector(3.8*x1*(1-x1)-0.05*(x2+0.35)*(1-2*x3),
  0.1*((x2+0.35)*(1-2*x3)-1 )*(1-1.9*x1),
  3.78*x3*(1-x3)+0.2*x2)
end

@inline function jacob_towel(x)
  @SMatrix [3.8*(1 - 2x[1]) -0.05*(1-2x[3]) 0.1*(x[2] + 0.35);
  -0.19((x[2] + 0.35)*(1-2x[3]) - 1)  0.1*(1-2x[3])*(1-1.9x[1])  -0.2*(x[2] + 0.35)*(1-1.9x[1]);
  0.0  0.2  3.78(1-2x[3]) ]
end


@testset "Folded-Towel Map" begin
  @testset "Construction" begin
    @test typeof(DiscreteDS(rand(3), eom_towel)) <: DiscreteDS
    @test typeof(DiscreteDS(rand(3), eom_towel, jacob_towel)) <: DiscreteDS
    @test typeof(DiscreteDS(big.(rand(3)), eom_towel, jacob_towel)) <: DiscreteDS
  end
  s1 = DiscreteDS(0.1ones(3), eom_towel)
  s2 = DiscreteDS(0.1ones(3), eom_towel, jacob_towel)
  s3 = DiscreteDS(big.(0.1ones(3)), eom_towel)
  s4 = DiscreteDS(big.(0.1ones(3)), eom_towel, jacob_towel)

  @testset "Evolution & Timeseries" begin
    s1 = evolve(s1)
    s2 = evolve(s2)
    s3 = evolve(s3)
    s4 = evolve(s4)
    @test s1.state == s2.state
    @test isapprox.(s1.state, s3.state; rtol = 1e-12) == ones(s1.state)
    @test isapprox.(s1.state, s4.state; rtol = 1e-12) == ones(s1.state)

    s1 = evolve(s1, 1000)
    s2 = evolve(s2, 1000)
    s3 = evolve(s3, 1000)
    s4 = evolve(s4, 1000)
    @test isapprox.(s1.state, s2.state; rtol = 1e-12) == ones(s1.state)

    ts = timeseries(s1, 100)
    @test size(ts) == (100, 3)
    ts4 = timeseries(s4, 100)
    @test size(ts4) == (100, 3)
    @test eltype(ts4) == BigFloat
  end
  @testset "Jacobians" begin
    s1 = DiscreteDS(0.1ones(3), eom_towel)
    s2 = DiscreteDS(0.1ones(3), eom_towel, jacob_towel)
    s3 = DiscreteDS(big.(0.1ones(3)), eom_towel)
    s4 = DiscreteDS(big.(0.1ones(3)), eom_towel, jacob_towel)

    J1 = jacobian(s1)
    @test typeof(J1) <: SMatrix
    J2 = jacobian(s2)
    J3 = jacobian(s3)
    J4 = jacobian(s4)
    @test typeof(J4) <: SMatrix

    @test isapprox.(J1, J2; rtol = 1e-12) == trues(J1)
    @test isapprox.(J1, J3; rtol = 1e-12) == trues(J1)
    @test isapprox.(J1, J4; rtol = 1e-12) == trues(J1)
    @test eltype(J3) == BigFloat
  end
end
