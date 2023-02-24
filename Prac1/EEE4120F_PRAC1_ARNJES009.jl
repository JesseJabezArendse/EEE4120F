
#Author: Jesse Jabez Arendse (ARNJES009)

# i like linespace
linspace(a,b,n) = collect(range(a,stop=b,length=n))

using Pkg
# using Tables

#_____________Uncomments the packages below once they have been installed________
using WAV
using Plots
using TickTock
using Statistics

#this function installs all packages needed to run this script
function installFunc()
	Pkg.add("WAV")
	Pkg.add("Plots")
	Pkg.add("TickTock")
	Pkg.add("Statistics")
	print("------Packages Installed---------")
	print(Pkg.status())
end

function createwhiten1(n) # n = seconds, always multiples of 10
	whiteNoise = Vector{Float64}()

	whiteNoise = (rand(48000)*2).-1
	println(n)
	WAV.wavwrite(whiteNoise, "whiteNoise1.wav", Fs=48000/n) #sample freq is 48000/n Hz
	# print( "Number of samples: " , (size(whiteNoise)))
	# print(whiteNoise)
	return whiteNoise
end

function createwhiten(n) # n = seconds, always multiples of 10
	whiteNoise = Vector{Float64}()

	for i in 1:48000
		num = (rand()*2)-1
		push!(whiteNoise,num)
	end

	WAV.wavwrite(whiteNoise, "whiteNoise2.wav", Fs=48000/n) #sample freq is 48000/n Hz
	# print( "Number of samples: " , (size(whiteNoise)))
	# print(whiteNoise)
	return whiteNoise
end

function corr(arr1,arr2)
	ave1 = mean(arr1)
	ave2 = mean(arr2)

	r = sum( (arr1.-ave1).*(arr2.-ave2) ) / ( sum( (arr1.-ave1).^2 ).^0.5 *sum((arr2.-ave2).^2 ).^0.5 )

	return r
end

function ownSin(frequency, numSamples)
	out = Vector{Float64}()
	x = linspace(0,2*pi*frequency,numSamples)
	for i in x
		push!(out   , sin(i))
	end
	return out
end

function main()
	# installFunc() #comment this out once you have run it once and all packages have been installed

	# for multiple sampling times
	sampleTimes1 = Vector{Float64}()
	WN1times	 = Vector{Float64}()
	WN2times 	= Vector{Float64}()

	times = [10 50 100 150 200 400 500 1000 1500 2000]

	for power in times
		time = power
		push!(sampleTimes1   , time)
		

		# method 1
		tick()
		whiteNoiseArray1 = createwhiten1(time)
		elapsed = tok()
		push!(WN1times   , round(elapsed , digits=4) )

		#  method 2
		tick()
		whiteNoiseArray2 = createwhiten(time)
		elapsed = tok()
		push!(WN2times   , round(elapsed , digits=4) )
	end

	# against self
	sampleTimes2 = Vector{Float64}()
	myCorrTimes = Vector{Float64}()
	statCorrTimes = Vector{Float64}()
	myCorrs 	= Vector{Float64}()
	statCorrs 	= Vector{Float64}()

	for power in times
		time = power
		push!(sampleTimes2   ,time)
		whiteNoiseArray1 = createwhiten1(time)
		whiteNoiseArray2 = createwhiten(time)

		tick()
		myCorr = corr(whiteNoiseArray2,whiteNoiseArray2)
		elapsed = tok()
		push!(myCorrTimes   ,round(elapsed , digits=4) )

		tick()
		statCorr = Statistics.cor(whiteNoiseArray1,whiteNoiseArray1)
		elapsed = tok()
		push!(statCorrTimes   ,round(elapsed , digits=4) )

		push!(myCorrs   ,round(myCorr , digits=4) )
		push!(statCorrs   ,round(statCorr , digits=4) )

		# 1
		# println("\nComparing whiteNoiseN to self")
		# println("Function Corr: ", corr(whiteNoiseArray2,whiteNoiseArray2))
		# println("Statistics Corr: ", Statistics.cor(whiteNoiseArray1,whiteNoiseArray1))
		# push!(myCorr , )
	end

	# compare white1 to white2

	sampleTimes3 = Vector{Float64}()
	mainCorrs	 = Vector{Float64}()


	for power in times
		time = power
		push!(sampleTimes3   ,time)
		whiteNoiseArray1 = createwhiten1(time)
		whiteNoiseArray2 = createwhiten(time)

		tick()
		myCorr = corr(whiteNoiseArray1,whiteNoiseArray2)
		elapsed = tok()
		push!(mainCorrs   ,round(myCorr , digits=4) )
	end

		# println("\nComparing whiteNoiseN to whiteNoiseN1")
		# tick()
		# println("Function Corr: ", corr(whiteNoiseArray1,whiteNoiseArray2))
		# elapsed = tok()
		# tick()
		# println("Statistics Corr: ", Statistics.cor(whiteNoiseArray1,whiteNoiseArray2))
		# elapsed = tok()
	
	sampleTimes4 = Vector{Float64}()
	shiftedCorrs = Vector{Float64}()

	for power in times
		time = power
		push!(sampleTimes4 , time)

		signal = ownSin(2,time)

		shiftedSignal = circshift(signal , 10)
		correl = Statistics.cor(signal,shiftedSignal)
		push!(shiftedCorrs , round(correl , digits=4) )
		# println("Corr of shiftedSignal: ", correl )
		Plots.scatter(signal,shiftedSignal)
	end

	println("")
 	for i in 1:10
		println(sampleTimes1[i] , " & " ,WN1times[i]	, " & " ,WN2times[i] , " & " ,  round(WN1times[i]/WN2times[i], digits=4)  ," \\\\")
		println("\\hline")
	end

	println("")
	for i in 1:10
	   println(sampleTimes2[i] , " & " ,myCorrTimes[i]	, " & " ,statCorrTimes[i] , " & " ,  round(statCorrTimes[i]/myCorrTimes[i], digits=4) , " & " , myCorrs[i], " & " ,statCorrs[i] ," \\\\")
	
	   println("\\hline")
	end


   println("")
   for i in 1:10
	  println(sampleTimes3[i] , " & " ,mainCorrs[i]	," \\\\")
	  println("\\hline")
	end

  println("")
  for i in 1:10
	 println(sampleTimes4[i] , " & " ,shiftedCorrs[i]	," \\\\")
	 println("\\hline")
	end

end

main()
