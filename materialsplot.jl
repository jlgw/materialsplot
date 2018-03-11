using InteractNext, Plots

const N_A = 6.022e23
const d = [0:0.05:10...]
materialdata = readdlm("materialdata.csv", ',', skipstart=1)
# Formatted as
# name, σ_a, σ_s, ρ, A

gr(show=false)

ui = @manipulate for  
    search in textbox("search"),
    element in 1:size(materialdata)[1]
    
    σ_astr = materialdata[element, 2]
    σ_sstr = materialdata[element, 3]
    σ_a = 0.0
    σ_s = 0.0
    try 
        σ_a = (Float64)(σ_astr)
    end
    try
        σ_s = (Float64)(σ_sstr)
    end
    elem = String(materialdata[element,1])
    ρ = materialdata[element,4]
    A = materialdata[element,5]
    N = ρ/A*N_A
    Σ = N*(σ_s+σ_a)*1e-24
    Node(:div, Node(:div, elem), 
         Node(:div, "σ_s = $(σ_sstr)"), 
         Node(:div, "σ_a = $(σ_astr)"),
         Node(:div, "A = $A"), 
         Node(:div, "ρ = $ρ"), 
         plot(d, exp.(-d*Σ), ylim = (0,1), xlabel = "cm", 
              ylabel = "Transmission [I/I_0]", label=elem))
end

on(obs(search)) do val
    finds = findin([contains(lowercase(i), lowercase(val)) 
                    for i in materialdata[:,1]], true)
    if length(finds)>=1
        obs(element)[] = finds[1]
    end
end

responder(req) = ui

webio_serve(page("/", responder))
