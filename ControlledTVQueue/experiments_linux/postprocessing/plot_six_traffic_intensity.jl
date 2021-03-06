cd(dirname(Base.source_path()))
include("../functions_distribution.jl")
using PyPlot

function plot_ρ1(x::Any, coeff::Tuple, μ::Function, β::Float64, plt::Module)
 λ = t -> coeff[1] + coeff[2]*sin(coeff[3]*t)
 y = Float64[]
 for i in x
  push!(y, β*λ(i)/μ(i))
 end
 plt.plot(x,y,color="blue",linestyle="--",label=L"$\rho(t)_{SR}$")
end

function plot_ρ3(x::Any, coeff::Tuple, μ::Function, β::Float64, plt::Module)
 λ = t -> coeff[1] + coeff[2]*sin(coeff[3]*t)
 y = Float64[]
 for i in x
  push!(y, β*λ(i)/μ(i))
 end
 plt.plot(x,y,color="brown",linestyle="--",label=L"$\rho(t)_{PD}$")
end

function plot_arrival_rate_function(x::Any, coeff::Tuple, plt::Module)
 λ = t -> coeff[1] + coeff[2]*sin(coeff[3]*t)
 y = λ(x)
 plt.plot(x,y,color="black",linestyle="-", label=L"$\lambda(t)$")
end

function plot_mean_number(file_array::Any, plt::Module)
  x = file_array[1,:]
  y = file_array[2,:]
  plt.plot(x,y,color="lime", label="E[Q(t)]")
end

function plot_virtual_sojourn_time(file_array::Any, plt::Module)
  x = file_array[1,:]
  y = file_array[2,:]
  plt.plot(x,y,color="tomato", label="E[S(t)]")
end

function plot_ci(file_array::Any, plt::Module)
  x = file_array[1,:]
  upper_ci = file_array[3,:]
  lower_ci = file_array[4,:]
  plt.plot(x,upper_ci,color="black", linestyle="--", linewidth = 0.1)
  plt.plot(x,lower_ci,color="black", linestyle="--", linewidth = 0.1)
end

function full_name(short_name::String)
 if short_name == "ER"
  return "Erlang"
 elseif short_name == "LN"
  return "LogNormal"
 elseif short_name == "EXP"
  return "Exponential"
 elseif short_name == "TVGG1"
  return L"$G_t/G_t/1$"
 elseif short_name == "TVGG1PS"
  return L"$G_t/G_t/1/PS$"
 elseif short_name == "SR"
  return "(sojourn time) Square-root control"
 elseif short_name == "PD"
  return "Proportional difference-matching control"
 end
end

# common parameters
coeff = (1.0, 0.2, 0.01)
γ = coeff[3]
T = 2000.0
λ = t -> coeff[1] + coeff[2]*sin(coeff[3]*t)

# super graph parameter
dist_str_set = (("EXP","EXP"), ("ER","ER"), ("LN","LN"), ("LN","ER"), ("ER","LN"))
β_set = (1.0, 10.0)
s_set = (0.1, 1.0, 10.0)

for d in dist_str_set
 arrival_str = d[1]
 service_str = d[2]
 plt = PyPlot
 plt.figure(figsize=(8,10))
 suptitle("Traffic intensity, Arrival=$(full_name(arrival_str)) (scv $(desired_scv_for_dist(arrival_str))), Service=$(full_name(service_str)) (scv $(desired_scv_for_dist(service_str))), λ(t)=$(coeff[1])+$(coeff[2])sin($(coeff[3])t)")
 for j in 1:6
  plt.subplot(3,2,j)

  s = 0
  if 1 <= j <= 2
   s = 0.1
  elseif 3 <= j <=4
   s = 1.0
  elseif 5 <= j <= 6
   s = 10.0
  end

  β = isodd(j) ? 1.0:10.0
  if j == 1 || j == 2
   plt.title("β = $β")
  end

  if j ∈ (1,3,5)
   plt.ylabel("s = $s")
  end

  arrival_dist = Distribution_generator(arrival_str, β, desired_scv_for_dist(arrival_str))[1]
  service_dist = Distribution_generator(service_str, β, desired_scv_for_dist(service_str))[1]

  V = (scv(arrival_dist)+scv(service_dist))/2
  Vps = (scv(arrival_dist)+scv(service_dist))/(1+scv(service_dist))

  μ1(t) = ( s*λ(t)*β + β + sqrt((s*λ(t)*β+β)^2 + 4*s*λ(t)*(β^2)*(V-1) ) )/(2*s)
  μ2(t) = ( s*λ(t)*β + sqrt((s*λ(t)*β)^2 + 4*s*λ(t)*(β^2)*Vps ) )/(2*s)
  μ3(t) = β*(λ(t)+ Vps/s)

  x = linspace(0.0,2000.0,10000)
  plot_arrival_rate_function(x, coeff, plt)
  plot_ρ1(x, coeff, μ1, β, plt)
  #plot_ρ2(x, coeff, μ2, β, plt)
  plot_ρ3(x, coeff, μ3, β, plt)
  plt.legend(loc = "upper right", fontsize = 8)
  plt.savefig("../plots/traffic_intensities_$(arrival_str)_$(service_str).pdf")
 end
 plt.close()
