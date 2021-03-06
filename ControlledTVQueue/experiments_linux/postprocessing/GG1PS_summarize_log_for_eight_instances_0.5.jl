function time_axis(file_array::Any)
 temp_array = file_array[1,:]
 X = Float64[]
 for i in 1:1001
  push!(X, temp_array[i])
 end
 return X
end

function save_mean_with_ci(file_array::Any, stream::IOStream)
 X = time_axis(file_array)
 avg, upper_ci, lower_ci = Float64[], Float64[], Float64[]
 for i in 1:length(X)
  values = convert(Array{Float64,1}, file_array[2:end,i])
  #values = convert(Array{Any,1}, file_array[2:end,i])
  effective_values = Float64[]
  for v in values
   if v != -1
    push!(effective_values,v)
   end
  end
  n = length(effective_values)
  σ = std(effective_values)
  push!(avg, sum(values)/n)
  push!(upper_ci, avg[i]+1.96*(σ/sqrt(n)))
  push!(lower_ci, avg[i]-1.96*(σ/sqrt(n)))
 end
 writedlm(stream, transpose(X)) # time axis
 writedlm(stream, transpose(avg)) # average
 writedlm(stream, transpose(upper_ci)) # upper ci
 writedlm(stream, transpose(lower_ci)) # lower ci
end


arrival_set = ("ER0","LN0")
μ_set = (1.0 , 2.0)

queue = "GG1PS"
service = "ER"
N = 10000
T = 10000.0
cd(dirname(Base.source_path()))
for arrival in arrival_set
 for μ in μ_set
  if μ == 1.0
   service_set = ("ER3","LN3")
  elseif μ == 2.0
   service_set = ("ER4","LN4")
  end
  for service in service_set
   queue_length_log_file_path = "../logs/$queue/$(queue)_$(μ)_$(arrival)_$(service)_$(T)_$(N)_queue_length.txt"
   sojourn_time_log_file_path = "../logs/$queue/$(queue)_$(μ)_$(arrival)_$(service)_$(T)_$(N)_sojourn_time.txt"
   queue_length_sum_log_save_path = "../sum_logs/$queue/$(queue)_$(μ)_$(arrival)_$(service)_$(T)_$(N)_sum_queue_length.txt"
   sojourn_time_sum_log_save_path = "../sum_logs/$queue/$(queue)_$(μ)_$(arrival)_$(service)_$(T)_$(N)_sum_sojourn_time.txt"
   queue_length_file = open(queue_length_log_file_path)
   sojourn_time_file = open(sojourn_time_log_file_path)
   queue_length_file_array = readdlm(queue_length_file)
   sojourn_time_file_array = readdlm(sojourn_time_file)
   close(queue_length_file)
   close(sojourn_time_file)
   queue_length_sum_log_file = open(queue_length_sum_log_save_path, "w")
   sojourn_time_sum_log_file = open(sojourn_time_sum_log_save_path, "w")
   save_mean_with_ci(queue_length_file_array, queue_length_sum_log_file)
   save_mean_with_ci(sojourn_time_file_array, sojourn_time_sum_log_file)
   close(queue_length_sum_log_file)
   close(sojourn_time_sum_log_file)
  end
 end
end