end



## for paper '

dist_str_set = (("ER","ER"), ("LN","LN"))
β = 1.0
for j in 1:6
 plt.subplot(3,2,j)
 s = 0
 if 1 <= j <= 2
  s = 0.1
 elseif 3 <= j <=4
  s = 1.0
 elseif 5 <= j <= 6
  s = 10.0
 end

 if isodd(j)
  plt.ylabel("s = $s")
 end

 d = isodd(j) ? dist_str_set[1] : dis_str_set[2]
 arrival_str = d[1]
 service_str = d[2]
 arrival_dist = Distribution_generator(arrival_str, β, desired_scv_for_dist(arrival_str))[1]
 service_dist = Distribution_generator(service_str, β, desired_scv_for_dist(service_str))[1]

 V = (scv(arrival_dist)+scv(service_dist))/2
 Vps = (scv(arrival_dist)+scv(service_dist))/(1+scv(service_dist))

 μ1(t) = ( s*λ(t)*β + β + sqrt((s*λ(t)*β+β)^2 + 4*s*λ(t)*(β^2)*(V-1) ) )/(2*s)
 μ3(t) = β*(λ(t)+ Vps/s)

 x = linspace(0.0,2000.0,10000)
 plot_arrival_rate_function(x, coeff, plt)
 plot_ρ1(x, coeff, μ1, β, plt)
 #plot_ρ2(x, coeff, μ2, β, plt)
 plot_ρ3(x, coeff, μ3, β, plt)
 plt.legend(loc = "upper right", fontsize = 8)
 plt.savefig("../plots/traffic_intensities.pdf")
end


arrival_str = d[1]
service_str = d[2]
plt = PyPlot
plt.figure(figsize=(8,10))
suptitle("Traffic intensity, Arrival=$(full_name(arrival_str)) (scv $(desired_scv_for_dist(arrival_str))), Service=$(full_name(service_str)) (scv $(desired_scv_for_dist(service_str))), λ(t)=$(coeff[1])+$(coeff[2])sin($(coeff[3])t)")
for j in 1:6
 plt.subplot(3,2,j)

 s = 0
 if 1 <= j <= 2
  s = 0.1
 elseif 3 <= j <=4
  s = 1.0
 elseif 5 <= j <= 6
  s = 10.0
 end

 β = isodd(j) ? 1.0:10.0
 if j == 1 || j == 2
  plt.title("β = $β")
 end

 if j ∈ (1,3,5)
  plt.ylabel("s = $s")
 end

 arrival_dist = Distribution_generator(arrival_str, β, desired_scv_for_dist(arrival_str))[1]
 service_dist = Distribution_generator(service_str, β, desired_scv_for_dist(service_str))[1]

 V = (scv(arrival_dist)+scv(service_dist))/2
 Vps = (scv(arrival_dist)+scv(service_dist))/(1+scv(service_dist))

 μ1(t) = ( s*λ(t)*β + β + sqrt((s*λ(t)*β+β)^2 + 4*s*λ(t)*(β^2)*(V-1) ) )/(2*s)
 μ2(t) = ( s*λ(t)*β + sqrt((s*λ(t)*β)^2 + 4*s*λ(t)*(β^2)*Vps ) )/(2*s)
 μ3(t) = β*(λ(t)+ Vps/s)

 x = linspace(0.0,2000.0,10000)
 plot_arrival_rate_function(x, coeff, plt)
 plot_ρ1(x, coeff, μ1, β, plt)
 #plot_ρ2(x, coeff, μ2, β, plt)
 plot_ρ3(x, coeff, μ3, β, plt)
 plt.legend(loc = "upper right", fontsize = 8)
 plt.savefig("../plots/traffic_intensities_$(arrival_str)_$(service_str).pdf")
end
plt.close()
